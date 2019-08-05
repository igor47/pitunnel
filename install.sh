#!/bin/bash

wd=`pwd`
ln -s ${wd}/tunnel.service /etc/systemd/system/tunnel.service
systemctl enable tunnel
systemctl start tunnel
systemctl status tunnel
