# main.tf - Complete Neptune Analytics + Bedrock GraphRAG Setup
# Uses native AWS provider + aws-ia/terraform-aws-bedrock module approach

terraform {
  required_version = ">= 1.3"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.70"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
    awscc = {
      source  = "hashicorp/awscc"
      version = "~> 0.60"
    }
  }
}

# Data sources
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

# Random suffix for unique names
resource "random_id" "suffix" {
  byte_length = 4
}

# ========================================
# S3 BUCKET FOR DATA SOURCE
# ========================================
resource "aws_s3_bucket" "kb_data" {
  count  = var.create_s3_bucket ? 1 : 0
  bucket = var.s3_bucket_name != "" ? var.s3_bucket_name : "bedrock-kb-${var.project_name}-${var.environment}-${random_id.suffix.hex}"
}

resource "aws_s3_bucket_ownership_controls" "kb_data" {
  count  = var.create_s3_bucket ? 1 : 0
  bucket = aws_s3_bucket.kb_data[0].id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "kb_data" {
  count     = var.create_s3_bucket ? 1 : 0
  depends_on = [aws_s3_bucket_ownership_controls.kb_data]
  bucket    = aws_s3_bucket.kb_data[0].id
  acl       = "private"
}

resource "aws_s3_bucket_versioning" "kb_data" {
  count  = var.create_s3_bucket ? 1 : 0
  bucket = aws_s3_bucket.kb_data[0].id
  versioning_configuration {
    status = "Enabled"
  }
}

# ========================================
# IAM ROLE FOR BEDROCK KNOWLEDGE BASE
# ========================================
resource "aws_iam_role" "bedrock_kb_role" {
  count = var.create_iam_role ? 1 : 0
  name  = "${var.project_name}-${var.kb_role_name}-${random_id.suffix.hex}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = [
            "bedrock.amazonaws.com",
            "neptune.amazonaws.com",
            "neptune-analytics.amazonaws.com"
          ]
        }
      }
    ]
  })

  tags = merge(var.tags, {
    Name = "${var.project_name}-${var.kb_role_name}"
  })
}

resource "aws_iam_role_policy" "bedrock_kb_policy" {
  count = var.create_iam_role ? 1 : 0
  name  = "bedrock-kb-policy"
  role  = aws_iam_role.bedrock_kb_role[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "neptune-db:*",
          "neptune-analytics:*",
          "neptune-graph:*"
        ]
        Resource = ["*"]
      },
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject*",
          "s3:GetBucket*",
          "s3:List*",
          "s3:DeleteObject*"
        ]
        Resource = [
          var.create_s3_bucket ? aws_s3_bucket.kb_data[0].arn : var.s3_bucket_name,
          "${var.create_s3_bucket ? aws_s3_bucket.kb_data[0].arn : var.s3_bucket_name}/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = var.enable_cloudwatch_logs ? "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:${var.log_group_name}:*" : []
      },
      {
        Effect = "Allow"
        Action = [
          "bedrock:InvokeModel",
          "bedrock:*Permission"
        ]
        Resource = [
          "*",
          "arn:aws:bedrock:${data.aws_region.current.name}::foundation-model/amazon.titan-embed-text-v*"
        ]
      }
    ]
  })
}

# ========================================
# NEPTUNE ANALYTICS CLUSTER (VECTOR STORE)
# ========================================
resource "aws_neptune_graph" "kb_neptune_graph" {
  count         = var.create_neptune_analytics ? 1 : 0
  graph_name    = "${var.neptune_cluster_name}-${random_id.suffix.hex}"
  engine_target = "neptune"

  endpoint_details {
    endpoint {
      port      = 8182
      endpoint  = "${var.neptune_cluster_name}-${random_id.suffix.hex}.${data.aws_region.current.name}.neptune-graph.amazonaws.com"
      transport = "TCP"
    }
  }

  graph_notebook_properties {
    default_provenance_setting = "ENABLED"
    notebook_properties {
      notebook_creation_status = "ENABLED"
    }
  }

  tags = merge(var.tags, {
    Name = var.neptune_cluster_name
  })
}

# Wait for Neptune Graph to be ready
resource "time_sleep" "wait_neptune_ready" {
  count           = var.create_neptune_analytics ? 1 : 0
  depends_on      = [aws_neptune_graph.kb_neptune_graph]
  create_duration = "300s"
}

# ========================================
# BEDROCK KNOWLEDGE BASE (NATIVE + MODULE APPROACH)
# ========================================

# Option 1: Using awscc provider (CloudFormation) for GraphRAG support
resource "awscc_bedrock_knowledge_base" "graphrag_kb" {
  count = var.create_module_kb ? 0 : 1

  name        = "${var.project_name}-${var.kb_name}-${random_id.suffix.hex}"
  description = var.kb_description
  role_arn    = var.create_iam_role ? aws_iam_role.bedrock_kb_role[0].arn : var.kb_role_name

  knowledge_base_configuration {
    type = var.kb_type
    vector_knowledge_base_configuration {
      embedding_model_arn = var.embedding_model_arn
      embedding_model_configuration {
        bedrock_embedding_model_configuration {
          dimensions      = var.embedding_dimensions
          embedding_data_type = "FLOAT"
        }
      }
    }
  }

  storage_configuration {
    type = "NEPTUNE_ANALYTICS"
    neptune_analytics_configuration {
      graph_arn = var.create_neptune_analytics ? aws_neptune_graph.kb_neptune_graph[0].arn : var.neptune_cluster_arn
      field_mapping {
        vector_field   = var.neptune_vector_field
        text_field     = var.neptune_text_field
        metadata_field = var.neptune_metadata_field
      }
      vector_index_name = var.vector_index_name
    }
  }

  tags = var.tags

  depends_on = [
    aws_iam_role_policy.bedrock_kb_policy,
    time_sleep.wait_neptune_ready
  ]
}

# ========================================
# S3 DATA SOURCE
# ========================================
resource "aws_bedrockagent_knowledge_base_data_source" "s3_data_source" {
  count           = var.create_data_source ? 1 : 0
  knowledge_base_id = var.create_module_kb ? "" : awscc_bedrock_knowledge_base.graphrag_kb[0].id
  name            = "${var.project_name}-${var.data_source_name}-${random_id.suffix.hex}"

  data_source_configuration {
    type = "S3"
    s3_configuration {
      bucket_arn     = var.create_s3_bucket ? aws_s3_bucket.kb_data[0].arn : var.s3_bucket_name
      inclusion_prefixes = [var.s3_data_prefix]
    }
  }

  depends_on = [awscc_bedrock_knowledge_base.graphrag_kb]
}

# ========================================
# INITIAL INGESTION JOB
# ========================================
resource "aws_bedrockagent_knowledge_base_ingestion_job" "initial_sync" {
  count           = var.run_initial_ingestion && var.create_data_source ? 1 : 0
  knowledge_base_id = awscc_bedrock_knowledge_base.graphrag_kb[0].id
  data_source_id    = aws_bedrockagent_knowledge_base_data_source.s3_data_source[0].id
  description       = "Initial GraphRAG data sync from S3"

  depends_on = [aws_bedrockagent_knowledge_base_data_source.s3_data_source]
}

# ========================================
# CLOUDWATCH LOG GROUP (OPTIONAL)
# ========================================
resource "aws_cloudwatch_log_group" "kb_logs" {
  count             = var.enable_cloudwatch_logs ? 1 : 0
  name              = "${var.log_group_name}-${random_id.suffix.hex}"
  retention_in_days = 7

  tags = var.tags
}

# ========================================
# MODULE APPROACH (ALTERNATIVE)
# ========================================
module "bedrock_neptune_module" {
  count  = var.create_module_kb ? 1 : 0
  source = "aws-ia/bedrock/aws"
  version = var.module_version

  create_neptune_analytics_config = var.create_neptune_analytics
  create_s3_data_source           = var.create_data_source
  create_default_kb               = true

  # S3 Configuration
  s3_bucket_name = var.s3_bucket_name

  # Embeddings
  kb_embedding_model_arn     = var.embedding_model_arn
  embedding_model_dimensions = var.embedding_dimensions

  # Neptune Configuration
  neptune_cluster_arn = aws_neptune_graph.kb_neptune_graph[0].arn
  vector_index_name   = var.vector_index_name

  # IAM
  kb_role_arn = aws_iam_role.bedrock_kb_role[0].arn

  tags = var.tags
}

# ========================================
# OUTPUTS
# ========================================
output "knowledge_base_id" {
  description = "Bedrock Knowledge Base ID"
  value       = var.create_module_kb ? module.bedrock_neptune_module[0].knowledge_base_id : awscc_bedrock_knowledge_base.graphrag_kb[0].id
}

output "knowledge_base_arn" {
  description = "Bedrock Knowledge Base ARN"
  value       = var.create_module_kb ? module.bedrock_neptune_module[0].knowledge_base_arn : awscc_bedrock_knowledge_base.graphrag_kb[0].attr_arn
}

output "neptune_graph_arn" {
  description = "Neptune Analytics Graph ARN"
  value       = var.create_neptune_analytics ? aws_neptune_graph.kb_neptune_graph[0].arn : null
}

output "neptune_graph_endpoint" {
  description = "Neptune Analytics Graph endpoint"
  value       = var.create_neptune_analytics ? aws_neptune_graph.kb_neptune_graph[0].endpoint_details[0].endpoint[0].endpoint : null
}

output "s3_bucket_name" {
  description = "S3 bucket for data source"
  value       = var.create_s3_bucket ? aws_s3_bucket.kb_data[0].bucket : var.s3_bucket_name
}

output "iam_role_arn" {
  description = "Bedrock KB IAM Role ARN"
  value       = var.create_iam_role ? aws_iam_role.bedrock_kb_role[0].arn : null
}
