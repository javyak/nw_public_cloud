# Creates a web server in AWS

The Terraform code deploys a web server in AWS based with the following characteristics:
- Uses Ubuntu as the OS
- Deploy NGINX web server on top
- Creates a S3 bucket and upload a sample image
- Creates a static webpage that includes the picture from S3
- Provides the ifconfig information in the static webpage
- Terraform collects the following information as output: Instance ID, Public IP, DNS name, private IP, applied security groups and region and VPC.




Original request:
Install and enable a web server (Apache or Nginx if you decided to use Linux) on your VM.
Add a static web page that references the picture in your cloud storage
(Optional) Use server-side include to add ifconfig printout to the web page. You will need this (or similar) functionality when we'll deploy web servers in multiple availability zones.

Try to use an automation tool to provision the web server, and if at all possible use dynamic inventory features of your tool to fetch the VM details from your cloud orchestration system.