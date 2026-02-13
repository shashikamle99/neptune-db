output "neptune_cluster_endpoint" {
  description = "Neptune cluster endpoint"
  value       = aws_neptune_cluster.production.endpoint
}

output "neptune_reader_endpoint" {
  description = "Neptune reader endpoint"
  value       = aws_neptune_cluster.production.reader_endpoint
}

output "neptune_cluster_arn" {
  description = "Neptune cluster ARN"
  value       = aws_neptune_cluster.production.arn
}

output "security_group_id" {
  description = "Neptune security group ID"
  value       = aws_security_group.neptune_sg.id
}