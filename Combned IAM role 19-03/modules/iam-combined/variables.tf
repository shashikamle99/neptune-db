variable "prefix" {
  description = "Resource name prefix (e.g. mpg-dev-ai-gpt)"
  type        = string
}

variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "account_id" {
  description = "AWS account ID"
  type        = string
}

variable "neptune_s3_bucket_arns" {
  description = "S3 bucket ARNs for Neptune bulk-load. Pass empty list to skip."
  type        = list(string)
  default     = []
}

variable "aoss_collection_arns" {
  description = "AOSS collection ARNs. Pass empty list for wildcard (use only before collection exists)."
  type        = list(string)
  default     = []
}

variable "bedrock_s3_bucket_arns" {
  description = "S3 bucket ARNs that Bedrock KB reads source documents from."
  type        = list(string)
}

variable "bedrock_embedding_model_id" {
  description = "Bedrock embedding model ID"
  type        = string
  default     = "amazon.titan-embed-text-v2:0"
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}
