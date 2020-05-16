# Creates an environment with 3 VMs and automate testing

The Terraform code in "create_infrastructure.tf" file deploys: 
- VPC for the project environment.
- Two subnets: public and private.
- An Internet Gateway assigned to the public subnet using a new route table with a default route.
- Security Group allowing SSH, TLS and HTTP for inbound and all outbound traffic.
- Key-pairs for accessing VMs via SSH.
- S3 bucket and upload a local file to it called "goku.jpg"
- Web_server VM in the public subnet.
- Jump_station VM in the public subnet.
- Database_server VM in the private subnet, accessible through the jump_station_VM.
- Creates the following output variables: web_server FQDN, jump_server public IP and database_server private IP to facilitate the management.

Files included in the git repository:
- create_infrastructure.tf, terraform file creating the environment.
- web_init.sh, script for initializing the web server.
- jump_init.sh, script for initializing the jump station.
- regportal.ssl, nginx configuration for the web server.
- index.html, web server html template.
- goku.jpg, image for the web server.

Pending for next version: code to automate post-deployment tests.
