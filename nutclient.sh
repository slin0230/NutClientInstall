#!/bin/bash

# Install Nut client
apt install -y nut-client

# Download and extract configuration files
if [ ! -f "nutconfig.tar.gz" ]; then
  echo "Downloading Configuration..."
  wget https://raw.githubusercontent.com/steven-geo/proxmox-nut/refs/heads/master/nutconfig.tar.gz -O nutconfig.tar.gz
else
  echo "Using Existing Configuration tarball"
fi
tar -xvzf nutconfig.tar.gz -C /etc

echo "Configuring NUT"
# Edit upsmon.conf - update password to match upsd.users
sed -i "s/^MONITOR.*/MONITOR ups@192.168.84.243 1 upsmon pssupsmonitor2024 master/g" /etc/nut/upsmon.conf

# remove unused files
rm /etc/nut/ups.conf /etc/nut/upsd.* /etc/nut/nut.conf

echo "MODE=netclient" >/etc/nut/nut.conf

#Ensure our actions are executable
chmod +x /etc/nut/upssched-cmd

# Restart/Start services with our new configuration
service nut-client start
systemctl start nut-monitor

echo "Nut successfully configured"
