import sys
from ConfigParser import SafeConfigParser

class Config:
    
    def __init__(self):
        self.current_env = sys.argv[2]
        self.config_file = sys.argv[3]
        
        ## database
        self.DB_HOST = ''
        self.DB_PORT = ''
        self.DB_NAME = ''

        ## system
        self.VERSION_API = ''
        self.VERSION_WEB = ''
        self.VERSION_IOS = ''
        
        ## web
        self.HTTP_COOKIE_SECRET = ''
        self.BASE_URL = ''
        self.BASE_DIR = ''

        self.FAQ_URL = ''
        self.TOS_URL = ''
        self.PRIVACY_URL = ''
        self.STATUS_URL = ''

        self.GOOGLE_ANALYTICS = ''

        self.APPLE_APP_STORE_URL = ''
        self.MOBILE_WEB_URL = ''

        ## admin
        self.ADMIN_KEY = ''

        ## user
        self.PW_HASH_SALT = ''
        
        ## email
        self.EMAIL_FROM_NAME = ''
        self.EMAIL_FROM_ADDRESS = ''

        ## aws
        self.AWS_ACCESS_KEY = ''
        self.AWS_SECRET_KEY = ''

        ## twilio
        self.TWILIO_ACCOUNT = ''
        self.TWILIO_TOKEN = ''
        self.TWILIO_NUMBER = ''

        ## soul kitchen
        self.SOUL_KITCHEN_LAT = ''
        self.SOUL_KITCHEN_LNG = ''

        ## bed data
        self.BED_DATA_URL = ''

        ## openhmis
        self.OPENHMIS_URL = ''
        
        self.readConfigFile()
        
    def readConfigFile(self):
        parser = SafeConfigParser()
        parser.read(self.config_file)
        
        ## database
        self.DB_HOST = parser.get(self.current_env, 'DB_HOST')
        self.DB_PORT = parser.get(self.current_env, 'DB_PORT')
        self.DB_NAME = parser.get(self.current_env, 'DB_NAME')

        ## system
        self.VERSION_API = parser.get(self.current_env, 'VERSION_API')
        self.VERSION_WEB = parser.get(self.current_env, 'VERSION_WEB')
        self.VERSION_IOS = parser.get(self.current_env, 'VERSION_IOS')

        ## web
        self.HTTP_COOKIE_SECRET = parser.get(self.current_env, 'HTTP_COOKIE_SECRET')
        self.BASE_URL = parser.get(self.current_env, 'BASE_URL')
        self.BASE_DIR = parser.get(self.current_env, 'BASE_DIR')


        self.FAQ_URL = parser.get(self.current_env, 'FAQ_URL')
        self.TOS_URL = parser.get(self.current_env, 'TOS_URL')
        self.PRIVACY_URL = parser.get(self.current_env, 'PRIVACY_URL')
        self.STATUS_URL = parser.get(self.current_env, 'STATUS_URL')

        self.GOOGLE_ANALYTICS = parser.get(self.current_env, 'GOOGLE_ANALYTICS')

        self.APPLE_APP_STORE_URL = parser.get(self.current_env, 'APPLE_APP_STORE_URL')
        self.MOBILE_WEB_URL = parser.get(self.current_env, 'MOBILE_WEB_URL')

        ## admin
        self.ADMIN_KEY = parser.get(self.current_env, 'ADMIN_KEY')

        ## user
        self.PW_HASH_SALT = parser.get(self.current_env, 'PW_HASH_SALT')

        ## email
        self.EMAIL_FROM_NAME = parser.get(self.current_env, 'EMAIL_FROM_NAME')
        self.EMAIL_FROM_ADDRESS = parser.get(self.current_env, 'EMAIL_FROM_ADDRESS')

        ## aws
        self.AWS_ACCESS_KEY = parser.get(self.current_env, 'AWS_ACCESS_KEY')
        self.AWS_SECRET_KEY = parser.get(self.current_env, 'AWS_SECRET_KEY')

        ## twilio
        self.TWILIO_ACCOUNT = parser.get(self.current_env, 'TWILIO_ACCOUNT')
        self.TWILIO_TOKEN = parser.get(self.current_env, 'TWILIO_TOKEN')
        self.TWILIO_NUMBER = parser.get(self.current_env, 'TWILIO_NUMBER')

        ## soul kitchen
        self.SOUL_KITCHEN_LAT = parser.get(self.current_env, 'SOUL_KITCHEN_LAT')
        self.SOUL_KITCHEN_LNG = parser.get(self.current_env, 'SOUL_KITCHEN_LNG')

        ## bed data
        self.BED_DATA_URL = parser.get(self.current_env, 'BED_DATA_URL')

        ## openhmis
        self.OPENHMIS_URL = parser.get(self.current_env, 'OPENHMIS_URL')
        