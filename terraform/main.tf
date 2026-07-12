terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "ap-southeast-1"
}

# Key pair for SSH access
resource "aws_key_pair" "frisbee_key" {
  key_name   = "frisbee-sre-key"
  public_key = file("~/.ssh/frisbee-sre.pub")
}

# Security group — controls what traffic is allowed
resource "aws_security_group" "frisbee_sg" {
  name        = "frisbee-sre-sg"
  description = "Security group for frisbee SRE project"

  # SSH access
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # App access
  ingress {
    from_port   = 30000
    to_port     = 30003
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
  from_port   = 6443
  to_port     = 6443
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  }

  # All outbound traffic allowed
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# EC2 instance
resource "aws_instance" "frisbee_server" {
  ami                    = "ami-0497a974f8d5dcef8"
  instance_type          = "t3.small"
  key_name               = aws_key_pair.frisbee_key.key_name
  vpc_security_group_ids = [aws_security_group.frisbee_sg.id]

  user_data = <<-EOF
    #!/bin/bash
    curl -sfL https://get.k3s.io | sh -
    systemctl enable k3s
    systemctl start k3s
  EOF

  tags = {
    Name = "frisbee-sre"
  }
}

resource "aws_eip" "frisbee_ip" {
  instance = aws_instance.frisbee_server.id
  domain   = "vpc"
}

output "instance_ip" {
  value = aws_eip.frisbee_ip.public_ip
}
