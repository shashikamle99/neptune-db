output "vpc_id" {
  description = "ID of the VPC"
  value       = module.vpc.vpc_id
}

output "private_subnet_ids" {
  description = "IDs of the private subnets"
  value       = module.vpc.private_subnet_ids
}

output "neptune_sg_id" {
  description = "ID of the Neptune security group"
  value       = module.security_group.neptune_sg_id
}

output "neptune_cluster_id" {
  description = "Neptune cluster identifier"
  value       = module.neptune.cluster_id
}

output "neptune_cluster_endpoint" {
  description = "Neptune cluster writer endpoint"
  value       = module.neptune.cluster_endpoint
}

output "neptune_cluster_reader_endpoint" {
  description = "Neptune cluster reader endpoint"
  value       = module.neptune.cluster_reader_endpoint
}

output "neptune_cluster_port" {
  description = "Neptune cluster port"
  value       = module.neptune.cluster_port
}
