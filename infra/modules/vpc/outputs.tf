output "vpc_id" {
  value = aws_vpc.vpc.id
}
output "public_subnet_ids" {
  value = [for subnet in values(aws_subnet.public_subnets) : subnet.id]
}

output "private_subnet_ids" {
  value = [for subnet in values(aws_subnet.private_subnets) : subnet.id]
}

output "vpc_endpoint_sg_id" {
  value       = aws_security_group.vpc_endpoints.id
  description = "Security group ID for VPC interface endpoints"
}

output "s3_prefix_list_id" {
  value       = aws_vpc_endpoint.s3.prefix_list_id
  description = "Prefix list ID for the S3 gateway endpoint"
}
