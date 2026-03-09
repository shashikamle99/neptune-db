# Example: Complete OpenSearch Serverless deployment
# Covers both public-access and VPC-access scenarios


# Public Access (no VPC endpoint) 
module "opensearch_public" {
  source = "../../modules/opensearch_serverless"

  collection_name        = "my-search-collection"
  collection_type        = "SEARCH"
  collection_description = "Public search collection"
  standby_replicas       = "ENABLED"

  # Encryption: AWS-owned key (default)
  kms_key_arn = null

  # Network: open to the internet
  network_access_type = "PublicAccess"

  # No VPC endpoint needed for public access
  create_vpc_endpoint = false

  # IAM principals with data access
  data_access_principals = [
    "arn:aws:iam::123456789012:role/MyAppRole",
    "arn:aws:iam::123456789012:user/developer"
  ]

  tags = {
    Environment = "dev"
    Project     = "search"
  }
}

# VPC Access (private) 
module "opensearch_vpc" {
  source = "../../modules/opensearch_serverless"

  collection_name        = "my-private-collection"
  collection_type        = "VECTORSEARCH"
  collection_description = "Private vector search collection behind VPC"
  standby_replicas       = "ENABLED"

  # Encryption: Customer-managed KMS key
  kms_key_arn = "arn:aws:kms:us-east-1:123456789012:key/mrk-abc123"

  # Network: VPC-only
  network_access_type = "VPC"

  # VPC Endpoint
  create_vpc_endpoint = true
  vpc_id              = "vpc-0abc123def456"
  subnet_ids          = ["subnet-0aaa111", "subnet-0bbb222"]
  security_group_ids  = ["sg-0xyz789"]

  # IAM principals with data access
  data_access_principals = [
    "arn:aws:iam::123456789012:role/LambdaExecutionRole",
    "arn:aws:iam::123456789012:role/ECSTaskRole"
  ]

  tags = {
    Environment = "prod"
    Project     = "vector-search"
  }
}


# Outputs

output "public_collection_endpoint" {
  value = module.opensearch_public.collection_endpoint
}

output "private_collection_endpoint" {
  value = module.opensearch_vpc.collection_endpoint
}

output "private_vpc_endpoint_id" {
  value = module.opensearch_vpc.vpc_endpoint_id
}
