#!/bin/bash
# Install NGINX
sudo apt-get update
sudo apt-get --assume-yes update
sudo apt-get --assume-yes install mysql-server 

# Apply FW rules that allow 22, for inbound conections.
sudo ufw allow 22/tcp
sudo ufw allow 3306/tcp
sudo ufw --force enable

# Mysql configuration pending