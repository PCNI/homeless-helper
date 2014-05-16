#!/usr/bin/env python

import sys
import datetime
import urllib
import urllib2
from pprint import pprint

import pymongo
import json
import bson 

import tornado.auth
import tornado.escape
import tornado.httpserver
import tornado.ioloop
import tornado.options
import tornado.web
import tornado.template
from tornado.options import define, options

## handlers
import handlers_base
BaseHandler = handlers_base.BaseHandler
import handlers_api
import handlers_public_api
import handlers_web
import handlers_mobile

## homeless
from HomelessHelper.config import Config
from HomelessHelper.database import DbPrimary
from HomelessHelper.system import System
from HomelessHelper.resource import Resource

## config
PORT = int(sys.argv[1])
config = Config()

class Application(tornado.web.Application):
    def __init__(self):

        handlers = [
        
            ### web ###
            (r'/static/(.*)', tornado.web.StaticFileHandler, {'path':'ui/assets'}),
            (r'/', handlers_web.MainHandler),
            #(r'/developer', handlers_web.Developer),
            #(r'/developer/register', handlers_web.DeveloperRegister),
            (r'/tos', handlers_web.Terms),
            (r'/privacy', handlers_web.Privacy),
            (r'/faq', handlers_web.Faq),
            (r'/about', handlers_web.About),
            (r'/admin', handlers_web.Admin),
            (r'/admin/update', handlers_web.AdminUpdate),
            (r'/resources', handlers_web.Resources),
            (r'/resource_profile', handlers_web.ResourceProfile),
            (r'/shelter/register', handlers_web.ShelterRegister),
            (r'/geo_failed', handlers_web.GeoFailed),
            (r'/job/new', handlers_web.JobNew),

            (r'/add_shelter_from_scrape', handlers_web.ShelterScrape),
            (r'/add_medical_from_scrape', handlers_web.MedicalScrape),
            (r'/add_food_from_scrape', handlers_web.FoodScrape),
            
            ### mobile web app ###
            (r'/mobile', handlers_mobile.HomeHandler),
            (r'/mobile/', handlers_mobile.HomeHandler),
            (r'/mobile/resources', handlers_mobile.ResourcesHandler),
            (r'/mobile/resource_profile', handlers_mobile.ResourceProfileHandler),
            (r'/mobile/admin', handlers_mobile.AdminHandler),
            (r'/mobile/admin/update', handlers_mobile.AdminUpdate),
            (r'/mobile/shelter/register', handlers_mobile.ShelterRegisterHandler),
            (r'/mobile/geo_failed', handlers_mobile.GeoFailed),
            (r'/mobile/geo_search', handlers_mobile.GeoSearch),
            (r'/mobile/job/new', handlers_mobile.JobNew),


            ## outreach
            (r'/outreach', handlers_web.OutreachClient),
            (r'/outreach/client/get', handlers_web.OutreachClientGet),
            (r'/outreach/client/add', handlers_web.OutreachClientAdd),

            (r'/mobile/outreach', handlers_mobile.OutreachClient),
            (r'/mobile/outreach/client/get', handlers_mobile.OutreachClientGet),
            (r'/mobile/outreach/client/add', handlers_mobile.OutreachClientAdd),


            ### ios webviews ###
            (r'/ios/admin', handlers_web.IOSAdminHandler),
            (r'/ios/admin/update', handlers_web.IOSAdminUpdateHandler),
            (r'/ios/shelter/register', handlers_web.IOSShelterRegister),
            (r'/ios/job/new', handlers_web.IOSJobNew),
            

            ### api ###

            ## system
            (r'/api/system/health', handlers_api.SystemHealth),
            (r'/api/system/version', handlers_api.SystemVersion),

            ## loader.io verify
            (r'/loaderio-47d4f83df4ea3e5f2296b2e070f190c8.txt', handlers_api.LoaderIO),            

            ## external data leechers
            (r'/api/tools/update_shelters', handlers_api.ToolsUpdateShelters),
            (r'/api/tools/update_beds', handlers_api.ToolsUpdateBeds),
            (r'/api/tools/update_jobs', handlers_api.ToolsUpdateJobs),

            ## resources
            (r'/api/resource/verify_admin', handlers_api.ResourceVerifyAdmin),
            (r'/api/resource/new', handlers_api.ResourceNew),
            (r'/api/resource/new_shelter', handlers_api.ResourceNewShelter),
            (r'/api/resource/get', handlers_api.ResourceGet),
            (r'/api/resource/list', handlers_api.ResourceList),
            (r'/api/resource/add_bed', handlers_api.ResourceAddBed),
            (r'/api/resource/del_bed', handlers_api.ResourceDelBed),
            (r'/api/resource/update_bed', handlers_api.ResourceUpdateBed),
            (r'/api/resource/share', handlers_api.ResourceShare),
            (r'/api/resource/sms_inbound', handlers_api.ResourceSMSInbound),
            (r'/api/resource/voice_inbound', handlers_api.ResourceVoiceInbound),
            (r'/api/resource/voice_zipcode', handlers_api.ResourceVoiceZipcode),
            (r'/api/resource/request_shelter', handlers_api.ResourceRequestShelter),
            (r'/api/resource/request_apikey', handlers_api.ResourceRequestAPIKey),
            (r'/api/resource/complete_register', handlers_api.ResourceCompleteRegister),
    
            ## google
            (r'/api/google_geo/address_search', handlers_api.GoogleGeoAddressSearch),


            ## public api
            (r'/api/1/system/health', handlers_public_api.SystemHealth),
            (r'/api/1/system/version', handlers_public_api.SystemVersion),

            (r'/api/1/resource/new', handlers_public_api.ResourceNew),
            (r'/api/1/resource/get', handlers_public_api.ResourceGet),
            (r'/api/1/resource/bed/add', handlers_public_api.ResourceAddBed),
            (r'/api/1/resource/bed/subtract', handlers_public_api.ResourceDelBed),
            (r'/api/1/resource/bed/update', handlers_public_api.ResourceUpdateBed),    
            
        ]
        
        settings = dict(
            cookie_secret=config.HTTP_COOKIE_SECRET,
            xheaders=True
        )
        
        tornado.web.Application.__init__(self, handlers, **settings)
        
        ## establish database connection
        dbPrimary = DbPrimary()
        self.db = dbPrimary.db

        ## create template loader
        loader = tornado.template.Loader(config.BASE_DIR + 'ui/templates')
        self.loader = loader

        static_kwargs = {}
        static_kwargs['title'] = 'Homeless Helper'
        static_kwargs['url'] = config.BASE_URL
        self.static_kwargs = static_kwargs

def main():
    http_server = tornado.httpserver.HTTPServer(Application(), xheaders=True)
    http_server.listen(PORT)
    tornado.ioloop.IOLoop.instance().start()        

if __name__ == '__main__':
    main()
    