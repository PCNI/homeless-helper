#!/bin/bash

/opt/homelesshelper/daemons/stop-all.sh
sudo rm -rf /opt/homelesshelper
sudo mkdir /opt/homelesshelper
cd /opt/homelesshelper/
tar -xzf /tmp/homelesshelper.tar.gz
rm /etc/init.d/homelesshelper-8010
rm /etc/init.d/homelesshelper-8011
rm /etc/init.d/homelesshelper-8012
rm /etc/init.d/homelesshelper-8013
ln -s /opt/homelesshelper/daemons/homelesshelper-8010.sh /etc/init.d/homelesshelper-8010 
ln -s /opt/homelesshelper/daemons/homelesshelper-8011.sh /etc/init.d/homelesshelper-8011 
ln -s /opt/homelesshelper/daemons/homelesshelper-8012.sh /etc/init.d/homelesshelper-8012 
ln -s /opt/homelesshelper/daemons/homelesshelper-8013.sh /etc/init.d/homelesshelper-8013
chmod 755 -R /opt/homelesshelper
/opt/homelesshelper/daemons/start-all.sh
