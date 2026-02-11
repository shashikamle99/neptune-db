# neptune-graph.tf variables
variable "create_neptune_graph" {
  description = "Create Neptune Analytics Graph for GraphRAG"
  type        = bool
  default     = true
}

variable "manage_vector_index" {
  description = "Manage vector index creation explicitly"
  type        = bool
  default     = false  # Bedrock KB creates this automatically
}

variable "neptune_version" {
  description = "Neptune engine version"
  type        = string
  default     = "1.3.0"
}

variable "graph_schema" {
  description = "Gremlin schema for entity/relation extraction"
  type        = string
  default     = ""
}

variable "vpc_id" {
  description = "VPC ID for private Neptune access"
  type        = string
  default     = null
}

variable "vpc_cidr_block" {
  description = "VPC CIDR for security group"
  type        = string
  default     = "10.0.0.0/16"
}

variable "kms_key_id" {
  description = "KMS key for Neptune ML data catalog"
  type        = string
  default     = null
}
