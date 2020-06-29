#!/bin/bash
# Install NGINX
sudo apt-get update
sudo apt-get --assume-yes update 
sudo apt-get --assume-yes install nginx

# Apply FW rules that allow 80, 22 and 443 for inbound conections.
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw allow 22/tcp
sudo ufw --force enable

# Create a certificate for the SSL service
sudo openssl req -x509 \
    -days 365 \
    -sha256 \
    -newkey rsa:2048 \
    -nodes \
    -keyout /etc/ssl/private/regportal.key \
    -out /etc/ssl/certs/regportal-cert.pem \
    -subj "/C=ES/ST=Madrid/L=Madrid/O=Regportal/OU=IoT/CN=regportal.lan"

# Create the website for the IoT registration portal service
sudo mkdir /var/www/regportal
cd /var/www/regportal
sudo wget https://raw.githubusercontent.com/javyak/nw_public_cloud/master/S06/web_server_files/index.html
# Complete the Html configuration by appending the 
cd /var/www/regportal
sudo bash -c "sed -i s/S3_BUCKET/$1/ index.html"
sudo bash -c "sed -i s/PRIVATE_IP_ADDR/$2/ index.html"
# Configure the web server settings
cd /etc/nginx/sites-available/
sudo wget https://raw.githubusercontent.com/javyak/nw_public_cloud/master/S06/web_server_files/regportal_ssl
sudo ln -s /etc/nginx/sites-available/regportal_ssl /etc/nginx/sites-enabled/regportal
sudo systemctl restart nginx


