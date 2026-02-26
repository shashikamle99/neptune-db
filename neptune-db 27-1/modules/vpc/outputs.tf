output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.vpc.id
}

output "private_subnet_ids" {
  description = "IDs of private subnets"
  value       = aws_subnet.private[*].id
}

output "neptune_subnet_group_name" {
  description = "Name of the Neptune DB subnet group"
  value       = aws_db_subnet_group.neptune.name
}
