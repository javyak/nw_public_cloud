# Creates a web server in AWS

The Terraform code deploys a web server in AWS based with the following characteristics:
- Uses Ubuntu as the OS
- Deploy NGINX web server on top
- Creates a S3 bucket and upload a sample image
- Creates a static webpage that includes the picture from S3: www.regportal.lan
- The web page FQDN is not registerd in any DNS, use localhost file for testing.
- The webserver private IP information in shown the static webpage
- Terraform collects the following information as output: S3 bucket global and region FQDN, instance private IP address and instance FQDN.

Files included;
- create_web_server.tf is the terraform file used to deploy the environment in AWS.
- web_init.sh includes the bash script to deploy the NGINX web server, it is called from the terraform file.
- index.html is the template of the html file to be completed with the image and ip address. It's called from web_init.sh.
- regportal_ssl inclides the NGINX website configuration file. It's called from web_init.sh.



