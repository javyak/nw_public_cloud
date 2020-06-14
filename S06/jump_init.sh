#!/bin/bash
# Install NGINX
sudo apt-get update
sudo apt-get --assume-yes update 

# Apply FW rules that allow 22 for inbound conections.
sudo ufw allow 22/tcp
sudo ufw --force enable

# SSH server confioguration already included in default image.

# Download and install cloudwatch agent
wget https://s3.amazonaws.com/amazoncloudwatch-agent/ubuntu/amd64/latest/amazon-cloudwatch-agent.deb
sudo dpkg -i -E ./amazon-cloudwatch-agent.deb
# Configure cloudwatch agent with the file in the gir repository
cd /opt/aws/amazon-cloudwatch-agent/bin 
sudo wget https://raw.githubusercontent.com/javyak/nw_public_cloud/master/S06/config.json
# Start the cloudwatch agent
sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -c file:/opt/aws/amazon-cloudwatch-agent/bin/config.json -s


