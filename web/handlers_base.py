import tornado.web

from HomelessHelper.config import Config
from HomelessHelper.database import DbPrimary
from HomelessHelper.system import System
from HomelessHelper.resource import Resource

config = Config()

class BaseHandler(tornado.web.RequestHandler): 
    @property

    def db(self):
        '''return database instance'''
        return self.application.db
       