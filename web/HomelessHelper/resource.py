import time
import bson
from bson import json_util
import json
import urllib
import urllib2
import base64
import string
import re
import math
import logging
from random import randint


from pprint import pprint
from pygeocoder import Geocoder

import pymongo
from pymongo import Connection
from pymongo.son import SON

from twilio.rest import TwilioRestClient

from emailsender import Email

class Resource():
    

    def __init__(self, db, config):
        self.db = db
        self.config = config
        self.result = {'meta':{'method_name':'', 'status':''},'response':{}}


    def verify_admin(self, admin_code):
        self.result['meta']['method_name'] = '/resource/verify_admin'

        ## split code
        code = admin_code[:4]
        pin = admin_code[-4:]
	

        ## query db
        resource_object = self.db.resource.find_one({'admin_code':code, 'admin_pin':pin})
        ##resource_object = self.db.resource.find({'admin_code':pin})
	if resource_object is None:
	    logging.info("object is null")
	
            ## check for user pin
            resource_object2 = self.db.resource.find_one({'admin_code':code, 'user_pin':pin})            
            if resource_object2 is None:
                self.result['meta']['status'] = 'Invalid code'
                return self.result
            else:
                access_level = 'user'
        else:
            access_level = 'admin'

        ## remove the admin_code from results
        #resource_object['admin_code'] = None

        ## build response
        if access_level == 'admin':
            self.result['response'] = resource_object
        else:
            self.result['response'] = resource_object2
            
        self.result['access_level'] = access_level
        self.result['meta']['status'] = 'OK'
        return self.result

    def complete_register(self, admin_key, resource_type, va_status, name_1, name_2, street_1, street_2, city, state, zipcode, phone, email, url, hours, notes, beds, lat, lng):
        self.result['meta']['method_name'] = '/resource/complete_register'
        
        ## check admin key
        if self.config.ADMIN_KEY != admin_key:
            self.result['meta']['status'] = 'Authentication failed'
            return self.result

        ## check bed value
        if beds is None:
            beds = 0

        ## geo lookup
        if lat is None or lng is None:            
            try:
		logging.info('geo lookup line 85')
                address_query = '%s+%s+%s+%s' % (street_1, city, state, zipcode)
                google_url = 'https://maps.googleapis.com/maps/api/geocode/json'
                headers = {}
                params = {}
                params['address'] = address_query
                params['sensor'] = 'false'        
                google_url = google_url + '?' + urllib.urlencode(params)
                req = urllib2.Request(google_url, None, headers)
                response = json.load(urllib2.urlopen(req))
                web_request_result = json.load(urllib2.urlopen(google_url))
                lat = web_request_result['results'][0]['geometry']['location']['lat']
                lng = web_request_result['results'][0]['geometry']['location']['lng']
            except:
                if resource_type == 'hotline':
                    lat = self.config.SOUL_KITCHEN_LAT
                    lng = self.config.SOUL_KITCHEN_LNG
                else:
                    self.result['meta']['status'] = 'FAIL'
                    self.result['meta']['error'] = 'geo lookup failed'
                    return self.result                

        ## generate admin code
        admin_code = self.generate_admin_code()
        admin_pin = self.generate_admin_code()
        user_pin = self.generate_admin_code()

        full_address = '%s %s, %s %s' % (street_1, city, state, zipcode)

        ## insert db object
        db_result = self.db.resource.insert({
                '_id':str(bson.ObjectId()),
                'last_updated':int(time.time()),
                'last_update_time_openhmis':int(time.time()),
                'resource_type':resource_type,
                'admin_code':str(admin_code),
                'admin_pin':str(admin_pin),
                'user_pin':str(user_pin),
                'va_status':va_status,
                'name_1':name_1,
                'name_2':name_2,
                'street_1':street_1,
                'street_2':street_2,
                'city':city,
                'state':state,
                'zipcode':zipcode,
                'location':[float(lat), float(lng)],
                'phone':phone,
                'url':url,
                'hours':hours,
                'notes':notes,
                'email_address':email,
                'beds':int(beds),
                'full_address':full_address,
                'beds_occupied':int(0),
                'beds_total':int(0),
                'hmis_program':'',
                'contact_name':'',
                'program_type':'',
                'program_key':'',
                'target_pop_a_name':''
        })
        
        ## email user
        pin_code = str(admin_code) + str(admin_pin)
        user_pin_code = str(admin_code) + str(user_pin)
        email_obj = Email(self.db, self.config)
        email_message = 'Welcome to Homeless Helper!\n\n'
        email_message = email_message + 'Your admin PIN code is: %s\n\n' % (pin_code)
        email_message = email_message + 'Update your info anytime at %s/admin\n\n' % (self.config.BASE_URL)
        
        if resource_type == 'shelter':
            email_message = email_message + 'Since you are a shelter, your volunteers are also able to update the real-time bed availability information.\n\n'
            email_message = email_message + 'Your shelter volunteer PIN code is: %s\n\n' % (user_pin_code)
        email_result = email_obj.send_text(email, self.config.EMAIL_FROM_ADDRESS, 'Welcome to Homeless Helper', email_message)
        
        ## build response
        resource_dict = {}
        resource_dict['resource_id'] = db_result
        self.result['response'] = resource_dict
        self.result['meta']['status'] = 'OK'
        return self.result


    def add_shelter_from_scrape(self, name_1, street_1, city, state, zipcode, phone, email, url, lat, lng):        
        
        ## check for duplicate
        resource_object = self.db.resource.find_one({'name_1':name_1, 'phone':phone})
        if resource_object is None:
                    
            ## generate admin code
            admin_code = self.generate_admin_code()
            admin_pin = self.generate_admin_code()
            user_pin = self.generate_admin_code()

            full_address = '%s %s, %s %s' % (street_1, city, state, zipcode)

            ## insert db object
            db_result = self.db.resource.insert({
                    '_id':str(bson.ObjectId()),
                    'last_updated':int(time.time()),
                    'last_update_time_openhmis':int(time.time()),
                    'resource_type':'shelter',
                    'admin_code':str(admin_code),
                    'admin_pin':str(admin_pin),
                    'user_pin':str(user_pin),
                    'va_status':'0',
                    'name_1':name_1,
                    'name_2':'',
                    'street_1':street_1,
                    'street_2':'',
                    'city':city,
                    'state':state,
                    'zipcode':zipcode,
                    'location':[float(lat), float(lng)],
                    'phone':phone,
                    'url':url,
                    'hours':'Call for hours',
                    'notes':'',
                    'email_address':email,
                    'beds':int(0),
                    'full_address':full_address,
                    'beds_occupied':int(0),
                    'beds_total':int(0),
                    'hmis_program':'',
                    'contact_name':'',
                    'program_type':'',
                    'program_key':'',
                    'target_pop_a_name':''
            })
            
            return db_result
        else:
            return 'DUPE'

    def add_medical_from_scrape(self, name_1, street_1, city, state, zipcode, phone, url, lat, lng):        
        
        ## check for duplicate
        resource_object = self.db.resource.find_one({'name_1':name_1, 'phone':phone})
        if resource_object is None:
                    
            ## generate admin code
            admin_code = self.generate_admin_code()
            admin_pin = self.generate_admin_code()
            user_pin = self.generate_admin_code()

            full_address = '%s %s, %s %s' % (street_1, city, state, zipcode)

            ## insert db object
            db_result = self.db.resource.insert({
                    '_id':str(bson.ObjectId()),
                    'last_updated':int(time.time()),
                    'last_update_time_openhmis':int(time.time()),
                    'resource_type':'medical',
                    'admin_code':str(admin_code),
                    'admin_pin':str(admin_pin),
                    'user_pin':str(user_pin),
                    'va_status':'0',
                    'name_1':name_1,
                    'name_2':'',
                    'street_1':street_1,
                    'street_2':'',
                    'city':city,
                    'state':state,
                    'zipcode':zipcode,
                    'location':[float(lat), float(lng)],
                    'phone':phone,
                    'url':url,
                    'hours':'Call for hours',
                    'notes':'',
                    'email_address':'',
                    'full_address':full_address,
                    'hmis_program':'',
                    'contact_name':'',
                    'program_type':'',
                    'program_key':'',
            })
            
            return db_result
        else:
            return 'DUPE'

    def add_food_from_scrape(self, name_1, street_1, city, state, zipcode, phone, lat, lng):        
        
        ## check for duplicate
        resource_object = self.db.resource.find_one({'name_1':name_1, 'phone':phone})
        if resource_object is None:
                    
            ## generate admin code
            admin_code = self.generate_admin_code()
            admin_pin = self.generate_admin_code()
            user_pin = self.generate_admin_code()

            full_address = '%s %s, %s %s' % (street_1, city, state, zipcode)

            ## insert db object
            db_result = self.db.resource.insert({
                    '_id':str(bson.ObjectId()),
                    'last_updated':int(time.time()),
                    'last_update_time_openhmis':int(time.time()),
                    'resource_type':'food',
                    'admin_code':str(admin_code),
                    'admin_pin':str(admin_pin),
                    'user_pin':str(user_pin),
                    'va_status':'0',
                    'name_1':name_1,
                    'name_2':'',
                    'street_1':street_1,
                    'street_2':'',
                    'city':city,
                    'state':state,
                    'zipcode':zipcode,
                    'location':[float(lat), float(lng)],
                    'phone':phone,
                    'url':'',
                    'hours':'Call for hours',
                    'notes':'',
                    'email_address':'',
                    'full_address':full_address,
                    'hmis_program':'',
                    'contact_name':'',
                    'program_type':'',
                    'program_key':'',
            })
            
            return db_result
        else:
            return 'DUPE'


    def new(self, admin_key, admin_code, resource_type, va_status, name_1, name_2, street_1, street_2, city, state, zipcode, lat, lng, phone, url, hours, notes, beds, email_address):
        self.result['meta']['method_name'] = '/resource/new'
        
        ## check admin key
        if self.config.ADMIN_KEY != admin_key:
            self.result['meta']['status'] = 'Authentication failed'
            return self.result

        ## check bed value
        if beds is None:
            beds = 0

        ## geo lookup
        if lat is None or lng is None:            
            try:
		logging.info('geo lookup line 330')
                address_query = '%s+%s+%s' % (street_1, city, state)
                google_url = 'https://maps.googleapis.com/maps/api/geocode/json'
                headers = {}
                params = {}
                params['address'] = address_query
                params['sensor'] = 'false'        
                google_url = google_url + '?' + urllib.urlencode(params)
                req = urllib2.Request(google_url, None, headers)
                response = json.load(urllib2.urlopen(req))
                web_request_result = json.load(urllib2.urlopen(google_url))
                lat = web_request_result['results'][0]['geometry']['location']['lat']
                lng = web_request_result['results'][0]['geometry']['location']['lng']
            except:
                if resource_type == 'hotline':
                    lat = self.config.SOUL_KITCHEN_LAT
                    lng = self.config.SOUL_KITCHEN_LNG
                else:
                    self.result['meta']['status'] = 'FAIL'
                    return self.result                

        ## insert db object
        db_result = self.db.resource.insert({
                '_id':str(bson.ObjectId()),
                'last_updated':int(time.time()),
                'resource_type':resource_type,
                'admin_code':admin_code,
                'va_status':va_status,
                'name_1':name_1,
                'name_2':name_2,
                'street_1':street_1,
                'street_2':street_2,
                'city':city,
                'state':state,
                'zipcode':zipcode,
                'location':[float(lat), float(lng)],
                'phone':phone,
                'url':url,
                'hours':hours,
                'notes':notes,
                'email_address':email_address,
                'beds':int(beds)
        })
        
        ## build response
        resource_dict = {}
        resource_dict['resource_id'] = db_result
        self.result['response'] = resource_dict
        self.result['meta']['status'] = 'OK'
        return self.result

    def public_api_new(self, token, resource_type, va_status, name_1, name_2, street_1, street_2, city, state, zipcode, lat, lng, phone, url, hours, notes):
        self.result['meta']['method_name'] = '/resource/new'
        
        ## check admin key
        if token != 'evrvrvrvrvrvrvrvr':
            self.result['meta']['status'] = 'Authentication failed'
            return self.result
        
        ## build response
        resource_dict = {}
        resource_dict['resource_id'] = '659384024'
        self.result['response'] = resource_dict
        self.result['meta']['status'] = 'OK'
        return self.result

    def new_shelter(self, admin_key, admin_code, resource_type, va_status, name_1, name_2, full_address, street_1, street_2, city, state, zipcode, lat, lng, phone, url, hours, notes, beds, beds_occupied, beds_total, hmis_program, contact_name, program_key, program_type, target_pop_a_name, update_time_stamp):
        self.result['meta']['method_name'] = '/resource/new_shelter'
        
        ## check admin key
        if self.config.ADMIN_KEY != admin_key:
            self.result['meta']['status'] = 'Authentication failed'
            return self.result

        ## insert db object
        db_result = self.db.resource.insert({
                '_id':str(bson.ObjectId()),
                'last_updated':int(time.time()),
                'last_update_time_openhmis':update_time_stamp,
                'resource_type':resource_type,
                'admin_code':str(admin_code),
                'va_status':va_status,
                'name_1':name_1,
                'name_2':name_2,
                'full_address':full_address,
                'street_1':street_1,
                'street_2':street_2,
                'city':city,
                'state':state,
                'zipcode':zipcode,
                'location':[float(lat), float(lng)],
                'phone':phone,
                'email_address':'',
                'url':url,
                'hours':hours,
                'notes':notes,
                'beds':int(beds),
                'beds_occupied':int(beds_occupied),
                'beds_total':int(beds_total),
                'hmis_program':hmis_program,
                'contact_name':contact_name,
                'program_type':program_type,
                'program_key':program_key,
                'target_pop_a_name':target_pop_a_name,
        })
        
        ## build response
        resource_dict = {}
        resource_dict['resource_id'] = db_result
        self.result['response'] = resource_dict
        self.result['meta']['status'] = 'OK'
        return self.result

    def request_shelter(self, resource_type, name, email, address, city, state, zipcode, hours, notes, phone, url, va_status):
        self.result['meta']['method_name'] = '/resource/request_shelter'


        ## send email to admin
        email_obj = Email(self.db, self.config)
        email_message = 'Resource type: %s\nName: %s\nEmail: %s\nAddress: %s\nCity: %s\nState: %s\nZipcode: %s\nHours: %s\nNotes: %s\nPhone number: %s\nWeb site: %s\nVA Status: %s\n' % (resource_type, name, email, address, city, state, zipcode, hours, notes, phone, url, va_status)
        approval_url = '\n\n%s/api/resource/complete_register?admin_key=%s&resource_type=%s&name=%s&email=%s&address=%s&city=%s&state=%s&zipcode=%s&hours=%s&notes=%s&phone=%s&url=%s&va_status=%s' % (self.config.BASE_URL, self.config.ADMIN_KEY, resource_type, urllib.quote_plus(name), urllib.quote_plus(email), urllib.quote_plus(address), urllib.quote_plus(city), urllib.quote_plus(state), urllib.quote_plus(zipcode), urllib.quote_plus(hours), urllib.quote_plus(notes), urllib.quote_plus(phone), urllib.quote_plus(url), va_status)
        email_message = email_message + approval_url
        email_result = email_obj.send_text(self.config.EMAIL_FROM_ADDRESS, self.config.EMAIL_FROM_ADDRESS, 'HH -- New Resource!', email_message)
                        
        ## build response
        self.result['meta']['status'] = 'OK'
        return self.result

    def get(self, resource_id):
        self.result['meta']['method_name'] = '/resource/get'

        ## query db
        resource_object = self.db.resource.find_one({'_id':resource_id})
        if resource_object is None:
            self.result['meta']['status'] = 'Resource does not exist in database'
            return self.result
        
        ## remove the admin_code from results
        resource_object['admin_code'] = None

        ## build response
        self.result['response'] = resource_object
        self.result['meta']['status'] = 'OK'
        return self.result

    def public_api_get(self, resource_id):
        self.result['meta']['method_name'] = '/resource/get'

        ## query db
        resource_object = self.db.resource.find_one({'_id':resource_id})
        if resource_object is None:
            self.result['meta']['status'] = 'Resource does not exist in database'
            return self.result
        
        ## remove the admin_code from results
        resource_object['admin_code'] = None

        ## build response
        self.result['response'] = resource_object
        self.result['meta']['status'] = 'OK'
        return self.result

    def list(self, kind, lat, lng, radius):
        self.result['meta']['method_name'] = '/resource/list'
	logging.info('Line 496')	
        if kind != 'hotline':
            if radius is None: 
                radius = 2000
            else:
                radius = int(radius)
            
            radius = float(radius) * 1.609
            self.db.resource.ensure_index([("location", pymongo.GEO2D)])
            limit = 100
            db_results = self.db.resource.find({'location': {'$within':{'$center':[[float(lat),float(lng)],radius/100]}}, 'resource_type':kind})

            results_count = db_results.count()
            if results_count > limit:
                results_count = limit
        
            results_array = []
            for row in db_results:
                row['admin_code'] = None
                row['resource_id'] = str(row['_id'])

                ## get the distance
                try:
                    arc_value = self.distance_on_unit_sphere(float(lat), float(lng), row['location'][0], row['location'][1])
                    miles = arc_value * 3960
                    row['miles'] = miles

                    ## add row to results array
                    results_array.append(row)
                except:
                    pass

            ## sort array by distance
            results_array_sorted1 = sorted(results_array, key=lambda k: k['miles'])
            results_array_sorted = []
            counter = 0
            for x in results_array_sorted1:
                results_array_sorted.append(x)
                counter = counter + 1
                if counter > 45:
                    break
        else:

            limit = 100
            db_results = self.db.resource.find({'resource_type':kind})            
            results_count = db_results.count()
            if results_count > limit:
                results_count = limit
        
            results_array = []
            for row in db_results:
                row['admin_code'] = None
                row['resource_id'] = str(row['_id'])

                ## get the distance
                miles = 0
                row['miles'] = miles

                ## add row to results array
                results_array.append(row)

            results_array_sorted = sorted(results_array, key=lambda k: k['miles'])

        ## create response
        self.result['response'] = results_array_sorted
        self.result['meta']['status'] = 'OK'
        return self.result

    def add_bed(self, admin_code):
        self.result['meta']['method_name'] = '/resource/add_bed'

        ## split code
        code = admin_code[:4]
        pin = admin_code[-4:]

        ## query db
        resource_object = self.db.resource.find_one({'admin_code':code, 'admin_pin':pin})
        if resource_object is None:
            ## check for user pin
            resource_object2 = self.db.resource.find_one({'admin_code':code, 'user_pin':pin})            
            if resource_object2 is None:
                self.result['meta']['status'] = 'Invalid code'
                return self.result
            else:
                resource_object = resource_object2

        ## update bedcount
        db_results = self.db.resource.update(
                                {'_id':resource_object['_id']},
                                {'$inc':{'beds':1}})

        db_results = self.db.resource.update(
                                {'_id':resource_object['_id']},
                                {'$inc':{'beds_occupied':-1}})

        db_results = self.db.resource.update(
                        {
                            '_id':resource_object['_id']
                        },
                        {"$set":{
                            'last_updated':int(time.time())
                        }},
                        upsert=False)
        
        ## build response
        resource_object = self.db.resource.find_one({'admin_code':admin_code})
        self.result['response'] = resource_object
        self.result['meta']['status'] = 'OK'
        return self.result

    def del_bed(self, admin_code):
        self.result['meta']['method_name'] = '/resource/del_bed'

        ## split code
        code = admin_code[:4]
        pin = admin_code[-4:]

        ## query db
        resource_object = self.db.resource.find_one({'admin_code':code, 'admin_pin':pin})
        if resource_object is None:
            ## check for user pin
            resource_object2 = self.db.resource.find_one({'admin_code':code, 'user_pin':pin})            
            if resource_object2 is None:
                self.result['meta']['status'] = 'Invalid code'
                return self.result
            else:
                resource_object = resource_object2

        ## update bedcount
        db_results = self.db.resource.update(
                                {'_id':resource_object['_id']},
                                {'$inc':{'beds':-1}})

        db_results = self.db.resource.update(
                                {'_id':resource_object['_id']},
                                {'$inc':{'beds_occupied':1}})

        db_results = self.db.resource.update(
                        {
                            '_id':resource_object['_id']
                        },
                        {"$set":{
                            'last_updated':int(time.time())
                        }},
                        upsert=False)
        
        ## build response
        resource_object = self.db.resource.find_one({'admin_code':admin_code})
        self.result['response'] = resource_object
        self.result['meta']['status'] = 'OK'
        return self.result

    def update_bed(self, admin_code, number):
        self.result['meta']['method_name'] = '/resource/update_bed'

        ## split code
        code = admin_code[:4]
        pin = admin_code[-4:]

        ## query db
        resource_object = self.db.resource.find_one({'admin_code':code, 'admin_pin':pin})
        if resource_object is None:
            ## check for user pin
            resource_object2 = self.db.resource.find_one({'admin_code':code, 'user_pin':pin})            
            if resource_object2 is None:
                self.result['meta']['status'] = 'Invalid code'
                return self.result
            else:
                access_level = 'user'
        else:
            access_level = 'admin'
        
        ## update bedcount
        number = int(number)
        db_results = self.db.resource.update(
                        {
                            '_id':resource_object['_id']
                        },
                        {"$set":{
                            'beds':number,
                            'last_updated':int(time.time())
                        }},
                        upsert=False)

        ## build response
        resource_object = self.db.resource.find_one({'admin_code':admin_code})
        self.result['response'] = resource_object
        self.result['meta']['status'] = 'OK'
        return self.result

    def update_resource(self, admin_code, data):
        self.result['meta']['method_name'] = '/resource/update'

        ## split code
        code = admin_code[:4]
        pin = admin_code[-4:]

        ## query db
        resource_object = self.db.resource.find_one({'admin_code':code, 'admin_pin':pin})
        if resource_object is None:
                self.result['meta']['status'] = 'Invalid code'
                return self.result
        
        ## normalize shit
        full_address = '%s %s %s %s %s' % (data['street_1'], data['street_2'], data['city'], data['state'], data['zipcode'],)

        ## lookup geo
        geo_data = self.lookup_geocode_data(full_address)
        if geo_data is not False:
            db_results = self.db.resource.update(
                            {
                                '_id':resource_object['_id']
                            },
                            {"$set":{
                                'location':[float(geo_data['lat']), float(geo_data['lng'])],
                            }},
                            upsert=False)
        
        ## update
        db_results = self.db.resource.update(
                        {
                            '_id':resource_object['_id']
                        },
                        {"$set":{
                            'last_updated':int(time.time()),
                            'full_address':full_address,
                            'name_1':data['name_1'],
                            'name_2':data['name_2'],
                            'street_1':data['street_1'],
                            'street_2':data['street_2'],
                            'city':data['city'],
                            'state':data['state'],
                            'zipcode':data['zipcode'],
                            'phone':data['phone'],
                            'url':data['url'],
                            'hours':data['hours'],
                            'notes':data['notes'],
                            'va_status':int(data['va_status']),
                            'contact_name':data['contact_name'],
                            'email_address':data['email_address'],
                        }},
                        upsert=True)

        ## build response
        resource_object = self.db.resource.find_one({'admin_code':admin_code})
        self.result['response'] = resource_object
        self.result['meta']['status'] = 'OK'
        return self.result
                                
    def share(self, resource_id, kind, destination):
        self.result['meta']['method_name'] = '/resource/share'

        ## query db
        resource_object = self.db.resource.find_one({'_id':resource_id})
        if resource_object is None:
            self.result['meta']['status'] = 'Resource does not exist in database'
            return self.result
        
        ## remove the admin_code from results
        resource_object['admin_code'] = None

        if kind == 'auto':
            try:
                match_result = re.search('@', destination)
                if match_result is None:
                    kind = 'sms'
                else:
                    kind = 'email'
            except:
                send_result = False
                
        if kind == 'email':
            try:
                ## send email
                email_obj = Email(self.db, self.config)
                email_message = '%s - %s - %s - %s' % (resource_object['name_1'], resource_object['street_1'], resource_object['city'],  resource_object['phone'])
                email_result = email_obj.send_text(destination, self.config.EMAIL_FROM_ADDRESS, 'Homeless Helper Info', email_message)
                send_result = True
            except:
                send_result = False

        elif kind == 'sms':

            try:
                account = self.config.TWILIO_ACCOUNT
                token = self.config.TWILIO_TOKEN
                client = TwilioRestClient(account, token)
                email_message = '%s - %s - %s - %s' % (resource_object['name_1'], resource_object['street_1'], resource_object['city'],  resource_object['phone'])
                message = client.sms.messages.create(to=destination, from_=self.config.TWILIO_NUMBER, body=email_message)
                send_result = True
            except:
                send_result = False

        ## log it
        db_result = self.db.share_log.insert({
                '_id':str(bson.ObjectId()),
                'resource_id':resource_object['_id'],
                'datetime':int(time.time()),
                'kind':kind,
                'destination':destination,
        })
        
        ## build response
        self.result['response'] = str(send_result)
        self.result['meta']['status'] = 'OK'
        return self.result

    def voice_inbound(self, from_number):
        response = '''<?xml version="1.0" encoding="UTF-8"?>
        <Response>
            <Gather method="POST" numDigits="5" action="voice_zipcode">
                <Say voice="woman">Welcome to Homeless Helper!</Say>
                <Say voice="woman">To find a shelter, please enter a 5 digit zipcode.</Say>
            </Gather>
        </Response>'''
        return response

    def voice_zipcode(self, zipcode):        

        try:
            ## geo lookup
            address_query = str(zipcode)
            url = 'https://maps.googleapis.com/maps/api/geocode/json'
            headers = {}
            params = {}
            params['address'] = address_query
            params['sensor'] = 'false'
        
            url = url + '?' + urllib.urlencode(params)
            req = urllib2.Request(url, None, headers)
            response = json.load(urllib2.urlopen(req))

            web_request_result = json.load(urllib2.urlopen(url))
            lat = web_request_result['results'][0]['geometry']['location']['lat']
            lng = web_request_result['results'][0]['geometry']['location']['lng']



            kind = 'shelter'
            radius = 200
            radius = float(radius) * 1.609
            self.db.resource.ensure_index([("location", pymongo.GEO2D)])
            limit = 3
            db_results = self.db.resource.find({'location': {'$within':{'$center':[[float(lat),float(lng)],radius/100]}}, 'resource_type':kind}).limit(int(limit))

            if db_results.count() < 1:
                response = '''<?xml version="1.0" encoding="UTF-8"?>
                    <Response>
                        <Say voice="woman">No shelters were found.</Say>
                        <Say voice="woman">Thank you for using Homeless Helper.</Say>
                        <Say voice="woman">Goodbye</Say>
                        <Hangup/>
                    </Response>'''
                return response

            results_count = db_results.count()
            if results_count > limit:
                results_count = limit
            
            results_array = []
            for row in db_results:
                #if row['beds'] > 0:
                resource_object = row
                break

        except:
            response = '''<?xml version="1.0" encoding="UTF-8"?>
                <Response>
                    <Say voice="woman">No shelters were found.</Say>
                    <Say voice="woman">Thank you for using Homeless Helper.</Say>
                    <Say voice="woman">Goodbye</Say>
                    <Hangup/>
                </Response>'''
            return response

                    
        ## log it

        ## build response
        
        phone_number = ''
        for a_digit in resource_object['phone']:
            phone_number = phone_number + a_digit + ' '

        response = '''<?xml version="1.0" encoding="UTF-8"?>
            <Response>
                <Say voice="woman">The closest shelter to you is %s.</Say>
                <Say voice="woman">They have %s beds available.</Say>
                <Say voice="woman">Their phone number is %s.</Say>
                 <Say voice="woman">Repeat their phone number is %s.</Say>
                <Say voice="woman">Their address is %s in %s.</Say>
                <Say voice="woman">Thank you for using Homeless Helper.</Say>
                <Say voice="woman">Goodbye</Say>
                <Hangup/>
            </Response>''' % (resource_object['name_1'], resource_object['beds'], phone_number,phone_number ,resource_object['street_1'], resource_object['city'])
        return response

    def send_sms_message(self, to_number, content):
        try:
            account = self.config.TWILIO_ACCOUNT
            token = self.config.TWILIO_TOKEN
            client = TwilioRestClient(account, token)
            message = client.sms.messages.create(to=to_number, from_=self.config.TWILIO_NUMBER, body=content)
            send_result = True
        except:
            message = 'FAIL'
            send_result = False

        ## log it
        db_result = self.db.sms_log.insert({
                '_id':str(bson.ObjectId()),
                'datetime':int(time.time()),
                'from_number':to_number,
                'text_content':content,
                'response_content':str(message),
        })
        return send_result
        
    def sms_inbound(self, from_number, text_content):
        self.result['meta']['method_name'] = '/resource/sms_inbound'

        if from_number is None:
            ## build response
            self.result['meta']['status'] = 'ERROR'
            return self.result
        
        if text_content is None:
            self.send_sms_message(from_number, 'Where do you want to find a shelter? Send us an address or zipcode.')            
            self.result['meta']['status'] = 'OK'
            return self.result
                
        try:
            ## geo lookup
	    time.sleep(.5)	##Google rate limit   
            address_query = str(text_content)
            address_query = address_query
            url = 'https://maps.googleapis.com/maps/api/geocode/json'
            headers = {}
            params = {}
            params['address'] = address_query
            params['sensor'] = 'false'
        
            url = url + '?' + urllib.urlencode(params)
            req = urllib2.Request(url, None, headers)
            response = json.load(urllib2.urlopen(req))

            web_request_result = json.load(urllib2.urlopen(url))
            lat = web_request_result['results'][0]['geometry']['location']['lat']
            lng = web_request_result['results'][0]['geometry']['location']['lng']
            
            kind = 'shelter'
            radius = 200
            radius = float(radius) * 1.609
            self.db.resource.ensure_index([("location", pymongo.GEO2D)])
            limit = 3
            db_results = self.db.resource.find({'location': {'$within':{'$center':[[float(lat),float(lng)],radius/100]}}, 'resource_type':kind}).limit(int(limit))


            if db_results.count() < 1:
                self.send_sms_message(from_number, 'No shelters found nearby. Please try another location by sending us an address or zipcode.')            
                self.result['meta']['status'] = 'OK'
                return self.result
                

            results_count = db_results.count()
            if results_count > limit:
                results_count = limit
        
            results_array = []

            for row in db_results:
                #if row['beds'] > 0:
                resource_object = row
                break

        except:
            self.send_sms_message(from_number, 'No shelters found nearby. Please try another location by sending us an address or zipcode.')            
            self.result['meta']['status'] = 'OK'
            return self.result

        try:                    
            message = '%s - %s - %s - %s - Beds: %s' % (resource_object['name_1'], resource_object['street_1'], resource_object['city'],  resource_object['phone'], resource_object['beds'])
            self.send_sms_message(from_number, message)            
        except:
            self.send_sms_message(from_number, 'No shelters found nearby. Please try another location by sending us an address or zipcode.')            
            self.result['meta']['status'] = 'OK'
            return self.result


        self.result['meta']['status'] = 'OK'
        return self.result

    def request_apikey(self, name, email):
        self.result['meta']['method_name'] = '/resource/request_apikey'

        ## send email to admin
        email_obj = Email(self.db, self.config)
        email_message = '%s\n%s' % (name, email)
        email_result = email_obj.send_text(self.config.EMAIL_FROM_ADDRESS, self.config.EMAIL_FROM_ADDRESS, 'Homeless Helper - API Key Request!', email_message)
                        
        ## build response
        self.result['meta']['status'] = 'OK'
        return self.result

    def new_job(self, job_id, job_url, job_title, job_lat, job_lng):
                
        ## insert db object
        db_result = self.db.resource.update(
                {
                    'job_id':job_id
                },
                {
                    '_id':str(bson.ObjectId()),
                    'last_updated':int(time.time()),
                    'resource_type':'job',
                    'job_id':job_id,
                    'name_1':job_title,
                    'location':[float(job_lat), float(job_lng)],
                    'url':job_url
                },
                upsert=True)

        return True

    def new_job_post(self, title, description, address, city, state, zipcode, phone, job_url, email, opp_type):
        self.result['meta']['method_name'] = '/job/new'

        ## geo lookup
        try:
	    time.sleep(.5) ## max limit 2 request / seconds	
            address_query = '%s+%s+%s+%s' % (address, city, state, zipcode)
            google_url = 'https://maps.googleapis.com/maps/api/geocode/json'
            headers = {}
            params = {}
            params['address'] = address_query
            params['sensor'] = 'false'        
            google_url = google_url + '?' + urllib.urlencode(params)
            req = urllib2.Request(google_url, None, headers)
            response = json.load(urllib2.urlopen(req))
            web_request_result = json.load(urllib2.urlopen(google_url))
            lat = web_request_result['results'][0]['geometry']['location']['lat']
            lng = web_request_result['results'][0]['geometry']['location']['lng']
        except:
            lat = self.config.SOUL_KITCHEN_LAT
            lng = self.config.SOUL_KITCHEN_LNG
            '''
                self.result['meta']['status'] = 'FAIL'
                self.result['meta']['error'] = 'geo lookup failed'
                return self.result                
            '''

        full_address = '%s %s, %s %s' % (address, city, state, zipcode)

        ## insert db object
        db_result = self.db.resource.insert({
                    '_id':str(bson.ObjectId()),
                    'last_updated':int(time.time()),
                    'resource_type':'job_gig',
                    'title':title,
                    'description':description,
                    'location':[float(lat), float(lng)],
                    'address':address,
                    'city':city,
                    'state':state,
                    'zipcode':zipcode,
                    'url':job_url,
                    'email':email,
                    'phone':phone,
                    'opp_type':opp_type
        })
                
        ## build response
        resource_dict = {}
        resource_dict['resource_id'] = db_result
        self.result['response'] = resource_dict
        self.result['meta']['status'] = 'OK'
        return self.result
        


    def update_beds_auto_script(self, hmis_program, beds):
        print beds
                
        ## insert db object
        db_result = self.db.resource.update(
                {
                    'hmis_program':hmis_program
                },
                {"$set":{
                    'last_updated':int(time.time()),
                    'beds':int(beds)
                }},
                upsert=False)

        ## insert db object
        db_result = self.db.resource.update(
                {
                    'name_1':hmis_program
                },
                {"$set":{
                    'last_updated':int(time.time()),
                    'beds':int(beds)
                }},
                upsert=False)

        ## insert db object
        db_result = self.db.resource.update(
                {
                    'name_2':hmis_program
                },
                {"$set":{
                    'last_updated':int(time.time()),
                    'beds':int(beds)
                }},
                upsert=False)


        return True

    def check_if_shelter_exists(self, ProgramName):
        resource_object = self.db.resource.find_one({'name_1':ProgramName})
        if resource_object is None:
            return False
        else:
            return True

    def distance_on_unit_sphere(self, lat1, long1, lat2, long2):

        # Convert latitude and longitude to 
        # spherical coordinates in radians.
        degrees_to_radians = math.pi/180.0
        
        # phi = 90 - latitude
        phi1 = (90.0 - lat1)*degrees_to_radians
        phi2 = (90.0 - lat2)*degrees_to_radians
        
        # theta = longitude
        theta1 = long1*degrees_to_radians
        theta2 = long2*degrees_to_radians
        
        # Compute spherical distance from spherical coordinates.
        
        # For two locations in spherical coordinates 
        # (1, theta, phi) and (1, theta, phi)
        # cosine( arc length ) = 
        #    sin phi sin phi' cos(theta-theta') + cos phi cos phi'
        # distance = rho * arc length
    
        cos = (math.sin(phi1)*math.sin(phi2)*math.cos(theta1 - theta2) + 
               math.cos(phi1)*math.cos(phi2))
        arc = math.acos( cos )

        # Remember to multiply arc by the radius of the earth 
        # in your favorite set of units to get length.
        return arc
        
    def update_db_fields(self):
        results = self.db.resource.find()
        for row in results:
            pprint(row)
            update_result = self.db.resource.update(
                {
                    '_id':row['_id']
                },
                {"$set":{
                    'email_address':''
                }},
                upsert=True)
    
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
            
            

    def public_api_add_bed(self, token, resource_id):
        self.result['meta']['method_name'] = '/resource/add_bed'

        ## build response
        self.result['response'] = ''
        self.result['meta']['status'] = 'OK'
        return self.result

    def public_api_del_bed(self, token, resource_id):
        self.result['meta']['method_name'] = '/resource/add_bed'

        ## build response
        self.result['response'] = ''
        self.result['meta']['status'] = 'OK'
        return self.result

    def public_api_update_bed(self, token, resource_id, number):
        self.result['meta']['method_name'] = '/resource/add_bed'

        ## build response
        self.result['response'] = ''
        self.result['meta']['status'] = 'OK'
        return self.result
