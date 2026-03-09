# Module Outputs

output "collection_id" {
  description = "ID of the OpenSearch Serverless collection"
  value       = aws_opensearchserverless_collection.this.id
}

output "collection_arn" {
  description = "ARN of the OpenSearch Serverless collection"
  value       = aws_opensearchserverless_collection.this.arn
}

output "collection_endpoint" {
  description = "Endpoint for submitting index, search, and data upload requests"
  value       = aws_opensearchserverless_collection.this.collection_endpoint
}

output "dashboard_endpoint" {
  description = "OpenSearch Dashboards endpoint"
  value       = aws_opensearchserverless_collection.this.dashboard_endpoint
}

output "vpc_endpoint_id" {
  description = "ID of the VPC endpoint (null if not created)"
  value       = var.create_vpc_endpoint ? aws_opensearchserverless_vpc_endpoint.this[0].id : null
}

output "encryption_policy_name" {
  description = "Name of the encryption security policy"
  value       = aws_opensearchserverless_security_policy.encryption.name
}

output "network_policy_name" {
  description = "Name of the network security policy"
  value       = aws_opensearchserverless_security_policy.network.name
}

output "data_access_policy_name" {
  description = "Name of the data access policy"
  value       = aws_opensearchserverless_access_policy.this.name
}
