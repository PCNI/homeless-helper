import sys
import time
import bson
import json
import urllib
import urllib2
import os
import socket
import hashlib
import string
import feedparser
import re
from random import randint
from operator import itemgetter
import StringIO
from pygeocoder import Geocoder
from pprint import pprint
import csv

from resource import Resource
from openhmis import OpenHMIS

class Tools():
    
    def __init__(self, db, config):
        self.db = db
        self.config = config
        self.result = {'meta':{'method_name':'', 'status':''},'response':{}}

    def update_beds(self):
        self.result['meta']['method_name'] = '/tools/update_beds'

        ## fetch data file
        url = self.config.BED_DATA_URL
        req = urllib2.Request(url)

        file_name = '/tmp/beds.csv'
        
        try:
            f = urllib2.urlopen(req)
            local_file = open(file_name, 'w')
            local_file.write(f.read())
            local_file.close()

        except urllib2.HTTPError, e:
            self.result['meta']['status'] = 'FAIL'
            self.result['meta']['error'] = 'HTTP Error: %s' % (e.code)
            return self.result

        except urllib2.URLError, e:
            self.result['meta']['status'] = 'FAIL'
            self.result['meta']['error'] = 'URL Error: %s' % (e.reason)
            return self.result
            
        ## process data file
        results = []
        input_data = csv.reader(open(file_name, 'rb'), delimiter=',', quotechar='|')
        for row in input_data: 
            if row[0] == 'Agency':
                continue
                           
            shelter_info = {}
            hmis_program = row[1]
            beds = row[7]
            shelter_info['hmis_program'] = hmis_program
            shelter_info['beds'] = beds
            results.append(shelter_info)

            ## update db
            resource = Resource(self.db, self.config)
            resource.update_beds_auto_script(hmis_program, beds)

        self.result['response'] = results
        self.result['meta']['status'] = 'OK'
        return self.result


    def update_shelters(self, admin_key):
        self.result['meta']['method_name'] = '/tools/update_shelters'

        ## check admin key
        if self.config.ADMIN_KEY != admin_key:
            self.result['meta']['status'] = 'Authentication failed'
            return self.result

        resource = Resource(self.db, self.config)
        openhmis = OpenHMIS(self.db, self.config)

        shelters = openhmis.get_shelters()
        counter = 0
        shelters_total = len(shelters)
        for s in shelters:
            if counter >= shelters_total: break 
            print counter
            counter = counter + 1
            
            if resource.check_if_shelter_exists(s['ProgramName']) is False:
                
                shelter_info = openhmis.get_program_info_by_id(s['ProgramKey'])
                pprint(shelter_info)
                agency_name = shelter_info[0]['AgencyName']            
                contact_name = shelter_info[0]['ContactName']          
                contact_phone = shelter_info[0]['ContactPhone']        
                program_address_full = shelter_info[0]['ProgramAddressFull']    
                program_address_street = shelter_info[0]['ProgramAddress']    
                program_address_city = shelter_info[0]['ProgramCity']    
                program_address_zip = shelter_info[0]['ProgramZip']    
                program_key = shelter_info[0]['ProgramKey']            
                program_name = shelter_info[0]['ProgramName']          
                program_type = shelter_info[0]['ProgramType']
                site_geo_code = shelter_info[0]['SiteGeocode']
                target_pop_a_name = shelter_info[0]['TargetPopAName']
                units_available = shelter_info[0]['UnitsAvailable']
                units_occupied = shelter_info[0]['UnitsOccupied']
                units_total = shelter_info[0]['UnitsTotal']
                update_time_stamp = shelter_info[0]['UpdateTimeStamp']
                
                if program_address_full == 'NULL' or program_address_full == 'null' or program_address_full is None:
                    if program_address_street != 'NULL' or program_address_street != 'null' or program_address_street is not None:
                        if program_address_city != 'NULL' or program_address_city != 'null' or program_address_city is not None:
                            if program_address_zip != 'NULL' or program_address_zip != 'null' or program_address_zip is not None:
                                program_address_full = '%s %s %s' % (program_address_street, program_address_city, program_address_zip)
                
                if program_address_full == 'NULL' or program_address_full == 'null' or program_address_full is None or program_address_full == 'None None None':
                    print 'skipping - bad address: %s' % (program_address_full)
                    continue

                print 'normalizing data'
                ## normalize data
            
                try:
                    numbers = re.findall(r'\d+', contact_phone)
                    phone = '(%s) %s-%s' % (numbers[0], numbers[1], numbers[2])
                except:
                    phone = contact_phone
            
                try:
                    time.sleep(1)  ## too avoid google maps api rate limit

                    geo_data = self.lookup_geocode_data(program_address_full)
                    if geo_data is False:
                        print 'skipping due to False geocode result'
                        continue
                    lat = geo_data['lat']
                    lng = geo_data['lng']
                    full_address = geo_data['full_address']
                    street_1 = geo_data['street_name']
                    street_2 = ''
                    city = geo_data['city']
                    state = geo_data['state']
                    zipcode = geo_data['zipcode']
                except:
                    print 'skipping - bad geocode'
                    continue

                print 'inserting to db'
                resource_type = 'shelter'                
                va_status = 0
                name_1 = program_name
                name_2 = agency_name
                url = ''
                hours = 'Call for hours'
                notes = ''
                hmis_program = ''
                beds = int(units_available)
                if beds is None: beds = 0
                beds_occupied = int(units_occupied)
                beds_total = int(units_total)
                contact_name = contact_name
                admin_code = self.generate_admin_code()

                ## update db
                resource.new_shelter(admin_key, admin_code, resource_type, va_status, name_1, name_2, full_address, street_1, street_2, city, state, zipcode, lat, lng, phone, url, hours, notes, beds, beds_occupied, beds_total, hmis_program, contact_name, program_key, program_type, target_pop_a_name, update_time_stamp)
            else:
                'print updating program_key'
                ## update program_key
                db_result = self.db.resource.update(
                        {'name_1':s['ProgramName']},
                        {'$set':{'program_key':s['ProgramKey']}}, upsert=False)
                        
                ## update bed availability data
                db_result = self.db.resource.find_one({'program_key':s['ProgramKey']})
                current_time = int(time.time())
                last_update_time = db_result['last_updated']
                time_difference = current_time - last_update_time

                ## if within 24 hours -- use ours, do nothing
                ## if within 6 hours -- use ours, update openhmis  (http://openciss.appspot.com/bed_units/occupied/set?id=567&val=30)
                ## if over 24 hours (last resort) -- use openhmis data

                if time_difference > 86400:
                    ## update bed from openhmis
                    shelter_info = openhmis.get_program_info_by_id(s['ProgramKey'])
                    units_available = int(shelter_info[0]['UnitsAvailable'])
                    units_occupied = int(shelter_info[0]['UnitsOccupied'])
                    units_total = int(shelter_info[0]['UnitsTotal'])
                    update_time_stamp = shelter_info[0]['UpdateTimeStamp']

                    db_result = self.db.resource.update(
                            {'program_key':s['ProgramKey']},
                            {'$set':{'beds':units_available}}, upsert=False)

                    db_result = self.db.resource.update(
                            {'program_key':s['ProgramKey']},
                            {'$set':{'beds_occupied':units_occupied}}, upsert=False)

                    db_result = self.db.resource.update(
                            {'program_key':s['ProgramKey']},
                            {'$set':{'beds_total':units_total}}, upsert=False)
                    
                    ## update last update time
                    db_result = self.db.resource.update(
                            {'program_key':s['ProgramKey']},
                            {'$set':{'last_updated':int(time.time())}}, upsert=False)

                if time_difference < 21600:
                    ## send update to openhmis
                    openhmis.update_bed_units_occupied(s['ProgramKey'], db_result['beds_occupied'])


        self.result['meta']['status'] = 'OK'
        return self.result
        

    def update_jobs(self):
        self.result['meta']['method_name'] = '/tools/update_jobs'

        states = ["AL","AK","AZ","AR","CA","CO","CT","DE","FL","GA","HI","ID","IL","IN","IA","KS","KY","LA","ME","MD","MA","MI","MN","MS","MO","MT","NE","NV","NH","NJ","NM","NY","NC","ND","OH","OK","OR","PA","RI","SC","SD","TN","TX","UT","VT","VA","WA","WV","WI","WY"]

        for state in states:
            url = 'http://rss.indeed.com/rss?q=&l=%s' % (state)
        
            for entry in feedparser.parse(url)['entries']:

                try:
                    ## parse data
                    job_id = str(entry['id'])
                    job_url = str(entry['link'])
                    job_title = str(entry['title'])

                    ## parse geo coords
                    georss_point = entry['georss_point']
                    lat_re = re.search('\d+.\d+', georss_point)
                    job_lat = str(lat_re.group(0))
                    lng_re = re.search('-\d+.\d+', georss_point)
                    job_lng = str(lng_re.group(0))

                    resource = Resource(self.db, self.config)
                    resource.new_job(job_id, job_url, job_title, job_lat, job_lng)
                except:
                    pass
        
        self.remove_expired_jobs()
        self.result['meta']['status'] = 'OK'
        return self.result

    def remove_expired_jobs(self):

        current_time = int(time.time())
        time_month = int(2592000)
        time_difference = current_time - time_month
        
        db_result = self.db.resource.remove(
                {'resource_type':'job', 'last_updated': {'$lte':time_difference}})

    def lookup_geocode_data(self, address):
        try:
            print address
            results = Geocoder.geocode(address)
            if results[0].valid_address is False:
                print 'Invalid address'
                return False

            ## parse address
            geo_data = {}
            geo_data['lat'] = results[0].coordinates[0]
            geo_data['lng'] = results[0].coordinates[1]
            geo_data['street_name'] = results[0].route
            geo_data['city'] = results[0].locality
            geo_data['state'] = results[0].administrative_area_level_1
            geo_data['zipcode'] = results[0].postal_code
            geo_data['full_address'] = results[0].formatted_address
            pprint(geo_data)
            return geo_data
            
        except Exception as e:
            print 'Geocoding failed:', e
            return False
     
    def generate_admin_code(self):
        looper = True
        while looper is True:
            a = randint(1000,9999)        
            if self.check_dupe_admin_code(a) is False:
                return a
        
    def check_dupe_admin_code(self, admin_code):
        resource_object = self.db.resource.find_one({'admin_code':admin_code})
        if resource_object is not None:
            return True
        else:
            return False