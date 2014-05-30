import time
#from fabric.api import abort, cd, env, get, hide, hosts, local, prompt, put, require, roles, run, runs_once, settings, show, sudo, warn
from fabric.api import *
from fabric.contrib.files import *

def install_firewall_app():
  run('sudo apt-get install -y ufw')
  run('sudo ufw allow ssh/tcp')
  run('sudo ufw allow http/tcp')
  run('sudo ufw allow https/tcp')
  run('sudo ufw allow proto tcp from 127.0.0.1 to any port 2500')
  run('sudo ufw allow proto tcp from 127.0.0.1 to any port 2400')
  run('sudo ufw logging on')
  run('sudo ufw enable')
  run('sudo ufw status')

## nginx
def install_nginx():
    run('sudo apt-get -y install nginx')
    run('sudo chmod 777 -R /etc/nginx/sites-enabled')

def update_nginx_conf():
    put('configs/web/nginx.conf', '/etc/nginx/nginx.conf', use_sudo=True)
    put('configs/web/sites-available/homelesshelper.us', '/etc/nginx/sites-available/homelesshelper.us', use_sudo=True)
    with settings(warn_only=True):
        run('sudo rm /etc/nginx/sites-enabled/default')
        run('sudo ln -s /etc/nginx/sites-available/homelesshelper.us /etc/nginx/sites-enabled/homelesshelper.us')
    run('sudo /etc/init.d/nginx restart')
    
## Tornado Web Server
def install_tornado():
    with cd('/tmp/'):
        run('wget http://github.com/downloads/facebook/tornado/tornado-1.1.tar.gz')
        run('tar xvzf tornado-1.1.tar.gz')
    with cd('/tmp/tornado-1.1'):
        run('sudo python setup.py build')
        run('sudo python setup.py install')

## py mongo client
def install_pymongo():
    run('pip install -I pymongo==1.9')

## bit.ly python module
def install_bitly_python():
    run('sudo pip install -e git://github.com/bitly/bitly-api-python.git#egg=bitly_api')

## resizer
def install_py_imaging():
    run('sudo apt-get -y install python-imaging')
    
## tweepy
def install_tweepy():
    run('sudo easy_install tweepy')

## googlemaps
def install_googlemaps():
    run('sudo easy_install googlemaps')    

## pygeocoder
def install_pygeocoder():
    run('sudo pip install pygeocoder')    
    
## PyAPNS
def install_pyapns():
    run('sudo easy_install apns')
    
## xhtml2pdf
def install_xhtml2pdf():
    run('sudo pip install xhtml2pdf')
    
## twilio
def install_twilio_python():
    run('sudo pip install twilio')
    
## xlrd
def install_xlrd():
    run('sudo pip install xlrd')

## pycurl
def install_pycurl():
    run('apt-get install python-pycurl')

## feedparser
def install_feedparser():
    run('sudo pip install feedparser')

## lxml
def install_lxml():
    run('sudo apt-get -y install libxml2-dev libxslt-dev')
    run('sudo apt-get -y install python-lxml')

def update_web_crontab():
    put('configs/web/crontab', '/tmp/crontab')
    run('crontab -u root /tmp/crontab')
     
## code deployments
def push_code_homelesshelper():
    put('/tmp/homelesshelper.tar.gz', '/tmp', use_sudo=True)
    put('/development/homelesshelper/tools/deploy/installer.sh', '/tmp', use_sudo=True)
    run('chmod 755 /tmp/installer.sh')
    run('/tmp/installer.sh')
    
