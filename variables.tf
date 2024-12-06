# Variables for AWS Provider
variable "region" {
  default = "us-east-1"
  description = "AWS region where resources will be created"
}

# Variables for VPC
variable "vpc_cidr_block" {
  default = "10.0.0.0/16"
  description = "CIDR block for the VPC"
}

# Variables for Subnets
variable "subnet_cidrs" {
  default = ["10.0.1.0/24", "10.0.2.0/24"]
  description = "CIDR blocks for subnets in different availability zones"
}

variable "availability_zones" {
  default = ["us-east-1a", "us-east-1b"]
  description = "Availability zones for the subnets"
}

# Variables for EC2 Instances
variable "instance_count" {
  default = 4
  description = "Number of EC2 instances to create"
}

variable "instance_type" {
  default = "t2.micro"
  description = "Instance type for EC2 instances"
}

variable "ami_id" {
  default = "ami-0123456789abcdef0" # Replace with your valid AMI ID
  description = "AMI ID for the EC2 instances"
}
