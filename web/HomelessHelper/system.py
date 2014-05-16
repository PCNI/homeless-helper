import time
import bson
import json
import urllib
import urllib2
import string

class System():
    
    def __init__(self, db, config):
        self.db = db
        self.config = config
        self.result = {'meta':{'method_name':'', 'status':''},'response':{}}

    def health(self):
        self.result['meta']['method_name'] = '/system/health'        
        self.result['meta']['status'] = 'OK'
        return self.result
        
    def version(self):
        self.result['meta']['method_name'] = '/system/version'        
        self.result['meta']['status'] = 'OK'

        version_dict = {}
        version_dict['api'] = self.config.VERSION_API
        version_dict['web'] = self.config.VERSION_WEB
        version_dict['ios'] = self.config.VERSION_IOS
        self.result['response'] = version_dict
        return self.result
