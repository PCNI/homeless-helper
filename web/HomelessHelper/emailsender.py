import string
import json
import urllib
import urllib2
from pprint import pprint

import smtplib
from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText

import boto
from boto.ses import SESConnection

class Email:
   
    def __init__(self, db, config):
        self.db = db
        self.config = config
        self.result = {'meta':{'method_name':'', 'status':''},'response':{}}
     
    def send_text(self, to_address, from_address, subject, body):
        ## SES
        try:
            ses = SESConnection(self.config.AWS_ACCESS_KEY, self.config.AWS_SECRET_KEY)
            result = ses.send_email(from_address, subject, body, to_address)
            return True
        except:
            return False