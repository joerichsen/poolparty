#!/bin/sh

# Reconfigure master
:config_master
# Start this instance's master maintain script
:start_pool_maintain
# Make the ha.d/resource.d
sudo mkdir /etc/ha.d/resource.d/
# Set this hostname as appropriate in the cloud
:set_hostname
# Configure heartbeat
sudo mkdir /etc/ha.d/resource.d/
# Start heartbeat
/etc/init.d/heartbeat start
# Start s3fs
:start_s3fs
# Configure monit
mkdir /etc/monit.d
