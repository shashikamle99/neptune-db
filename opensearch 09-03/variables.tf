# Root Variables

variable "collection_name" {
  description = "Name of the OpenSearch Serverless collection"
  type        = string
}

variable "collection_type" {
  description = "Type of collection: SEARCH, TIMESERIES, or VECTORSEARCH"
  type        = string
  default     = "SEARCH"

  validation {
    condition     = contains(["SEARCH", "TIMESERIES", "VECTORSEARCH"], var.collection_type)
    error_message = "collection_type must be one of: SEARCH, TIMESERIES, VECTORSEARCH."
  }
}

variable "collection_description" {
  description = "Description of the OpenSearch Serverless collection"
  type        = string
  default     = ""
}

variable "standby_replicas" {
  description = "Indicates whether standby replicas should be used: ENABLED or DISABLED"
  type        = string
  default     = "ENABLED"

  validation {
    condition     = contains(["ENABLED", "DISABLED"], var.standby_replicas)
    error_message = "standby_replicas must be ENABLED or DISABLED."
  }
}

# Encryption
variable "encryption_policy_name" {
  description = "Name of the encryption security policy"
  type        = string
  default     = ""
}

variable "kms_key_arn" {
  description = "ARN of the KMS key for encryption. If null, AWS-managed key is used"
  type        = string
  default     = null
}

# Network
variable "network_policy_name" {
  description = "Name of the network security policy"
  type        = string
  default     = ""
}

variable "network_access_type" {
  description = "Network access type: PublicAccess or VPC"
  type        = string
  default     = "PublicAccess"

  validation {
    condition     = contains(["PublicAccess", "VPC"], var.network_access_type)
    error_message = "network_access_type must be PublicAccess or VPC."
  }
}

# VPC Endpoint
variable "create_vpc_endpoint" {
  description = "Whether to create a VPC endpoint for OpenSearch Serverless"
  type        = bool
  default     = false
}

variable "vpc_endpoint_name" {
  description = "Name of the VPC endpoint"
  type        = string
  default     = ""
}

variable "vpc_id" {
  description = "VPC ID for the VPC endpoint"
  type        = string
  default     = null
}

variable "subnet_ids" {
  description = "List of subnet IDs for the VPC endpoint"
  type        = list(string)
  default     = []
}

variable "security_group_ids" {
  description = "List of security group IDs for the VPC endpoint"
  type        = list(string)
  default     = []
}

# Data Access
variable "data_access_policy_name" {
  description = "Name of the data access policy"
  type        = string
  default     = ""
}

variable "data_access_principals" {
  description = "List of IAM principal ARNs (roles/users) granted data access"
  type        = list(string)
  default     = []
}

variable "saml_provider_arn" {
  description = "ARN of the SAML provider for OpenSearch Serverless dashboard access"
  type        = string
  default     = null
}

variable "tags" {
  description = "Map of tags to apply to all resources"
  type        = map(string)
  default     = {}
}


variable "opensearch" {
  type = map(string)
  default = {
    "dev" = "dev_value",
    "uat" = "uat_value",
    "prod" = "prod_value"
  }  
}