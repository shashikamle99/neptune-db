output "cluster_id" {
  description = "Neptune cluster identifier"
  value       = aws_neptune_cluster.neptune_cluster.id
}

output "cluster_arn" {
  description = "Neptune cluster ARN"
  value       = aws_neptune_cluster.neptune_cluster.arn
}

output "cluster_endpoint" {
  description = "Neptune cluster writer endpoint"
  value       = aws_neptune_cluster.neptune_cluster.endpoint
}

output "cluster_reader_endpoint" {
  description = "Neptune cluster reader endpoint"
  value       = aws_neptune_cluster.neptune_cluster.reader_endpoint
}

output "cluster_port" {
  description = "Neptune cluster port"
  value       = aws_neptune_cluster.neptune_cluster.port
}

output "subnet_group_name" {
  description = "Neptune subnet group name"
  value       = aws_neptune_subnet_group.neptune_sg.name
}

output "cluster_resource_id" {
  description = "Neptune cluster resource ID"
  value       = aws_neptune_cluster.neptune_cluster.cluster_resource_id
}
