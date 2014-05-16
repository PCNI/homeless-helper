import os
import sys
import time
import random
import string
import json
import hashlib
import socket
import urllib
import urllib2
from pprint import pprint

import tornado.web

import handlers_base
BaseHandler = handlers_base.BaseHandler

import twilio.twiml

from HomelessHelper.config import Config
from HomelessHelper.database import DbPrimary
from HomelessHelper.system import System
from HomelessHelper.tools import Tools
from HomelessHelper.resource import Resource
from HomelessHelper.google_geo import GoogleGeo

config = Config()

## system

class SystemHealth(BaseHandler):
    def get(self):
        system = System(self.db, config)
        self.write(system.health())

class SystemVersion(BaseHandler):
    def get(self):
        system = System(self.db, config)
        self.write(system.version())

## loader.io (load testing)

class LoaderIO(BaseHandler):
    def get(self):
        self.write('loaderio-47d4f83df4ea3e5f2296b2e070f0c8')


## external data fetchers

class ToolsUpdateShelters(BaseHandler):
    def get(self):
        admin_key = self.get_argument('admin_key', None)
        tools = Tools(self.db, config)
        self.write(tools.update_shelters(admin_key))

class ToolsUpdateBeds(BaseHandler):
    def get(self):
        tools = Tools(self.db, config)
        self.write(tools.update_beds())

class ToolsUpdateJobs(BaseHandler):
    def get(self):
        tools = Tools(self.db, config)
        self.write(tools.update_jobs())

## resource 

class ResourceVerifyAdmin(BaseHandler):
    def post(self):
        admin_code = self.get_argument('admin_code', None)
        resource = Resource(self.db, config)
        self.write(resource.verify_admin(admin_code))

class ResourceNew(BaseHandler):
    def post(self):
        admin_key = self.get_argument('admin_key', None)
        admin_code = self.get_argument('admin_code', None)
        resource_type = self.get_argument('resource_type', None)
        va_status = self.get_argument('va_status', None)
        name_1 = self.get_argument('name_1', None)
        name_2 = self.get_argument('name_2', None)
        street_1 = self.get_argument('street_1', None)
        street_2 = self.get_argument('street_2', None)
        city = self.get_argument('city', None)
        state = self.get_argument('state', None)
        zipcode = self.get_argument('zipcode', None)
        lat = self.get_argument('lat', None)
        lng = self.get_argument('lng', None)
        phone = self.get_argument('phone', None)
        url = self.get_argument('url', None)
        hours = self.get_argument('hours', None)
        notes = self.get_argument('notes', None)
        beds = self.get_argument('beds', None)
        resource = Resource(self.db, config)
        self.write(resource.new(admin_key, admin_code, resource_type, va_status, name_1, name_2, street_1, street_2, city, state, zipcode, lat, lng, phone, url, hours, notes, beds))

class ResourceCompleteRegister(BaseHandler):
    def get(self):
        admin_key = self.get_argument('admin_key', None)
        resource_type = self.get_argument('resource_type', None)
        va_status = self.get_argument('va_status', '0')
        name_1 = self.get_argument('name', None)
        name_2 = self.get_argument('name_2', '')
        street_1 = self.get_argument('address', None)
        street_2 = self.get_argument('street_2', '')
        city = self.get_argument('city', None)
        state = self.get_argument('state', None)
        zipcode = self.get_argument('zipcode', None)
        phone = self.get_argument('phone', None)
        url = self.get_argument('url', None)
        email = self.get_argument('email', None)
        hours = self.get_argument('hours', 'Call for hours')
        notes = self.get_argument('notes', None)
        beds = self.get_argument('beds', 0)
        lat = self.get_argument('lat', None)
        lng = self.get_argument('lng', None)

        resource = Resource(self.db, config)
        self.write(resource.complete_register(admin_key, resource_type, va_status, name_1, name_2, street_1, street_2, city, state, zipcode, phone, email, url, hours, notes, beds, lat, lng))

class ResourceNewShelter(BaseHandler):
    def post(self):
        admin_key = self.get_argument('admin_key', None)
        admin_code = self.get_argument('admin_code', None)
        resource_type = self.get_argument('resource_type', None)
        va_status = self.get_argument('va_status', None)
        name_1 = self.get_argument('name_1', None)
        name_2 = self.get_argument('name_2', None)
        street_1 = self.get_argument('street_1', None)
        street_2 = self.get_argument('street_2', None)
        city = self.get_argument('city', None)
        state = self.get_argument('state', None)
        zipcode = self.get_argument('zipcode', None)
        lat = self.get_argument('lat', None)
        lng = self.get_argument('lng', None)
        phone = self.get_argument('phone', None)
        url = self.get_argument('url', None)
        hours = self.get_argument('hours', None)
        notes = self.get_argument('notes', None)
        beds = self.get_argument('beds', None)
        hmis_program = self.get_argument('hmis_program', None)
        resource = Resource(self.db, config)
        self.write(resource.new_shelter(admin_key, admin_code, resource_type, va_status, name_1, name_2, street_1, street_2, city, state, zipcode, lat, lng, phone, url, hours, notes, beds, hmis_program))

class ResourceRequestShelter(BaseHandler):
    def post(self):
        name = self.get_argument('name', '')
        email = self.get_argument('email', '')
        address = self.get_argument('address', '')
        city = self.get_argument('city', '')
        state = self.get_argument('state', '')
        zipcode = self.get_argument('zipcode', '')
        hours = self.get_argument('hours', '')
        notes = self.get_argument('notes', '')
        resource = Resource(self.db, config)
        self.write(resource.request_shelter(name, email, address, city, state, zipcode, hours, notes))

class ResourceGet(BaseHandler):
    def get(self):
        resource_id = self.get_argument('resource_id', None)
        resource = Resource(self.db, config)
        self.write(resource.get(resource_id))

class ResourceList(BaseHandler):
    def get(self):
        kind = self.get_argument('kind', None)
        lat = self.get_argument('lat', None)
        lng = self.get_argument('lng', None)
        radius = self.get_argument('radius', None)
        resource = Resource(self.db, config)
        self.write(resource.list(kind, lat, lng, radius))

class ResourceAddBed(BaseHandler):
    def post(self):
        admin_code = self.get_argument('admin_code', None)
        resource = Resource(self.db, config)
        self.write(resource.add_bed(admin_code))

class ResourceDelBed(BaseHandler):
    def post(self):
        admin_code = self.get_argument('admin_code', None)
        resource = Resource(self.db, config)
        self.write(resource.del_bed(admin_code))

class ResourceUpdateBed(BaseHandler):
    def post(self):
        admin_code = self.get_argument('admin_code', None)
        number = self.get_argument('number', None)
        resource = Resource(self.db, config)
        self.write(resource.update_bed(admin_code, number))

class ResourceShare(BaseHandler):
    def post(self):
        resource_id = self.get_argument('resource_id', None)
        kind = self.get_argument('kind', None)
        destination = self.get_argument('destination', None)
        resource = Resource(self.db, config)
        self.write(resource.share(resource_id, kind, destination))

class ResourceSMSInbound(BaseHandler):
    def post(self):
        resp = twilio.twiml.Response()
        from_number = self.get_argument('From', None)
        text_content = self.get_argument('Body', None)
        resource = Resource(self.db, config)
        self.write(resource.sms_inbound(from_number, text_content))

class ResourceVoiceInbound(BaseHandler):
    def post(self):
        resp = twilio.twiml.Response()
        from_number = self.get_argument('From', None)
        #text_content = self.get_argument('Body', None)
        resource = Resource(self.db, config)
        self.write(resource.voice_inbound(from_number))

class ResourceVoiceZipcode(BaseHandler):
    def post(self):
        resp = twilio.twiml.Response()
        zipcode = self.get_argument('Digits', None)
        zipcode = zipcode.replace('#', '').replace('*', '')[:5]
        resource = Resource(self.db, config)
        self.write(resource.voice_zipcode(zipcode))

class ResourceRequestAPIKey(BaseHandler):
    def post(self):
        name = self.get_argument('name', None)
        email = self.get_argument('email', None)
        resource = Resource(self.db, config)
        self.write(resource.request_apikey(name, email))

## google
    
class GoogleGeoAddressSearch(BaseHandler):
    def get(self):
        query = self.get_argument('query', None)
        google = GoogleGeo(self.db, config)
        self.write(google.address_search(query))
