# Module Variables

# Collection
variable "collection_name" {
  description = "Name of the OpenSearch Serverless collection (must be lowercase, 3-32 chars)"
  type        = string

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{2,31}$", var.collection_name))
    error_message = "collection_name must be 3-32 chars, start with a letter, and contain only lowercase letters, numbers, and hyphens."
  }
}

variable "collection_type" {
  description = "Type of collection: SEARCH, TIMESERIES, or VECTORSEARCH"
  type        = string
  default     = "SEARCH"
}

variable "collection_description" {
  description = "Description of the collection"
  type        = string
  default     = ""
}

variable "standby_replicas" {
  description = "Standby replicas: ENABLED or DISABLED"
  type        = string
  default     = "ENABLED"
}

# Encryption Policy
variable "encryption_policy_name" {
  description = "Override name for encryption policy. Defaults to '<collection_name>-enc-policy'"
  type        = string
  default     = ""
}

variable "kms_key_arn" {
  description = "Customer-managed KMS key ARN. If null, AWS-owned key is used"
  type        = string
  default     = null
}

# Network Policy
variable "network_policy_name" {
  description = "Override name for network policy. Defaults to '<collection_name>-net-policy'"
  type        = string
  default     = ""
}

variable "network_access_type" {
  description = "PublicAccess or VPC. If VPC, create_vpc_endpoint should be true"
  type        = string
  default     = "PublicAccess"
}

# VPC Endpoint
variable "create_vpc_endpoint" {
  description = "Whether to create an OpenSearch Serverless VPC endpoint"
  type        = bool
  default     = false
}

variable "vpc_endpoint_name" {
  description = "Override name for VPC endpoint. Defaults to '<collection_name>-vpce'"
  type        = string
  default     = ""
}

variable "vpc_id" {
  description = "VPC ID for the endpoint (required if create_vpc_endpoint = true)"
  type        = string
  default     = null
}

variable "subnet_ids" {
  description = "Subnet IDs for the endpoint (required if create_vpc_endpoint = true)"
  type        = list(string)
  default     = []
}

variable "security_group_ids" {
  description = "Security group IDs for the endpoint"
  type        = list(string)
  default     = []
}

# Data Access Policy
variable "data_access_policy_name" {
  description = "Override name for data access policy. Defaults to '<collection_name>-data-policy'"
  type        = string
  default     = ""
}

variable "data_access_principals" {
  description = "IAM role/user ARNs granted access to the collection"
  type        = list(string)
  default     = []
}

variable "saml_provider_arn" {
  description = "SAML provider ARN for dashboard access (optional)"
  type        = string
  default     = null
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}
