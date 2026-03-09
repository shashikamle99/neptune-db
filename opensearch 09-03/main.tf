# AWS OpenSearch Serverless - Root Configuration

module "opensearch_serverless" {
  source = "./modules/opensearch_serverless"

  collection_name        = var.collection_name
  collection_type        = var.collection_type
  collection_description = var.collection_description
  standby_replicas       = var.standby_replicas

  # Encryption
  encryption_policy_name        = var.encryption_policy_name
  kms_key_arn                   = var.kms_key_arn

  # Network
  network_policy_name           = var.network_policy_name
  network_access_type           = var.network_access_type

  # VPC Endpoint
  create_vpc_endpoint           = var.create_vpc_endpoint
  vpc_endpoint_name             = var.vpc_endpoint_name
  vpc_id                        = var.vpc_id
  subnet_ids                    = var.subnet_ids
  security_group_ids            = var.security_group_ids

  # Data Access
  data_access_policy_name       = var.data_access_policy_name
  data_access_principals        = var.data_access_principals
  saml_provider_arn             = var.saml_provider_arn

  tags = var.tags
}
