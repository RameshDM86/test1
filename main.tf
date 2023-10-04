terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
}


resource "aws_instance" "web_server" {
  ami           = "ami-0a50c6d5812ce8bf7" # Amazon Linux 
  instance_type = "t2.micro"
  key_name      = aws_key_pair.my_keypair.key_name # for SSH connection with a new key pair created below
  vpc_security_group_ids = [aws_security_group.allow_http_https_ssh_traffic.id]
  associate_public_ip_address = true

  tags = {
    Name = "Ramesh-SSHSecurityGroup-EC2"
  }
}

resource "aws_security_group" "allow_http_https_ssh_traffic" {
  name        = "Ramesh-tryingoutsecuritygroup"
  description = "Allow inbound traffic for https, http and ssh"

  ingress {
    description      = "HTTPS inbound"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks = ["219.74.247.174/32"]
  }

  ingress {
    description      = "HTTP inbound"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks = ["219.74.247.174/32"]
  }

  ingress {
    description      = "SSH inbound"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks = ["219.74.247.174/32"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks = ["219.74.247.174/32"]
  }

  tags = {
    Name = "allow_tls"
  }
}

# Below resources will create a key pair to your local computer on the same path as your terraform folder
resource "tls_private_key" "private_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

terraform { 
    backend "S3" {
      bucket = "sctp-ce3-tfstate-bkt"
      key    = "Ramesh.tfstate"
      region = "us-east-1"
    }

}

resource "aws_key_pair" "my_keypair" {
  key_name   = "ramesh-east11.pem"       # Create a key called "my-us-east-1-key" in AWS
  public_key = tls_private_key.private_key.public_key_openssh

  provisioner "local-exec" { # Creates/Downloads a "ramesha-east1-key.pem" to your computer
    command = "echo '${tls_private_key.private_key.private_key_pem}' > ./ramesha-east1-key.pem"
  }
}
