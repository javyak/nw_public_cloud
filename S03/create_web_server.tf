provider "aws" {
  profile = "default"
  region = "eu-west-1"
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

resource "aws_instance" "ubuntu_server" {
  ami           = "ami-035966e8adab4aaad"
  instance_type = "t2.micro"
  key_name = aws_key_pair.access.key_name
  security_groups = ["${aws_security_group.allow_access.name}"]

  connection {
    type = "ssh"
    user = "ubuntu"
    private_key = file("~/.ssh/terraform")
    host = self.public_ip
  }

  provisioner "remote-exec" {
    inline = [
      "sudo wget https://raw.githubusercontent.com/javyak/nw_public_cloud/master/S03/web_init.sh",
      "sudo chmod 774 web_init.sh", 
      "sudo ./web_init.sh ${aws_s3_bucket.web_bucket.bucket_regional_domain_name} ${aws_instance.ubuntu_server.private_ip}"
      ]
  }
}

output "image_url" {
  value = aws_s3_bucket.web_bucket.bucket_domain_name
}

output "image_regional_url"{
  value = aws_s3_bucket.web_bucket.bucket_regional_domain_name
}

output "ip" {
  value = aws_instance.ubuntu_server.private_ip
}

output "fqdn" {
  value = aws_instance.ubuntu_server.public_dns
}