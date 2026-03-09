# Root Outputs

output "collection_id" {
  description = "ID of the OpenSearch Serverless collection"
  value       = module.opensearch_serverless.collection_id
}

output "collection_arn" {
  description = "ARN of the OpenSearch Serverless collection"
  value       = module.opensearch_serverless.collection_arn
}

output "collection_endpoint" {
  description = "Collection-level endpoint used to submit index, search, and data upload requests to an OpenSearch Serverless collection"
  value       = module.opensearch_serverless.collection_endpoint
}

output "dashboard_endpoint" {
  description = "Collection-level endpoint used to access OpenSearch Dashboards"
  value       = module.opensearch_serverless.dashboard_endpoint
}

output "vpc_endpoint_id" {
  description = "ID of the VPC endpoint"
  value       = module.opensearch_serverless.vpc_endpoint_id
}

output "encryption_policy_name" {
  description = "Name of the encryption security policy"
  value       = module.opensearch_serverless.encryption_policy_name
}

output "network_policy_name" {
  description = "Name of the network security policy"
  value       = module.opensearch_serverless.network_policy_name
}

output "data_access_policy_name" {
  description = "Name of the data access policy"
  value       = module.opensearch_serverless.data_access_policy_name
}
