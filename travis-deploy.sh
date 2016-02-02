#!/bin/bash
cd `dirname $0`

#This file is located at /home/cor/server/woording/ on the woording.com server

tar -xzf package.tgz
rm package.tgz

screen -r web -X quit

rm -rf woording-web
mv build woording-web

chmod 777 woording-web
cd /home/cor/server/woording/woording-web

screen -S web -m "/home/cor/server/woording/woording-web/run-server.sh"
