#!/usr/bin/env sh
sudo semanage fcontext -d "/opt/LibreNMS/rrd/journal(/.*)?"
sudo semanage fcontext -d "/opt/LibreNMS/db(/.*)?"
sudo semanage fcontext -d "/opt/LibreNMS/librenmsdata(/.*)?"
sudo semanage fcontext -d "/opt/LibreNMS/rrd/db(/.*)?"
sudo semanage fcontext -d "/opt/LibreNMS/rrd(/.*)?"

sudo semanage fcontext -l | grep /opt/LibreNMS

sudo rm -rf /opt/LibreNMS/db /opt/LibreNMS/rrd /opt/LibreNMS/librenmsdata
