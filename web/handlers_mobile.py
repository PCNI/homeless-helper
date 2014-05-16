import time
from datetime import datetime, date
import tornado.web
from pprint import pprint
from pygeocoder import Geocoder

import urllib
import urllib2
import base64
import string
import re
import math

from lxml import etree, objectify

from pprint import pprint


import handlers_base
BaseHandler = handlers_base.BaseHandler

from HomelessHelper.config import Config
from HomelessHelper.database import DbPrimary
from HomelessHelper.system import System
from HomelessHelper.resource import Resource
from HomelessHelper.google_geo import GoogleGeo
from HomelessHelper.outreach import Outreach

config = Config()

class HomeHandler(BaseHandler):
    def get(self):        
        self.get_current_user()
        kwargs = dict(self.application.static_kwargs)
        kwargs['page_name'] = 'home'
        kwargs['config'] = config
        self.write(self.application.loader.load('mobile/home.html').generate(**kwargs))

class JobNew(BaseHandler):
    def get(self):        
        self.get_current_user()
        kwargs = dict(self.application.static_kwargs)
        kwargs['page_name'] = 'mobile_job_new'
        kwargs['config'] = config
        kwargs['done'] = self.get_argument('done', None)
        kwargs['job_id'] = self.get_argument('job_id', None)        
        self.write(self.application.loader.load('mobile/job_new.html').generate(**kwargs))

    def post(self):
        title = self.get_argument('title', None)
        description = self.get_argument('description', '')
        address = self.get_argument('address', '')
        city = self.get_argument('city', '')
        state = self.get_argument('state', '')
        zipcode = self.get_argument('zipcode', '')
        phone = self.get_argument('phone', '')
        url = self.get_argument('url', '')
        email = self.get_argument('email', '')
        opp_type = self.get_argument('opp_type', '')
        
        resource = Resource(self.db, config)
        request_result = resource.new_job_post(title, description, address, city, state, zipcode, phone, url, email, opp_type)
        if request_result['meta']['status'] == 'ERROR':
            self.get_current_user()
            kwargs = dict(self.application.static_kwargs)
            kwargs['page_name'] = 'mobile_job_new'
            kwargs['config'] = config
            kwargs['done'] = 0
            kwargs['job_id'] = None
            self.write(self.application.loader.load('mobile/job_new.html').generate(**kwargs))
        else:
            next_url = '/mobile/job/new?done=1&job_id=%s' % (request_result['response']['resource_id'])
            self.redirect(next_url)
            
class ResourcesHandler(BaseHandler):
    def get(self):        
        self.get_current_user()
        kwargs = dict(self.application.static_kwargs)
        kind = self.get_argument('kind')
        kwargs['page_name'] = kind
        kwargs['config'] = config
        query = self.get_argument('query', None)
        radius = self.get_argument('radius', None)
        if query is None or query == '':
            lat = self.get_argument('lat', None)
            lng = self.get_argument('lng', None)
            if lat is None or lng is None:
                lat = '40.050137'
                lng = '-74.221251'
            if radius is None:
                radius = '100'
        else:
            query = self.get_argument('query', None)
            google = GoogleGeo(self.db, config)
            query_results = google.address_search(query)
            query_array = query_results['response']
            
            ## get 1st result
            lat = query_array[0]['geometry']['location']['lat']
            lng = query_array[0]['geometry']['location']['lng']
            if radius is None:
                radius = '100'
                
        geo_results = Geocoder.reverse_geocode(float(lat), float(lng))
        kwargs['full_address'] = geo_results[0]

        resource = Resource(self.db, config)
        results = resource.list(kind, lat, lng, radius)
        kwargs['resource_objects'] = results['response']
        if int(len(results['response'])) == 0:
            self.write(self.application.loader.load('mobile/resources_none.html').generate(**kwargs))
            return

        if kind == 'employment':
            jobs = resource.list('job', lat, lng, radius)
            kwargs['jobs'] = jobs['response']

            job_gig = resource.list('job_gig', lat, lng, radius)
            kwargs['job_gig'] = job_gig['response']
            
        self.write(self.application.loader.load('mobile/resources.html').generate(**kwargs))

class GeoFailed(BaseHandler):
    def get(self):
        self.get_current_user()
        kwargs = dict(self.application.static_kwargs)
        kwargs['page_name'] = 'Geolocation'
        kwargs['config'] = config
        self.write(self.application.loader.load('mobile/geo_failed.html').generate(**kwargs))

class GeoSearch(BaseHandler):
    def get(self):
        self.get_current_user()
        kwargs = dict(self.application.static_kwargs)
        kwargs['page_name'] = 'search'
        kwargs['config'] = config
        self.write(self.application.loader.load('mobile/geo_search.html').generate(**kwargs))

class ResourceProfileHandler(BaseHandler):
    def get(self):        
        self.get_current_user()
        kwargs = dict(self.application.static_kwargs)
        kwargs['page_name'] = 'shelter_profile'
        kwargs['config'] = config
        resource_id = self.get_argument('resource_id', None)        

        resource = Resource(self.db, config)
        results = resource.get(resource_id)
        kwargs['resource_object'] = results['response']

        self.write(self.application.loader.load('mobile/resource_profile.html').generate(**kwargs))

class AdminHandler(BaseHandler):
    def get(self):        
        self.get_current_user()
        kwargs = dict(self.application.static_kwargs)
        kwargs['page_name'] = 'mobile_admin'
        kwargs['config'] = config
        kwargs['access_level'] = None

        ## check for logout
        logout_value = self.get_argument('logout', None)
        if logout_value == '1':
            self.clear_cookie('admin_code')
            self.redirect('/mobile/admin')

        ## check admin code
        admin_code = self.get_argument('admin_code', None)
        if admin_code is None:
            admin_code = self.get_secure_cookie('admin_code')        

        if admin_code is None:
            kwargs['admin_status'] = False
            self.write(self.application.loader.load('mobile/admin.html').generate(**kwargs))
            return
            
        resource = Resource(self.db, config)
        results = resource.verify_admin(admin_code)
        if results['meta']['status'] == 'OK':
            kwargs['admin_status'] = True
            kwargs['access_level'] = results['access_level']
            kwargs['resource_object'] = results['response']
            self.set_secure_cookie('admin_code', admin_code)
        else:
            kwargs['admin_status'] = False
            kwargs['access_level'] = False

        ## bedcount        
        if kwargs['admin_status'] is True:
            addbed = self.get_argument('addbed', None)
            delbed = self.get_argument('delbed', None)

            if addbed == '1':
                resource = Resource(self.db, config)
                results2 = resource.add_bed(admin_code)

            if delbed == '1':
                resource = Resource(self.db, config)
                results2 = resource.del_bed(admin_code)

        resource = Resource(self.db, config)
        results = resource.verify_admin(admin_code)
        kwargs['resource_object'] = results['response']
                
        self.write(self.application.loader.load('mobile/admin.html').generate(**kwargs))

class AdminUpdate(BaseHandler):
    def get(self):        
        self.get_current_user()
        kwargs = dict(self.application.static_kwargs)
        kwargs['page_name'] = 'mobile/admin_update'
        kwargs['config'] = config
        kwargs['access_level'] = None

        ## check for logout
        logout_value = self.get_argument('logout', None)
        if logout_value == '1':
            self.clear_cookie('admin_code')
            self.redirect('/mobile/admin')

        ## check admin code
        admin_code = self.get_argument('admin_code', None)
        if admin_code is None:
            admin_code = self.get_secure_cookie('admin_code')        

        if admin_code is None:
            kwargs['admin_status'] = False
            self.write(self.application.loader.load('mobile/admin.html').generate(**kwargs))
            return
            
        resource = Resource(self.db, config)
        results = resource.verify_admin(admin_code)
        if results['meta']['status'] == 'OK':
            kwargs['admin_status'] = True
            kwargs['access_level'] = results['access_level']
            
            if results['response']['name_2'] is None: results['response']['name_2'] = ''
            if results['response']['street_2'] is None: results['response']['street_2'] = ''
            if results['response']['phone'] is None: results['response']['phone'] = ''
            if results['response']['url'] is None: results['response']['url'] = ''
            if results['response']['hours'] is None: results['response']['hours'] = ''
            if results['response']['notes'] is None: results['response']['notes'] = ''
            
            
            kwargs['resource_object'] = results['response']
            self.set_secure_cookie('admin_code', admin_code)
        else:
            kwargs['admin_status'] = False
            kwargs['access_level'] = results['access_level']
                
        self.write(self.application.loader.load('mobile/admin_update.html').generate(**kwargs))


    def post(self):
        self.get_current_user()
        kwargs = dict(self.application.static_kwargs)
        kwargs['page_name'] = 'mobile/admin_update'
        kwargs['config'] = config
        kwargs['access_level'] = None

        ## check admin code
        admin_code = self.get_argument('admin_code', None)
        if admin_code is None:
            admin_code = self.get_secure_cookie('admin_code')        

        if admin_code is None:
            kwargs['admin_status'] = False
            self.write(self.application.loader.load('mobile/admin.html').generate(**kwargs))
            return
            
        resource = Resource(self.db, config)
        results = resource.verify_admin(admin_code)
        if results['meta']['status'] == 'OK':
            kwargs['admin_status'] = True
            kwargs['access_level'] = results['access_level']
            kwargs['resource_object'] = results['response']
            self.set_secure_cookie('admin_code', admin_code)
        else:
            kwargs['admin_status'] = False
            kwargs['access_level'] = results['access_level']

        ## resource update        
        if kwargs['admin_status'] is True:
            input_data = {}
            input_data['name_1'] = self.get_argument('name_1', None)
            input_data['name_2'] = self.get_argument('name_2', None)
            input_data['street_1'] = self.get_argument('street_1', None)
            input_data['street_2'] = self.get_argument('street_2', None)
            input_data['city'] = self.get_argument('city', None)
            input_data['state'] = self.get_argument('state', None)
            input_data['zipcode'] = self.get_argument('zipcode', None)
            input_data['phone'] = self.get_argument('phone', None)
            input_data['url'] = self.get_argument('url', None)
            input_data['hours'] = self.get_argument('hours', None)
            input_data['notes'] = self.get_argument('notes', None)
            input_data['va_status'] = self.get_argument('va_status', None)
            input_data['contact_name'] = self.get_argument('contact_name', None)
            input_data['email_address'] = self.get_argument('email_address', None)

            resource = Resource(self.db, config)
            results = resource.update_resource(admin_code, input_data)
            self.redirect('/mobile/admin/update')

class ShelterRegisterHandler(BaseHandler):
    def get(self):        
        self.get_current_user()
        kwargs = dict(self.application.static_kwargs)
        kwargs['page_name'] = 'mobile_shelter_register'
        kwargs['config'] = config
        kwargs['done'] = self.get_argument('done', None)
        kwargs['resource_id'] = self.get_argument('resource_id', None)        
        self.write(self.application.loader.load('mobile/shelter_register.html').generate(**kwargs))

    def post(self):
        resource_type = self.get_argument('resource_type', '')
        name = self.get_argument('name', '')
        email = self.get_argument('email', '')
        address = self.get_argument('address', '')
        city = self.get_argument('city', '')
        state = self.get_argument('state', '')
        zipcode = self.get_argument('zipcode', '')
        hours = self.get_argument('hours', '')
        notes = self.get_argument('notes', '')
        phone = self.get_argument('phone', '')        
        url = self.get_argument('url', '')
        va_status = self.get_argument('va_status', '')
        
        resource = Resource(self.db, config)
        request_result = resource.request_shelter(resource_type, name, email, address, city, state, zipcode, hours, notes, phone, url, va_status)

        if request_result['meta']['status'] == 'ERROR':
            self.get_current_user()
            kwargs = dict(self.application.static_kwargs)
            kwargs['page_name'] = 'mobile_shelter_register'
            kwargs['config'] = config
            kwargs['done'] = 0
            kwargs['resource_id'] = None
            self.write(self.application.loader.load('mobile/shelter_register.html').generate(**kwargs))
        else:
            next_url = '/mobile/shelter/register?done=1'
            self.redirect(next_url)

## OUTREACH

class OutreachClient(BaseHandler):
    def get(self):
        
        username = self.get_secure_cookie('openhmis1')
        password = self.get_secure_cookie('openhmis2')

        kwargs = dict(self.application.static_kwargs)
        kwargs['page_name'] = 'outreach'
        kwargs['config'] = config
        kwargs['error'] = False
        
        outreach = Outreach(self.db, config)
        person = outreach.client_get(username, password, '6')
        
        if person['meta']['status'] != 'OK':
            kwargs['error'] = True

        self.write(self.application.loader.load('mobile/outreach_client.html').generate(**kwargs))

    def post(self):
        username = self.get_argument('username', '')
        password = self.get_argument('password', '')
        
        kwargs = dict(self.application.static_kwargs)
        kwargs['page_name'] = 'outreach'
        kwargs['config'] = config
        kwargs['error'] = False
        
        outreach = Outreach(self.db, config)
        person = outreach.client_get(username, password, '6')
        
        if person['meta']['status'] != 'OK':
            kwargs['error'] = True

        self.set_secure_cookie('openhmis1', username)
        self.set_secure_cookie('openhmis2', password)
        self.write(self.application.loader.load('mobile/outreach_client.html').generate(**kwargs))


class OutreachClientGet(BaseHandler):
    def get(self):

        username = self.get_secure_cookie('openhmis1')
        password = self.get_secure_cookie('openhmis2')

        kwargs = dict(self.application.static_kwargs)
        kwargs['page_name'] = 'mobile_outreach_client_get'
        kwargs['config'] = config
        kwargs['client_id'] = self.get_argument('client_id', '')
        kwargs['error'] = ''

        if kwargs['client_id'] == '':
            client_id = '6'        
        else:
            client_id = kwargs['client_id']

        outreach = Outreach(self.db, config)
        person = outreach.client_get(username, password, client_id)


        kwargs['error'] = person['meta']['status']

        try:
            kwargs['dob'] = person['response']['dob']
        except:
            kwargs['dob'] = ''

        try:
            kwargs['ethnicity'] = person['response']['ethnicity']
        except:
            kwargs['ethnicity'] = ''

        try:
            kwargs['gender'] = person['response']['gender']
        except:
            kwargs['gender'] = ''

        try:
            kwargs['name_first'] = person['response']['name_first']
        except:
            kwargs['name_first'] = ''

        try:
            kwargs['name_last'] = person['response']['name_last']
        except:
            kwargs['name_last'] = ''

        try:
            kwargs['name_middle'] = person['response']['name_middle']
        except:
            kwargs['name_middle'] = ''

        try:
            kwargs['race'] = person['response']['race']
        except:
            kwargs['race'] = ''
        
        if person['meta']['status'] != 'OK':
            kwargs['error'] = True

        self.write(self.application.loader.load('mobile/outreach_client_get.html').generate(**kwargs))
        
    def post(self):
        kwargs = dict(self.application.static_kwargs)
        kwargs['page_name'] = 'mobile_outreach_client_get'
        kwargs['config'] = config
        kwargs['client_id'] = ''
        kwargs['error'] = ''
        
        username = self.get_secure_cookie('openhmis1')
        password = self.get_secure_cookie('openhmis2')

        client_id = self.get_argument('client_id', None)
        outreach = Outreach(self.db, config)        

        kwargs['client_id'] = client_id
        
        person = outreach.client_get(username, password, client_id)

        if person['meta']['status'] != 'OK':
            kwargs['error'] = True
            self.write(self.application.loader.load('mobile/outreach_client_get.html').generate(**kwargs))

        kwargs['client_id'] = client_id
        kwargs['error'] = person['meta']['status']

        try:
            kwargs['dob'] = person['response']['dob']
        except:
            kwargs['dob'] = ''

        try:
            kwargs['ethnicity'] = person['response']['ethnicity']
        except:
            kwargs['ethnicity'] = ''

        try:
            kwargs['gender'] = person['response']['gender']
        except:
            kwargs['gender'] = ''

        try:
            kwargs['name_first'] = person['response']['name_first']
        except:
            kwargs['name_first'] = ''

        try:
            kwargs['name_last'] = person['response']['name_last']
        except:
            kwargs['name_last'] = ''

        try:
            kwargs['name_middle'] = person['response']['name_middle']
        except:
            kwargs['name_middle'] = ''

        try:
            kwargs['race'] = person['response']['race']
        except:
            kwargs['race'] = ''
            
        self.write(self.application.loader.load('mobile/outreach_client_get.html').generate(**kwargs))


class OutreachClientAdd(BaseHandler):
    def get(self):

        username = self.get_secure_cookie('openhmis1')
        password = self.get_secure_cookie('openhmis2')

        kwargs = dict(self.application.static_kwargs)
        kwargs['page_name'] = 'mobile_outreach_client_add'
        kwargs['config'] = config
        kwargs['client_id'] = self.get_argument('client_id', None)
        kwargs['error'] = ''
        client_id = '6'        

        outreach = Outreach(self.db, config)
        person = outreach.client_get(username, password, client_id)
        
        if person['meta']['status'] != 'OK':
            kwargs['error'] = True

        self.write(self.application.loader.load('mobile/outreach_client_add.html').generate(**kwargs))

    def post(self):
        username = self.get_secure_cookie('openhmis1')
        password = self.get_secure_cookie('openhmis2')

        kwargs = dict(self.application.static_kwargs)
        kwargs['page_name'] = 'mobile_outreach_client_add'
        kwargs['config'] = config
        kwargs['error'] = ''


        data = {}
        data['name_first'] = self.get_argument('name_first', None)
        data['name_middle'] = self.get_argument('name_middle', None)
        data['name_last'] = self.get_argument('name_last', None)
        data['dob'] = self.get_argument('dob', None)
        data['ethnicity'] = self.get_argument('ethnicity', None)
        data['gender'] = self.get_argument('gender', None)
        outreach = Outreach(self.db, config)
        response = outreach.client_add(username, password, data)
        if response['meta']['status'] != 'OK':
            kwargs['error'] = True
            print 'ERROR'
            pprint(response)
            self.redirect('/mobile/outreach/client/add')
            return
            
        url = '/mobile/outreach/client/get?client_id=%s' % (response['response'])
        self.redirect(url)
