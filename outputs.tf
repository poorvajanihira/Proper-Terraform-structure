output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.my_vpc.id
}

output "subnet_ids" {
  description = "The IDs of the created subnets"
  value       = aws_subnet.my_subnet[*].id
}

output "alb_dns_name" {
  description = "The DNS name of the Application Load Balancer"
  value       = aws_lb.my_alb.dns_name
}

output "ec2_instance_ids" {
  description = "The IDs of the EC2 instances"
  value       = aws_instance.web_server[*].id
}