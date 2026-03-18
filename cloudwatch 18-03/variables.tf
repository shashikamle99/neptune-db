variable "env" {
  description = "Deployment environment (dev / uat / prod)"
  type        = string
}

variable "project" {
  description = "Project name prefix"
  type        = string
  default     = "mpg"
}

variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-2"
}

variable "sns_topic_arn" {
  description = "SNS topic ARN for alarm notifications"
  type        = string
}

# ── Neptune ────────────────────────────────────────────────────────────────────
variable "neptune_cluster_id" {
  description = "Neptune DB cluster identifier"
  type        = string
}

variable "neptune_read_latency_threshold_ms" {
  description = "Neptune read latency alarm threshold in milliseconds"
  type        = number
  default     = 200
}

variable "neptune_write_latency_threshold_ms" {
  description = "Neptune write latency alarm threshold in milliseconds"
  type        = number
  default     = 200
}

variable "neptune_serverless_capacity_threshold" {
  description = "Neptune Serverless NCU high-load threshold"
  type        = number
  default     = 80
}

# ── OpenSearch Serverless ──────────────────────────────────────────────────────
variable "aoss_collection_id" {
  description = "OpenSearch Serverless collection ID"
  type        = string
}

variable "aoss_collection_name" {
  description = "OpenSearch Serverless collection name"
  type        = string
}

variable "aoss_search_latency_threshold_ms" {
  description = "AOSS search request latency threshold in milliseconds"
  type        = number
  default     = 500
}

variable "aoss_search_ocu_threshold" {
  description = "AOSS SearchOCU high-load threshold"
  type        = number
  default     = 7
}

variable "aoss_5xx_error_threshold" {
  description = "AOSS 5xx error count threshold"
  type        = number
  default     = 10
}

# ── Bedrock Knowledge Base ─────────────────────────────────────────────────────
variable "bedrock_kb_id" {
  description = "Bedrock Knowledge Base ID"
  type        = string
}

variable "bedrock_latency_threshold_ms" {
  description = "Bedrock KB invocation latency threshold in milliseconds"
  type        = number
  default     = 3000
}

variable "bedrock_throttle_threshold" {
  description = "Bedrock KB invocation throttle count threshold"
  type        = number
  default     = 5
}

variable "bedrock_server_error_threshold" {
  description = "Bedrock KB server error count threshold"
  type        = number
  default     = 3
}
