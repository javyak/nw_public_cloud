# Create an instance in AWS using Terraform

Terraform is used to create a Linux instance in AWS with the following characteristics:
- Region selected is EU-West-01: Ireland.
- The insntace is based on Ubuntu AMI.
- An SSH key locally created is used to have access to the instance for administration.
- A SG is created allowing all outbound traffic and SSL+TLS for inbound.
- It shows the public IP address, DNS named and SG named assigned to the instance.