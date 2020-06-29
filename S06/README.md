# Creates a secure 3 tier web application

Environment descriotion:
- VPC enviroment with 2 public and 2 private subnets.
- 2 web servers in different AZs serving the content in HTTPS. Image served from a S3 bucket.
- A single atabase server (modify code for redundancy).
- Jump station for accessing any instance through SSH (no direct administration allowed for other instances). All SSH in/out connections are logged to cloudwatch.
- All instances secured with SGs.
- An ALB that distribute requests among both web servers for HTTP and HTTPS.
- WAF rule that prevents any /admin or /login request to the web servers.
- Read only user for operators.

Files included in the git repository:
- Terraform files: variables, networking, storage, instances, loadbalancers, iam and waf.
- init_scripts/ web_init.sh, jump_init.sh and config.json files for initializing the web servers and the jump station.
- wer_server_files/ regportal.ssl, nginx configuration for the web server; index.html, web server html template; goku.jpg, image for the web server.

