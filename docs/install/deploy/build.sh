#!/bin/bash

## create package
cd /development/homelesshelper/apps/web/
tar cfz /tmp/homelesshelper.tar.gz *

## drop installer on app host
scp /development/homelesshelper/tools/deploy/installer.sh XXXX@XXXX:/opt/homelesshelper-installer.sh
scp /tmp/homelesshelper.tar.gz XXXX@XXXX:/opt/homelesshelper.tar.gz

## push code
cd /development/homelesshelper/infrastructure/fabric
fab app push_code_homelesshelper
