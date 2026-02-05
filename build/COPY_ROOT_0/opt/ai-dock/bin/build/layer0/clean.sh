#!/bin/false

# Tidy up and keep image small
apt-get clean -y
rm -rf /var/lib/apt/lists/*

fix-permissions.sh -o container
rm /etc/ld.so.cache
ldconfig
