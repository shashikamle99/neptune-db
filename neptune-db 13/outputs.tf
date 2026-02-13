output "cluster_endpoint" {
  description = "Cluster writer endpoint"
  value       = aws_neptune_cluster.main.endpoint
}

output "reader_endpoint" {
  description = "Cluster reader endpoint"
  value       = aws_neptune_cluster.main.reader_endpoint
}

output "vpc_id" {
  value = aws_vpc.main.id
}

output "security_group_id" {
  value = aws_security_group.neptune.id
}
