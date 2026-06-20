terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Uses the variable for the region
provider "aws" {
  region = var.aws_region
}

# Create the IAM Role for the instance
resource "aws_iam_role" "ec2_ssm_role" {
  name = "resilient-ping-ec2-ssm-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

# Attach the AWS official SSM managed policy to the role
resource "aws_iam_role_policy_attachment" "ssm_policy" {
  role       = aws_iam_role.ec2_ssm_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# Create the profile wrapper that EC2 can actually read
resource "aws_iam_instance_profile" "ec2_profile" {
  name = "resilient-ping-ec2-profile"
  role = aws_iam_role.ec2_ssm_role.name
}

resource "aws_security_group" "resilient_sg" {
  name        = "resilient-ping-sg"
  description = "Allow inbound web traffic on port 8080"

  ingress {
    from_port   = 8080
    to_port     = 8080
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

resource "aws_instance" "app_server" {
  ami           = "ami-09040d770ffe2224f" # Ubuntu 24.04 LTS in us-east-2
  instance_type = var.instance_type       # Uses the variable for the size

  vpc_security_group_ids = [aws_security_group.resilient_sg.id]

  # Attaches the SSM permissions to this server
  iam_instance_profile   = aws_iam_instance_profile.ec2_profile.name

  tags = {
    Name = "ResilientPingServer"
  }
}

output "server_public_ip" {
  value       = aws_instance.app_server.public_ip
  description = "The public IP address of your web server"
}
