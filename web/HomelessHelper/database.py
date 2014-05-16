import pymongo
from pymongo import Connection
from pymongo.son import SON

from config import Config

class DbPrimary:

    def __init__(self):
        self.config = Config()
        connection = Connection(self.config.DB_HOST, int(self.config.DB_PORT))
        self.db = connection[self.config.DB_NAME]

        ## check/create indexes
        self.db.resource.ensure_index([("location", pymongo.GEO2D)])

    def db(self):
        return self.db
