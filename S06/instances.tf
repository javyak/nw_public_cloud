# Creation of instances and their key for remote administration.

resource "aws_key_pair" "access" {
  key_name = "accesskey"
  public_key = file("~/.ssh/terraform.pub")
}

resource "aws_instance" "web_server1" {
  ami           = "ami-035966e8adab4aaad"
  instance_type = "t2.micro"
  key_name = aws_key_pair.access.key_name
  vpc_security_group_ids = [aws_security_group.web_servers.id]
  subnet_id = aws_subnet.public1.id

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
      "sudo wget https://raw.githubusercontent.com/javyak/nw_public_cloud/master/S06/init_scripts/web_init.sh",
      "sudo chmod 774 web_init.sh", 
      "sudo ./web_init.sh ${aws_s3_bucket.web_bucket.bucket_regional_domain_name} ${aws_instance.web_server1.private_ip}"
      ]
  }
}

resource "aws_instance" "web_server2" {
  ami           = "ami-035966e8adab4aaad"
  instance_type = "t2.micro"
  key_name = aws_key_pair.access.key_name
  vpc_security_group_ids = [aws_security_group.web_servers.id]
  subnet_id = aws_subnet.public2.id

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
      "sudo wget https://raw.githubusercontent.com/javyak/nw_public_cloud/master/S06/init_scripts/web_init.sh",
      "sudo chmod 774 web_init.sh", 
      "sudo ./web_init.sh ${aws_s3_bucket.web_bucket.bucket_regional_domain_name} ${aws_instance.web_server2.private_ip}"
      ]
  }
}

resource "aws_instance" "jump_station" {
  ami           = "ami-035966e8adab4aaad"
  instance_type = "t2.micro"
  key_name = aws_key_pair.access.key_name
  vpc_security_group_ids = [aws_security_group.jump_stations.id]
  subnet_id = aws_subnet.public1.id
  iam_instance_profile = aws_iam_instance_profile.cloudwatch_agent.name

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
      "sudo wget https://raw.githubusercontent.com/javyak/nw_public_cloud/master/S06/init_scripts/jump_init.sh",
      "sudo chmod 774 jump_init.sh", 
      "sudo ./jump_init.sh"
      ]
  }
# Wait until the Cloudwatch agent role is defined before booting up the server and configuring the agent.
  depends_on = [
    aws_iam_role.cloudwatch_agent,
  ]
}

resource "aws_instance" "database_sever" {
  ami           = "ami-035966e8adab4aaad"
  instance_type = "t2.micro"
  key_name = aws_key_pair.access.key_name
  vpc_security_group_ids = [aws_security_group.database_servers.id]
  subnet_id = aws_subnet.private1.id

  tags = {
    Name = "database_server"
  }
}