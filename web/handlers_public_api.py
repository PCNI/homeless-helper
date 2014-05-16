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

class ResourceNew(BaseHandler):
    def post(self):
        token = self.get_argument('token', None)
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
        resource = Resource(self.db, config)
        self.write(resource.public_api_new(token, resource_type, va_status, name_1, name_2, street_1, street_2, city, state, zipcode, lat, lng, phone, url, hours, notes))

class ResourceGet(BaseHandler):
    def get(self):
        resource_id = self.get_argument('resource_id', None)
        resource = Resource(self.db, config)
        self.write(resource.public_api_get(resource_id))

class ResourceAddBed(BaseHandler):
    def post(self):
        token = self.get_argument('token', None)
        resource_id = self.get_argument('resource_id', None)
        resource = Resource(self.db, config)
        self.write(resource.public_api_add_bed(token, resource_id))

class ResourceDelBed(BaseHandler):
    def post(self):
        token = self.get_argument('token', None)
        resource_id = self.get_argument('resource_id', None)
        resource = Resource(self.db, config)
        self.write(resource.public_api_del_bed(token, resource_id))

class ResourceUpdateBed(BaseHandler):
    def post(self):
        token = self.get_argument('token', None)
        number = self.get_argument('number', None)
        resource_id = self.get_argument('resource_id', None)
        resource = Resource(self.db, config)
        self.write(resource.public_api_update_bed(token, resource_id, number))
