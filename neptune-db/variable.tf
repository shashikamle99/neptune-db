# variables.tf - Neptune Analytics + Bedrock Vector DB Configuration
# Compatible with aws-ia/terraform-aws-bedrock module and native resources

# ========================================
# GLOBAL CONFIGURATION
# ========================================
variable "project_name" {
  description = "Project name prefix for all resources"
  type        = string
  default     = "graphrag"
}

variable "environment" {
  description = "Environment (dev/staging/prod)"
  type        = string
  default     = "dev"
  
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be dev, staging, or prod."
  }
}

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "tags" {
  description = "Common tags for all resources"
  type        = map(string)
  default     = {}
}

# ========================================
# S3 DATA SOURCE
# ========================================
variable "s3_bucket_name" {
  description = "S3 bucket name for knowledge base data (must be globally unique)"
  type        = string
  default     = ""
}

variable "s3_data_prefix" {
  description = "S3 folder path for data files"
  type        = string
  default     = "data/"
}

variable "create_s3_bucket" {
  description = "Create new S3 bucket or use existing"
  type        = bool
  default     = true
}

# ========================================
# NEPTUNE ANALYTICS (VECTOR STORE)
# ========================================
variable "create_neptune_analytics" {
  description = "Create Neptune Analytics cluster"
  type        = bool
  default     = true
}

variable "neptune_cluster_name" {
  description = "Neptune Analytics cluster identifier"
  type        = string
  default     = "bedrock-graphrag-cluster"
}

variable "neptune_instance_class" {
  description = "Neptune instance class (db.r6g.large, db.r6g.xlarge, etc.)"
  type        = string
  default     = "db.r6g.large"
  
  validation {
    condition     = can(regex("^(db\\.)?r6g\\.(large|xlarge|2xlarge|4xlarge|8xlarge|12xlarge|16xlarge)$", var.neptune_instance_class))
    error_message = "Must be valid r6g instance class."
  }
}

variable "neptune_version" {
  description = "Neptune engine version"
  type        = string
  default     = "1.3.0"
}

variable "vector_index_name" {
  description = "Vector index name in Neptune Analytics"
  type        = string
  default     = "bedrock-graph-index"
}

variable "vector_dimensions" {
  description = "Vector embedding dimensions (1024 for Titan V2, 1536 for Titan V1)"
  type        = number
  default     = 1024
  
  validation {
    condition     = var.vector_dimensions >= 128 && var.vector_dimensions <= 65535
    error_message = "Vector dimensions must be 128-65535."
  }
}

# Neptune field mappings for Bedrock
variable "neptune_vector_field" {
  description = "Field name for vector embeddings"
  type        = string
  default     = "embedding"
}

variable "neptune_text_field" {
  description = "Field name for raw text"
  type        = string
  default     = "text"
}

variable "neptune_metadata_field" {
  description = "Field name for metadata"
  type        = string
  default     = "metadata"
}

# ========================================
# BEDDROCK KNOWLEDGE BASE
# ========================================
variable "kb_name" {
  description = "Bedrock Knowledge Base name"
  type        = string
  default     = "neptune-graphrag-kb"
}

variable "kb_description" {
  description = "Knowledge base description"
  type        = string
  default     = "GraphRAG Knowledge Base with Neptune Analytics"
}

variable "kb_type" {
  description = "Knowledge base type (VECTOR or GRAPH)"
  type        = string
  default     = "GRAPH"
  
  validation {
    condition     = contains(["VECTOR", "GRAPH"], var.kb_type)
    error_message = "kb_type must be VECTOR or GRAPH."
  }
}

variable "embedding_model_arn" {
  description = "Bedrock embedding model ARN"
  type        = string
  default     = "arn:aws:bedrock:us-east-1::foundation-model/amazon.titan-embed-text-v2:0"
}

variable "embedding_dimensions" {
  description = "Embedding model dimensions (must match vector_dimensions)"
  type        = number
  default     = 1024
}

# ========================================
# IAM & SECURITY
# ========================================
variable "create_iam_role" {
  description = "Create IAM role for Bedrock KB"
  type        = bool
  default     = true
}

variable "kb_role_name" {
  description = "IAM role name for knowledge base"
  type        = string
  default     = "bedrock-kb-neptune-role"
}

variable "enable_cloudwatch_logs" {
  description = "Enable CloudWatch logging"
  type        = bool
  default     = true
}

variable "log_group_name" {
  description = "CloudWatch log group name"
  type        = string
  default     = "/aws/bedrock/kb-neptune"
}

# ========================================
# DATA INGESTION
# ========================================
variable "create_data_source" {
  description = "Create S3 data source"
  type        = bool
  default     = true
}

variable "data_source_name" {
  description = "Data source name"
  type        = string
  default     = "s3-graphrag-data"
}

variable "run_initial_ingestion" {
  description = "Run initial data ingestion job"
  type        = bool
  default     = true
}

# ========================================
# NETWORKING (OPTIONAL)
# ========================================
variable "vpc_id" {
  description = "VPC ID for Neptune (optional)"
  type        = string
  default     = null
}

variable "subnet_ids" {
  description = "Subnet IDs for Neptune (optional)"
  type        = list(string)
  default     = []
}

variable "security_group_ids" {
  description = "Security group IDs for Neptune (optional)"
  type        = list(string)
  default     = []
}

# ========================================
# ADVANCED GRAPH RAG CONFIG
# ========================================
variable "graph_schema" {
  description = "Optional graph schema definition for entity/relation extraction"
  type        = string
  default     = ""
}

variable "max_chunk_size" {
  description = "Maximum chunk size for text splitting (tokens)"
  type        = number
  default     = 300
}

variable "overlap_percentage" {
  description = "Text chunk overlap percentage"
  type        = number
  default     = 20
}

# ========================================
# MODULE-SPECIFIC (aws-ia/terraform-aws-bedrock)
# ========================================
variable "module_version" {
  description = "Terraform module version"
  type        = string
  default     = "0.0.31"
}

variable "create_module_kb" {
  description = "Use community module instead of native resources"
  type        = bool
  default     = false
}
