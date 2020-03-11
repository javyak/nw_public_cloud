provider "aws" {
  profile = "default"
  region = "eu-west-1"
}

resource "aws_security_group" "allow_access" {
  name = "allow_access"
  description = "Allow admin with SSH and web with TLS"
  ingress {
    description = "Allow SSH"
    from_port   = 22
    to_port     = 22
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

resource "aws_instance" "ubuntu_server" {
  ami           = "ami-035966e8adab4aaad"
  instance_type = "t2.micro"
  key_name = aws_key_pair.access.key_name
  security_groups = ["${aws_security_group.allow_access.name}"]
}

output "public_dns" {
  value = "${aws_instance.ubuntu_server.public_dns}"
}

output "ip" {
  value = aws_instance.ubuntu_server.public_ip
}

output "security_groups" {
  value = aws_instance.ubuntu_server.security_groups
}
