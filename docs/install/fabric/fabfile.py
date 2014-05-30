from pprint import pprint
from boto import ec2

## fabric
import time
#from fabric.api import abort, cd, env, get, hide, hosts, local, prompt, put, require, roles, run, runs_once, settings, show, sudo, warn
from fabric.api import *
from fabric.contrib.files import *

## fabric recipes
from recipes.base import *
from recipes.mgmt import *
from recipes.web import *
from recipes.db import *

## ami details:
#   web app - Ubuntu 10.04
#   db - Ubuntu 12.04

AWS_ACCESS_KEY_ID = 'XXXX'
AWS_SECRET_ACCESS_KEY = 'XXXX'

## hosts

def app():
    env.user = 'XXXX'
    env.conftype = 'prod'
    env.project = 'homelesshelper'
    env.hosts = ['XXXX']

def db():
    env.user = 'XXXX'
    env.conftype = 'prod'
    env.project = 'homelesshelper'
    env.hosts = ['XXXX']
    
## recipes

def generic_bootstrap():  ## 10.04
    upgrade_packages()
    install_dev_packages()
    install_standard_packages()
    install_git()
    install_pip_and_virtualenv()


def db_bootstrap():         ## 12.04
    generic_bootstrap()
    update_packages()
    setup_time_syncing()
    install_mongodb()
    load_database()
    install_firewall_db()
    update_db_crontab()


def web_bootstrap():      ## 10.04
    generic_bootstrap()
    install_tornado()
    install_nginx()
    install_pymongo()
    install_bitly_python()
    install_py_imaging()
    install_tweepy()
    install_pyapns()
    install_xhtml2pdf()
    install_firewall_app()
    install_pycurl()
    install_pygeocoder()
    install_twilio_python()
    install_feedparser()
    install_lxml()
    update_ssl_certs()
    update_nginx_conf()
    update_web_crontab()

