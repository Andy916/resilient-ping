variable "aws_region" {
  type        = string
  default     = "us-east-2"
  description = "The AWS region to deploy resources into"
}

variable "instance_type" {
  type        = string
  default     = "t3.micro"
  description = "The EC2 instance size (Free Tier eligible)"
}
