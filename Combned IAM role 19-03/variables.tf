variable "project" {
  description = "Project name (e.g. mpg-dev-ai-gpt)"
  type        = string
}

variable "environment" {
  description = "Deployment environment"
  type        = string
  validation {
    condition     = contains(["dev", "uat", "prod"], var.environment)
    error_message = "Must be one of: dev, uat, prod."
  }
}

variable "aws_region" {
  type    = string
  default = "us-east-2"
}

variable "neptune_s3_bucket_arns" {
  type    = list(string)
  default = []
}

variable "aoss_collection_arns" {
  type    = list(string)
  default = []
}

variable "bedrock_s3_bucket_arns" {
  type = list(string)
}

variable "bedrock_embedding_model_id" {
  type    = string
  default = "amazon.titan-embed-text-v2:0"
}

variable "tags" {
  type    = map(string)
  default = {}
}
