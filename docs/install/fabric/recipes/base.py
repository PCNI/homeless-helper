import time
#from fabric.api import abort, cd, env, get, hide, hosts, local, prompt, put, require, roles, run, runs_once, settings, show, sudo, warn
from fabric.api import *
from fabric.contrib.files import *


## standard packages
def upgrade_system():
    run('sudo aptitude safe-upgrade')
    run('sudo init 6')

def update_packages():
    run('apt-get update')
    
def upgrade_packages():
    run('sudo apt-get -y update')
    run('sudo apt-get -y upgrade')
    
def install_dev_packages():
    run('sudo apt-get -y install gcc')
    run('sudo apt-get -y install make')
    run('sudo apt-get -y install build-essential linux-headers-`uname -r`')

def install_standard_packages():
    run('sudo apt-get -y install curl')
    run('sudo apt-get -y install socat')
    run('sudo apt-get -y install tsocks')
    run('sudo apt-get -y install mailutils')
    run('sudo apt-get -y install resolvconf')
    
## python
def install_pip_and_virtualenv():
    run('sudo apt-get -y install python-dev')
    run('sudo apt-get -y install python-setuptools')
    run('sudo easy_install pip')
    run('sudo pip install virtualenv')

## beautifulsoup
def install_beautifulsoup():
    run('sudo apt-get -y install python-beautifulsoup')
    
def remove_vsftpd():
    run('sudo apt-get -y remove vsftpd')

def install_git():
    run('sudo apt-get -y install git-core')
    
def get_uptime():
    run('uptime')
    
def setup_time_syncing():
  with settings(warn_only=True):  
    run('apt-get -y install ntp')
    put('configs/generic/ntp.conf', '/etc/ntp.conf')
    run('/etc/init.d/ntp reload')
    run('ntpq -pn')
