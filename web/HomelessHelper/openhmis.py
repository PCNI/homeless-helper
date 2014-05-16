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
from operator import itemgetter
from pprint import pprint
import StringIO

class OpenHMIS():
    
    def __init__(self, db, config):
        self.db = db
        self.config = config
        self.result = {'meta':{'method_name':'', 'status':''},'response':{}}
        
    def get_shelters(self):
        meth = '/programList'
        url = self.config.OPENHMIS_URL + meth
        headers = {}
        params = {}
        url = url + '?' + urllib.urlencode(params)
        req = urllib2.Request(url, None, headers)
        response = json.load(urllib2.urlopen(req))
        return response['Programs']
        
    def get_program_info_by_id(self, program_key):
        meth = '/programInfoByID?id=%s' % (program_key)
        url = self.config.OPENHMIS_URL + meth
        headers = {}
        params = {}
        url = url + '?' + urllib.urlencode(params)
        req = urllib2.Request(url, None, headers)
        response = json.load(urllib2.urlopen(req))
        return response['ProgramRecord']

    def update_bed_units_occupied(self, program_key, beds_occupied):
        meth = '/bed_units/occupied/set'
        url = self.config.OPENHMIS_URL + meth
        headers = {}
        params = {'id':program_key, 'val':str(beds_occupied)}
        url = url + '?' + urllib.urlencode(params)
        req = urllib2.Request(url, None, headers)
        response = urllib2.urlopen(req)
        