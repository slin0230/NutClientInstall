#!/bin/bash

Help() {
  echo "Proxmox UPS Client Installer Configuration."
  echo
  echo "Syntax: $0 [-a|-p]"
  echo "options:"
  echo "  -a a.b.c.d     The IP Address of the UPS to configure"
  echo "  -p ********    Password for Localhost nut access"
  echo
}

# Set defaults if not specified on commandline
IPADDR="127.0.0.1"
NUTPASS="password"

# Pass Commandline Arguments
while getopts ":a:p:" opt; do
  case $opt in
  a) # UPS IP Address
    IPADDR="${OPTARG}" ;;
  p) # nut password
    NUTPASS="${OPTARG}" ;;
  :) # no argument
    echo "Option -${OPTARG} requires an argument."
    exit
    ;;
  *) # invalid option
    Help
    exit
    ;;
  esac
done

# Check for the IP Address, this is the minimum required option
if [[ "${IPADDR}" == "127.0.0.1" ]]; then
  echo -e "ERROR: IP Address of UPS notspecified see help...\n"
  Help
  exit 204
fi

# Install Nut client
apt install -y nut-client

# Download and extract configuration files
if [ ! -f "nutconfig.tar.gz" ]; then
  echo "Downloading Configuration..."
  wget https://github.com/slin0230/NutClientInstall/raw/refs/heads/main/nutconfig.tar.gz -O nutconfig.tar.gz
else
  echo "Using Existing Configuration tarball"
fi
tar -xvzf nutconfig.tar.gz -C /etc

echo "Configuring NUT"
echo "  UPS IP Address = ${IPADDR}"
echo "  NUT Password = ***********"

echo "Configuring NUT"
# Edit upsmon.conf - update password to match upsd.users
sed -i "s/^MONITOR.*/MONITOR ups@${IPADDR} 1 upsmon $NUTPASS master/g" /etc/nut/upsmon.conf

echo "MODE=netclient" >/etc/nut/nut.conf

#Ensure our actions are executable
chmod +x /etc/nut/upssched-cmd

# Restart/Start services with our new configuration
service nut-client start
systemctl start nut-monitor

journalctl -u nut-monitor --no-pager

echo "Nut successfully configured"
