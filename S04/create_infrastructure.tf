provider "aws" {
  profile = "default"
  region = "eu-west-1"
}

resource "aws_vpc" "iot_service" {
  cidr_block = "10.0.0.0/20"
}

resource "aws_subnet" "public" {
  vpc_id     = aws_vpc.iot_service.id
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

resource "aws_security_group" "allow_access" {
  name = "allow_access"
  description = "Allow admin with SSH and web HTTP and HTTPS"
  ingress {
    description = "Allow SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "Allow WEB"
    from_port   = 0
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "Allow TLS"
    from_port   = 0
    to_port     = 443
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

resource "aws_key_pair" "access" {
  key_name = "accesskey"
  public_key = file("~/.ssh/terraform.pub")
}

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

resource "aws_instance" "web_server" {
  ami           = "ami-035966e8adab4aaad"
  instance_type = "t2.micro"
  key_name = aws_key_pair.access.key_name
  vpc_security_group_ids = ["${aws_security_group.allow_access.name}"]
  subnet_id = aws_subnet.public.id

  connection {
    type = "ssh"
    user = "ubuntu"
    private_key = file("~/.ssh/terraform")
    host = self.public_ip
  }

  provisioner "remote-exec" {
    inline = [
      "sudo wget https://raw.githubusercontent.com/javyak/nw_public_cloud/master/S04/web_init.sh",
      "sudo chmod 774 web_init.sh", 
      "sudo ./web_init.sh ${aws_s3_bucket.web_bucket.bucket_regional_domain_name} ${aws_instance.web_server.private_ip}"
      ]
  }
}

resource "aws_instance" "jump_station" {
  ami           = "ami-035966e8adab4aaad"
  instance_type = "t2.micro"
  key_name = aws_key_pair.access.key_name
  vpc_security_group_ids = ["${aws_security_group.allow_access.name}"]
  subnet_id = aws_subnet.public.id

  connection {
    type = "ssh"
    user = "ubuntu"
    private_key = file("~/.ssh/terraform")
    host = self.public_ip
  }

  provisioner "remote-exec" {
    inline = [
      "sudo wget https://raw.githubusercontent.com/javyak/nw_public_cloud/master/S04/jump_init.sh",
      "sudo chmod 774 jump_init.sh", 
      "sudo ./jump_init.sh"
      ]
  }
}

resource "aws_instance" "database_sever" {
  ami           = "ami-035966e8adab4aaad"
  instance_type = "t2.micro"
  key_name = aws_key_pair.access.key_name
  vpc_security_group_ids = ["${aws_security_group.allow_access.name}"]
  subnet_id = aws_subnet.private.id

  connection {
    type = "ssh"
    user = "ubuntu"
    private_key = file("~/.ssh/terraform")
    host = self.public_ip
  }

  provisioner "remote-exec" {
    inline = [
      "sudo wget https://raw.githubusercontent.com/javyak/nw_public_cloud/master/S04/database_init.sh",
      "sudo chmod 774 database_init.sh", 
      "sudo ./database_init.sh"
      ]
  }
}

output "web_fqdn" {
  value = aws_instance.web_server.public_dns
}

output "jump_ip" {
  value = aws_instance.jump_station.public_ip
}

output "database_ip" {
  value = aws_instance.database_sever.private_ip
}
