provider "aws" {
  profile = "default"
  region = "eu-west-1"
}

# Networking configurtion: VPC, subnets, gateways and routing

resource "aws_vpc" "iot_service" {
  cidr_block = "10.0.0.0/20"
  enable_dns_hostnames = true
}

resource "aws_subnet" "public" {
  vpc_id     = aws_vpc.iot_service.id
  map_public_ip_on_launch = true
  cidr_block = "10.0.0.0/24"
}

resource "aws_subnet" "private" {
  vpc_id     = aws_vpc.iot_service.id
  cidr_block = "10.0.1.0/24"
}

resource "aws_internet_gateway" "inet_gw" {
  vpc_id = aws_vpc.iot_service.id
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.iot_service.id
}

resource "aws_route" "default" {
  route_table_id = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.inet_gw.id 
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

# Network security configuration: security groups.

resource "aws_security_group" "jump_stations" {
  name = "jump_stations"
  description = "Allow admin with SSH from any location"
  vpc_id = aws_vpc.iot_service.id
# cidr_blocks should contain IP adressess or subnets ¡allowed to manage the environment.
# this hasn't been done to simplify the management of the environment as I don't have a static IP. 
  ingress {
    description = "Allow SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "web_servers" {
  name = "web_servers"
  description = "Allow admin with SSH and web HTTP and HTTPS"
  vpc_id = aws_vpc.iot_service.id
  
  ingress {
    description = "Allow SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    security_groups = [aws_security_group.jump_stations.id]
  }
  ingress {
    description = "Allow WEB"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "Allow TLS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "Allow ping"
    protocol = "icmp"
    from_port = 8
    to_port = 0
    security_groups = [aws_security_group.jump_stations.id]    
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "database_servers" {
  name = "database_servers"
  description = "Allow admin with SSH and web HTTP and HTTPS"
  vpc_id = aws_vpc.iot_service.id
  
  ingress {
    description = "Allow SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    security_groups = [aws_security_group.jump_stations.id]
  }
  ingress {
    description = "Allow WEB"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    self        = true
    security_groups = [aws_security_group.web_servers.id]
  }
  ingress {
    description = "Allow MySQL"
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    self        = true
    security_groups = [aws_security_group.web_servers.id]
  }
  ingress {
    description = "Allow ping"
    protocol = "icmp"
    from_port = 8
    to_port = 0
    security_groups = [aws_security_group.jump_stations.id]    
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Storage configuration and file upload
/*
resource "aws_s3_bucket" "web_bucket" {
  bucket = "iotportal.javyak.local.lan"
  acl = "public-read"
}

resource "aws_s3_bucket_object" "web_image" {
  bucket = aws_s3_bucket.web_bucket.bucket
  key = "image.jpg"
  source = "./goku.jpg"
  acl = "public-read"
}
*/
# Creation of instances and their key for remote administration.

resource "aws_key_pair" "access" {
  key_name = "accesskey"
  public_key = file("~/.ssh/terraform.pub")
}
/*
resource "aws_instance" "web_server" {
  ami           = "ami-035966e8adab4aaad"
  instance_type = "t2.micro"
  key_name = aws_key_pair.access.key_name
  vpc_security_group_ids = [aws_security_group.web_servers.id]
  subnet_id = aws_subnet.public.id

  tags = {
    Name = "web_server"
  }

  connection {
    bastion_host = aws_instance.jump_station.public_ip
    host         = self.private_ip
    type         = "ssh"
    user         = "ubuntu"
    private_key  = file("~/.ssh/terraform")
  }

  provisioner "remote-exec" {
    inline = [
      "sudo wget https://raw.githubusercontent.com/javyak/nw_public_cloud/master/S06/web_init.sh",
      "sudo chmod 774 web_init.sh", 
      "sudo ./web_init.sh ${aws_s3_bucket.web_bucket.bucket_regional_domain_name} ${aws_instance.web_server.private_ip}"
      ]
  }
}
*/
resource "aws_instance" "jump_station" {
  ami           = "ami-035966e8adab4aaad"
  instance_type = "t2.micro"
  key_name = aws_key_pair.access.key_name
  vpc_security_group_ids = [aws_security_group.jump_stations.id]
  subnet_id = aws_subnet.public.id

  tags = {
    Name = "jump_station"
  }

  connection {
    type = "ssh"
    user = "ubuntu"
    private_key = file("~/.ssh/terraform")
    host = self.public_ip
  }

  provisioner "remote-exec" {
    inline = [
      "sudo wget https://raw.githubusercontent.com/javyak/nw_public_cloud/master/S06/jump_init.sh",
      "sudo chmod 774 jump_init.sh", 
      "sudo ./jump_init.sh"
      ]
  }
# Wait until the Cloudwatch agent role is defined before booting up the server and configuring the agent.
  depends_on = [
    aws_iam_role_policy.cloudwatch_agent,
  ]
}
/*
resource "aws_instance" "database_sever" {
  ami           = "ami-035966e8adab4aaad"
  instance_type = "t2.micro"
  key_name = aws_key_pair.access.key_name
  vpc_security_group_ids = [aws_security_group.database_servers.id]
  subnet_id = aws_subnet.private.id

  tags = {
    Name = "database_server"
  }
}
*/
# IAM configuration. Group operators for read only reusing existing AWS EC2 policy.

resource "aws_iam_group" "operators" {
  name = "operators"
}

resource "aws_iam_user" "pepito" {
  name = "pepito"
}

resource "aws_iam_access_key" "pepito_key" {
  user = aws_iam_user.pepito.name
}

resource "aws_iam_group_membership" "operators" {
  name = "tf-read-only-group"

  users = [
    aws_iam_user.pepito.name,
  ]

  group = aws_iam_group.operators.name
}

resource "aws_iam_group_policy_attachment" "read_only" {
  group      = aws_iam_group.operators.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ReadOnlyAccess"
}

# IAM configuration. Creates the role required for the Cloudwatch agent
resource "aws_iam_role" "cloudwatch_agent" {
  name = "cloudwatch_agent"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "cloudwatch_agent" {
  role       = aws_iam_role.role.cloudwatch_agent
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

# Output values, get with terraform output <name>
# Use the user secret key to modify AWS credentials and config files
/*
output "web_fqdn" {
  value = aws_instance.web_server.public_dns
}
*/
output "jump_ip" {
  value = aws_instance.jump_station.public_ip
}
/*
output "database_ip" {
  value = aws_instance.database_sever.private_ip
}

output "web_server_ip" {
  value = aws_instance.web_server.private_ip
}
*/

output "pepito_key_id" {
  value = aws_iam_access_key.pepito_key.id
}

# Warning: the secret key will be visible in the TF state file. Use the encrypted option.
output "pepito_secret" {
  value = aws_iam_access_key.pepito_key.secret
}

# Use the following output to get an encrypted key, PGP configuration required.
# output "pepito_encrypted_secret" {
#  value = aws_iam_access_key.pepito.encrypted_secret 
#}
