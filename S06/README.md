# Creates a secure 3 tier web application

Environment descriotion:
- VPC enviroment with 2 public and 2 private subnets.
- 2 web servers in different AZs serving the content in HTTPS. Image served from a S3 bucket.
- A single atabase server (modify code for redundancy).
- Jump station for accessing any instance through SSH (no direct administration allowed for other instances). All SSH in/out connections are logged to cloudwatch from the instance (sshd inbound + iptables outbound)
Notes for connecting through the SSH jump station: 
Add your key: ssh-add ~/.ssh/terraform
Connect to the jump station: ssh -A ubuntu@<public_IP>
Connect from the jump station to another instance: ssh ubuntu@<private_IP>
- All instances secured with SGs.
- An ALB that distribute requests among both web servers for HTTP and HTTPS.
- WAF rule that prevents any /admin or /login request to the web servers.
- Read only user for operators
WARNING: private key in plain text visible in the TF state file, consider using PGP.
Modiofy AWS Credentials file:
[pepito]
aws_access_key_id = 
aws_secret_access_key =
Modigy AWS Config file:
[profile pepito]
region = eu-west-1

Files included in the git repository:
- Terraform files: variables, networking, storage, instances, loadbalancers, iam and waf.
- init_scripts/ web_init.sh, jump_init.sh and config.json files for initializing the web servers and the jump station.
- wer_server_files/ regportal.ssl, nginx configuration for the web server; index.html, web server html template; goku.jpg, image for the web server.

Pending code modifications:
- Use PGP encrypted keys for the read-only user.
- Use Elastic IP and a DNS name for the website, currently tested with ALB provided DNS name.
- Create an automatic post-deploument testing of the setup.
- Use valid certificates for the websites (not self-signed).
- Redundant the DB servers once used in the website setup.
- Use a local script (AWS CLI commands) to create a certificate in ACM as part of the setup. TF would add it to the state file which is not recommended.
- Redirect http to https in NGNIX or ALB (currently HTTP shows the NGINX testing pate, HTTPS shows the actual site).

