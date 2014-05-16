import time
import bson
import json
import urllib
import urllib2
import string
import types


class GoogleGeo():
    
    def __init__(self, db, config):
        self.db = db
        self.config = config
        self.result = {'meta':{'method_name':'', 'status':''},'response':{}}
    
    def address_search(self, query):
        self.result['meta']['method_name'] = '/google_geo/address_search'

        url = 'https://maps.googleapis.com/maps/api/geocode/json'
        headers = {}
        params = {}
        params['address'] = query
        params['sensor'] = 'false'
        
        url = url + '?' + urllib.urlencode(params)
        req = urllib2.Request(url, None, headers)
        response = json.load(urllib2.urlopen(req))


        try:
            web_request_result = json.load(urllib2.urlopen(url))
        except:
            self.result['meta']['status'] = 'Google API connection failed'
            return self.result
 
        self.result['meta']['status'] = 'OK'
        self.result['response'] = web_request_result['results']
        return self.result            
        