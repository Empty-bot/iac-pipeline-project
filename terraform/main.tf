terraform {
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

# Variables
variable "aws_region" {
  description = "AWS region"
  default     = "eu-west-3"
}

# Récupérer la dernière AMI Ubuntu 22.04
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

# Créer une paire de clés SSH pour se connecter à l'EC2
resource "tls_private_key" "ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "deployer" {
  key_name   = "iac-pipeline-key"
  public_key = tls_private_key.ssh_key.public_key_openssh
}

# Sauvegarder la clé privée localement (Ansible en aura besoin)
resource "local_file" "ssh_private_key" {
  content         = tls_private_key.ssh_key.private_key_pem
  filename        = "${path.module}/ec2-key.pem"
  file_permission = "0600"
}

# Security Group (firewall)
resource "aws_security_group" "app_sg" {
  name        = "iac-pipeline-sg"
  description = "Security group for IaC pipeline app"

  # Autoriser SSH (port 22)
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Autoriser l'accès à l'app Flask (port 5000)
  ingress {
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Autoriser tout le trafic sortant
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "iac-pipeline-sg"
  }
}

# Instance EC2
resource "aws_instance" "app_server" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"  # Free tier
  key_name      = aws_key_pair.deployer.key_name

  vpc_security_group_ids = [aws_security_group.app_sg.id]

  tags = {
    Name = "iac-pipeline-app"
  }
}

# Outputs (pour récupérer les infos après)
output "instance_id" {
  description = "ID de l'instance EC2"
  value       = aws_instance.app_server.id
}

output "instance_public_ip" {
  description = "IP publique de l'instance EC2"
  value       = aws_instance.app_server.public_ip
}

output "ssh_private_key_path" {
  description = "Chemin vers la clé SSH privée"
  value       = local_file.ssh_private_key.filename
}

output "app_url" {
  description = "URL pour accéder à l'application"
  value       = "http://${aws_instance.app_server.public_ip}:5000"
}