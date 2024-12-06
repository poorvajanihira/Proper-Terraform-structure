# Provider Configuration
provider "aws" {
  region = var.region
}

# VPC Configuration
resource "aws_vpc" "my_vpc" {
  cidr_block = var.vpc_cidr_block

  tags = {
    Name = "MyVPC"
  }
}

# Subnet Configuration
resource "aws_subnet" "my_subnet" {
  count             = length(var.subnet_cidrs)
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = var.subnet_cidrs[count.index]
  availability_zone = var.availability_zones[count.index]

  tags = {
    Name = "Subnet-${count.index + 1}"
  }
}

# Internet Gateway Configuration
resource "aws_internet_gateway" "my_igw" {
  vpc_id = aws_vpc.my_vpc.id

  tags = {
    Name = "My-IGW"
  }
}

# Route Table Configuration
resource "aws_route_table" "my_route_table" {
  vpc_id = aws_vpc.my_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my_igw.id
  }

  tags = {
    Name = "My-Route-Table"
  }
}

# Associate Route Table with Subnets
resource "aws_route_table_association" "my_route_table_assoc" {
  count          = length(var.subnet_cidrs)
  subnet_id      = aws_subnet.my_subnet[count.index].id
  route_table_id = aws_route_table.my_route_table.id
}

# Security Group for ALB
resource "aws_security_group" "alb_sg" {
  vpc_id = aws_vpc.my_vpc.id

  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
  }

  egress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
  }

  tags = {
    Name = "ALB-Security-Group"
  }
}

# Security Group for EC2 Instances
resource "aws_security_group" "ec2_sg" {
  vpc_id = aws_vpc.my_vpc.id

  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
  }

  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
  }

  egress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
  }

  tags = {
    Name = "EC2-Security-Group"
  }
}

# Application Load Balancer (ALB)
resource "aws_lb" "my_alb" {
  name               = "my-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = aws_subnet.my_subnet[*].id

  enable_deletion_protection = false

  tags = {
    Name = "My-ALB"
  }
}

# Target Group for ALB
resource "aws_lb_target_group" "my_tg" {
  name     = "my-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.my_vpc.id

  health_check {
    interval            = 30
    path                = "/"
    protocol            = "HTTP"
    timeout             = 5
    healthy_threshold   = 3
    unhealthy_threshold = 3
  }

  tags = {
    Name = "My-Target-Group"
  }
}

# EC2 Instances
resource "aws_instance" "web_server" {
  count                   = var.instance_count
  ami                     = var.ami_id
  instance_type           = var.instance_type
  subnet_id               = element(aws_subnet.my_subnet[*].id, count.index % length(var.subnet_cidrs))
  vpc_security_group_ids  = [aws_security_group.ec2_sg.id]

  tags = {
    Name = "WebServer-${count.index}"
  }
}
