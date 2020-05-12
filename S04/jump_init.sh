#!/bin/bash
# Install NGINX
sudo apt-get update
sudo apt-get --assume-yes update 

# Apply FW rules that allow 22 for inbound conections.
sudo ufw allow 22/tcp
sudo ufw --force enable

# SSH server confioguration already included in default image.
