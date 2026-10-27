terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
    region = "eu-west-3"
}

resource "aws_key_pair" "key-pair" {
  key_name   = "flask-key"
  public_key = file("~/.ssh/flask-cicd.pub")
}

resource "aws_security_group" "sg" {
  name = "flask-sg"

  ingress {
    description = "ssh"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["78.240.166.69/32"]
  }
  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    description = "sortie"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-arm64-server-*"]
  }
}

resource "aws_instance" "staging" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t4g.micro"
  key_name               = aws_key_pair.key-pair.key_name
  vpc_security_group_ids = [aws_security_group.sg.id]

  tags = {
    Name = "flask-staging"
  }
}

resource "aws_instance" "production" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t4g.micro"
  key_name               = aws_key_pair.key-pair.key_name
  vpc_security_group_ids = [aws_security_group.sg.id]

  tags = {
    Name = "flask-production"
  }
}

output "staging_ip" {
  description = "Public IP address of the staging server"
  value       = aws_instance.staging.public_ip
}

output "production_ip" {
  description = "Public IP address of the production server"
  value       = aws_instance.production.public_ip
}