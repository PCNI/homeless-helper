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
import random

from lxml import etree, objectify

from pprint import pprint

import pymongo
from pymongo import Connection
from pymongo.son import SON

from emailsender import Email

class Outreach():
    
    def __init__(self, db, config):
        self.db = db
        self.config = config
        self.result = {'meta':{'method_name':'', 'status':''},'response':{}}

    def client_get(self, username, password, client_id):
        self.result['meta']['method_name'] = '/outreach/client/get'

        url = 'http://open-ciss.appspot.com/client/get'
        headers = {}
        params = {}
        params['id'] = client_id
        url = url + '?' + urllib.urlencode(params)
        req = urllib2.Request(url, None, headers)

        base64string = base64.encodestring('%s:%s' % (username, password)).replace('\n', '')
        req.add_header("Authorization", "Basic %s" % base64string)           
        
        try: 
            response = urllib2.urlopen(req)
        except urllib2.HTTPError, e:
            self.result['meta']['status'] = 'ERROR'
            return self.result
        except urllib2.URLError, e:
            self.result['meta']['status'] = 'ERROR'
            return self.result
        except httplib.HTTPException, e:
            self.result['meta']['status'] = 'ERROR'
            return self.result
        except Exception:
            self.result['meta']['status'] = 'ERROR'
            return self.result

        ## parse client data
        person = {}
        xml_string = str(response.read())
        root = objectify.fromstring(xml_string)
        for e in root.getchildren():

            ## date of birth
            if str(e.tag) == '{http://www.hmis.info/schema/3_0/HUD_HMIS.xsd}DateOfBirth':
                for f in e.getchildren():
                    person['dob'] = f.text

            ## ethnicity
            if str(e.tag) == '{http://www.hmis.info/schema/3_0/HUD_HMIS.xsd}Ethnicity':
                for f in e.getchildren():
                    person['ethnicity'] = f.text

            ## gender
            if str(e.tag) == '{http://www.hmis.info/schema/3_0/HUD_HMIS.xsd}Gender':
                for f in e.getchildren():
                    person['gender'] = f.text

            ## legal first name
            if str(e.tag) == '{http://www.hmis.info/schema/3_0/HUD_HMIS.xsd}LegalFirstName':
                for f in e.getchildren():
                    person['name_first'] = f.text

            ## legal last name
            if str(e.tag) == '{http://www.hmis.info/schema/3_0/HUD_HMIS.xsd}LegalLastName':
                for f in e.getchildren():
                    person['name_last'] = f.text

            ## legal middle name
            if str(e.tag) == '{http://www.hmis.info/schema/3_0/HUD_HMIS.xsd}LegalMiddleName':
                for f in e.getchildren():
                    person['name_middle'] = f.text

            ## race
            if str(e.tag) == '{http://www.hmis.info/schema/3_0/HUD_HMIS.xsd}Race':
                for f in e.getchildren():
                    person['race'] = f.text

            
        ## build response
        self.result['response'] = person
        self.result['meta']['status'] = 'OK'
        return self.result

    def client_add(self, username, password, data):
        self.result['meta']['method_name'] = '/outreach/client/add'

        ## normalize input data
        chars = string.digits
        data['person_id'] = ''.join(random.choice(chars) for x in range(random.randint(5, 9)))   
            
            
        ## calculate and format date/times  ( format: 2011-05-27T18:51:58  )
        fdate = time.strftime("%Y-%m-%dT%H:%M:%S", time.gmtime())
        
        xml_template = '<?xml version=\'1.0\' encoding=\'UTF-8\'?><hmis:Person xmlns:hmis=\'http://www.hmis.info/schema/3_0/HUD_HMIS.xsd\'>'
        xml_template = xml_template + '<hmis:PersonID><hmis:IDNum>%s</hmis:IDNum></hmis:PersonID>' % (data['person_id'])
        xml_template = xml_template + '<hmis:DateOfBirth><hmis:Unhashed hmis:dateCollected=\'%s\' hmis:dataCollectionStage=\'2\'>%s</hmis:Unhashed></hmis:DateOfBirth>' % (fdate, data['dob'])
        xml_template = xml_template + '<hmis:Ethnicity><hmis:Unhashed hmis:dateCollected=\'%s\' hmis:dataCollectionStage=\'2\'>%s</hmis:Unhashed></hmis:Ethnicity>' % (fdate, data['ethnicity'])
        xml_template = xml_template + '<hmis:Gender><hmis:Unhashed hmis:dateCollected=\'%s\' hmis:dateEffective=\'%s\' hmis:dataCollectionStage=\'1\'>%s</hmis:Unhashed></hmis:Gender>' % (fdate, fdate, data['gender'])
        xml_template = xml_template + '<hmis:LegalFirstName><hmis:Unhashed hmis:dateCollected=\'%s\' hmis:dateEffective=\'%s\' hmis:dataCollectionStage=\'3\'>%s</hmis:Unhashed></hmis:LegalFirstName>' % (fdate, fdate, data['name_first'])
        xml_template = xml_template + '<hmis:LegalLastName><hmis:Unhashed hmis:dateCollected=\'%s\' hmis:dateEffective=\'%s\' hmis:dataCollectionStage=\'2\'>%s</hmis:Unhashed></hmis:LegalLastName>' % (fdate, fdate, data['name_last'])
        xml_template = xml_template + '<hmis:LegalMiddleName><hmis:Unhashed hmis:dateCollected=\'%s\' hmis:dateEffective=\'%s\' hmis:dataCollectionStage=\'3\'>%s</hmis:Unhashed></hmis:LegalMiddleName>' % (fdate, fdate, data['name_middle'])
        xml_template = xml_template + '</hmis:Person>'
        
        
        url = 'https://open-ciss.appspot.com/client/add'
        req = urllib2.Request(url=url, 
                      data=xml_template, 
                      headers={'Content-Type': 'application/xml'})

        base64string = base64.encodestring('%s:%s' % (username, password)).replace('\n', '')
        req.add_header("Authorization", "Basic %s" % base64string)           
        
        response = urllib2.urlopen(req)
        
        '''
        try: 
            response = urllib2.urlopen(req)
            pprint(response)
        except urllib2.HTTPError, e:
            self.result['meta']['status'] = 'ERROR'
            return self.result
        except urllib2.URLError, e:
            self.result['meta']['status'] = 'ERROR'
            return self.result
        except httplib.HTTPException, e:
            self.result['meta']['status'] = 'ERROR'
            return self.result
        except Exception:
            self.result['meta']['status'] = 'ERROR'
            return self.result
        '''

        client_id = str(response.read())

        ## build response
        self.result['response'] = client_id
        self.result['meta']['status'] = 'OK'
        pprint(self.result)
        return self.result
        

