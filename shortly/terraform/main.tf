terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# Get latest Ubuntu AMI
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical
  
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
  
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Security Group
resource "aws_security_group" "shortly_sg" {
  name        = "shortly-sg-terraform"
  description = "Security group for Shortly application (Terraform managed)"
  
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.allowed_ssh_cidr
  }
  
  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  ingress {
    description = "Frontend App"
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  ingress {
    description = "Backend API"
    from_port   = 8000
    to_port     = 8000
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
    Name = "shortly-sg-terraform"
    Project = "DevOps-Learning"
    ManagedBy = "Terraform"
  }
}

# Key Pair
resource "aws_key_pair" "shortly_key" {
  key_name   = var.key_name
  public_key = file(var.public_key_path)
  
  tags = {
    Name = "shortly-key-terraform"
    Project = "DevOps-Learning"
    ManagedBy = "Terraform"
  }
}

# EC2 Instance
resource "aws_instance" "shortly_server" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.instance_type
  key_name      = aws_key_pair.shortly_key.key_name
  
  vpc_security_group_ids = [aws_security_group.shortly_sg.id]
  
  user_data = file("${path.module}/user-data.sh")
  
  tags = {
    Name = "shortly-server-terraform"
    Project = "DevOps-Learning"
    Environment = "production"
    ManagedBy = "Terraform"
  }
}

# Elastic IP (Optional - for consistent IP addressing)
resource "aws_eip" "shortly_eip" {
  instance = aws_instance.shortly_server.id
  domain   = "vpc"
  
  tags = {
    Name = "shortly-eip-terraform"
    Project = "DevOps-Learning"
    ManagedBy = "Terraform"
  }
} 