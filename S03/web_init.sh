#!/bin/bash
sudo apt-get update
sudo apt-get --asume-yes update 
sudo apt-get --asume-yes install nginx
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw allow 22/tcp
sudo ufw --force enable

sudo openssl req -x509 \
    -days 365 \
    -sha256 \
    -newkey rsa:2048 \
    -nodes \
    -keyout /etc/ssl/private/regportal.key \
    -out /etc/ssl/certs/regportal-cert.pem \
    -subj "/C=ES/ST=Madrid/L=Madrid/O=Regportal/OU=IoT/CN=regportal.lan"

sudo mkdir /var/www/regportal
cd /var/www/regportal
sudo wget https://raw.githubusercontent.com/javyak/nw_public_cloud/master/S03/index.html
cd /etc/nginx/sites-available/
sudo wget https://raw.githubusercontent.com/javyak/nw_public_cloud/master/S03/regportal_ssl
sudo ln -s /etc/nginx/sites-available/regportal_ssl /etc/nginx/sites-enabled/regportal
sudo systemctl restart nginx