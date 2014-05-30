import time
#from fabric.api import abort, cd, env, get, hide, hosts, local, prompt, put, require, roles, run, runs_once, settings, show, sudo, warn
from fabric.api import *
from fabric.contrib.files import *


def install_mongodb():
  run('apt-key adv --keyserver keyserver.ubuntu.com --recv 7F0CEB10')
  run('echo "deb http://downloads-distro.mongodb.org/repo/ubuntu-upstart dist 10gen" | tee /etc/apt/sources.list.d/10gen.list')
  run('apt-get update')
  run('apt-get -y install mongodb-10gen')
  put('configs/db/mongodb.conf', '/etc/mongodb.conf')
  run('service mongodb restart')

def load_database():
  run('mkdir -p /db_data/mongodb')   
  run('chown mongodb:mongodb -R /db_data/mongodb/') 
  run('service mongodb restart')

def install_firewall_db():
  run('sudo apt-get install -y ufw')
  run('sudo ufw allow ssh/tcp')
  run('sudo ufw allow proto tcp from XXXX to any port 27017')   ## app-01 public ip
  run('sudo ufw allow proto tcp from XXXX to any port 27017')   ## app-01 private ip
  run('sudo ufw logging on')
  run('sudo ufw enable')
  run('sudo ufw status')

def update_mongodb_config():
  put('configs/db/mongodb.conf', '/etc/mongodb.conf')
  run('service mongodb restart')

def update_db_crontab():
    put('configs/db/crontab', '/tmp/crontab')
    run('crontab -u root /tmp/crontab')
