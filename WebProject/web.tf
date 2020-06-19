provider "aws" {
   region = "us-east-2"
   profile = "Terraform"
}

//Generate Key file

resource "tls_private_key" "web-key" {
  algorithm = "RSA"
}

resource "aws_key_pair" "gen-key" {
    key_name = "web_key"
    public_key = tls_private_key.web-key.public_key_openssh
    
    depends_on = [
         tls_private_key.web-key
         ]
}

//Save Key file to local

resource "local_file" "key_file" {
    content = tls_private_key.web-key.private_key_pem
    filename = "webkey.pem"
    file_permission = "0600"

    depends_on = [
        tls_private_key.web-key,
        aws_key_pair.gen-key
        ]
}

//Create Security Group

resource "aws_security_group" "web_sec" {
  name = "web-sec"
  description = "Allow web traffic"

  ingress {
    description = "Allow SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  ingress {
    description = "Allow SSH"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  } 

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "web_sec"
  }
}

//Launch EC2

resource "aws_instance" "web-server" {
    ami = "ami-0a54aef4ef3b5f881"
    instance_type = "t2.micro"
    key_name = aws_key_pair.gen-key.key_name
    security_groups = ["web-sec"]
  
   tags = {
    Name = "web-server"
   }

//Connecting to EC2

  connection {
    user = "ec2-user"
    type = "ssh"
    private_key = tls_private_key.web-key.private_key_pem
    host = self.public_ip
  }

//Install httpd and git
  provisioner "remote-exec" {
     inline = [
               "sudo yum install httpd git -y",
               "sudo systemctl start httpd",
               "sudo chkconfig httpd on",
               "sudo git clone https://github.com/kiranpe/DockerImage.git /var/www/html/"
              ]
  }

 depends_on = [
        tls_private_key.web-key,
        aws_key_pair.gen-key,
        aws_security_group.web_sec
        ]
}

