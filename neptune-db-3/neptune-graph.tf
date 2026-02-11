# neptune-graph.tf - Neptune Analytics Graph for GraphRAG + Bedrock Embeddings
# Dedicated module for Neptune Analytics vector/graph storage

# ========================================
# LOCALS FOR NEPTUNE CONFIG
# ========================================
locals {
  neptune_graph_name = "${var.project_name}-graphrag-${var.environment}-${random_id.suffix.hex}"
  
  # Bedrock embedding dimensions mapping
  embedding_config = {
    "amazon.titan-embed-text-v1:0"  = { dimensions = 1536 }
    "amazon.titan-embed-text-v2:0"  = { dimensions = 1024 }
    "amazon.titan-embed-text-v3:0"  = { dimensions = 1024 }
    "cohere.embed-english-v3:0"     = { dimensions = 1024 }
  }
  
  target_dimensions = lookup(
    lookup(local.embedding_config, regex("foundation-model/(.+):\\d+", var.embedding_model_arn)[0], 
    { dimensions = var.embedding_dimensions }),
    "dimensions",
    var.embedding_dimensions
  )
}

# ========================================
# NEPTUNE ANALYTICS GRAPH CLUSTER
# ========================================
resource "aws_neptune_graph" "graphrag_graph" {
  count      = var.create_neptune_graph ? 1 : 0
  graph_name = local.neptune_graph_name

  engine_target = "neptune"
  neptune_version = var.neptune_version

  # Graph notebook properties for GraphRAG exploration
  graph_notebook_properties {
    default_provenance_setting = "ENABLED"
    notebook_properties {
      notebook_creation_status = "ENABLED"
    }
  }

  # Public endpoint (use VPC endpoints for production)
  endpoint_details {
    endpoint {
      port     = 8182
      endpoint = "${local.neptune_graph_name}.${var.aws_region}.neptune-graph.amazonaws.com"
      transport = "TCP"
    }
  }

  # Tags
  tags = merge(var.tags, {
    Name            = "${var.project_name}-graphrag-graph"
    GraphRAG        = "enabled"
    BedrockKB       = var.kb_name
    Environment     = var.environment
    ManagedBy       = "terraform"
  })
}

# ========================================
# NEPTUNE VECTOR INDEX (CREATED BY BEDROCK)
# ========================================
# Note: Bedrock Knowledge Base auto-creates vector index during sync
# This resource manages the index explicitly for advanced use cases

resource "aws_neptune_graph_ml_data_catalog" "graphrag_catalog" {
  count    = var.create_neptune_graph && var.manage_vector_index ? 1 : 0
  graph_id = aws_neptune_graph.graphrag_graph[0].id
  name     = "${var.project_name}-graphrag-catalog"

  storage_properties {
    s3_object_encryption {
      kms_key_id = var.kms_key_id
    }
  }
}

# ========================================
# IAM AUTH FOR NEPTUNE + BEDROCK INTEGRATION
# ========================================
resource "aws_iam_policy" "neptune_graph_policy" {
  count = var.create_neptune_graph ? 1 : 0
  name  = "${var.project_name}-neptune-graph-policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "neptune-graph:*",
          "neptune-db:*",
          "neptune-analytics:*",
          "neptune-graph-ml:*"
        ]
        Resource = [
          aws_neptune_graph.graphrag_graph[0].arn,
          aws_neptune_graph.graphrag_graph[0].arn + "/*"
        ]
      },
      # Bedrock embedding model access
      {
        Effect = "Allow"
        Action = [
          "bedrock:InvokeModel",
          "bedrock:InvokeModelWithResponseStream"
        ]
        Resource = [
          var.embedding_model_arn,
          "arn:aws:bedrock:${var.aws_region}::foundation-model/amazon.titan-embed-text-*"
        ]
      },
      # S3 for data import/export
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:ListBucket"
        ]
        Resource = [
          aws_s3_bucket.kb_data[0].arn,
          "${aws_s3_bucket.kb_data[0].arn}/*"
        ]
      }
    ]
  })
}

# Attach Neptune policy to Bedrock KB role
resource "aws_iam_role_policy_attachment" "neptune_bedrock_attachment" {
  count      = var.create_neptune_graph && var.create_iam_role ? 1 : 0
  role       = aws_iam_role.bedrock_kb_role[0].name
  policy_arn = aws_iam_policy.neptune_graph_policy[0].arn

  depends_on = [
    aws_iam_policy.neptune_graph_policy,
    aws_iam_role.bedrock_kb_role
  ]
}

# ========================================
# GRAPH SCHEMA FOR ENTITY EXTRACTION (OPTIONAL)
# ========================================
resource "local_file" "graph_schema" {
  count    = var.create_neptune_graph && length(var.graph_schema) > 0 ? 1 : 0
  filename = "${path.module}/graph-schema-${random_id.suffix.hex}.gremlin"
  content  = templatefile("${path.module}/templates/graph-schema.tpl", {
    schema_definition = var.graph_schema
    vector_dimensions = local.target_dimensions
    vector_field     = var.neptune_vector_field
  })
}

# ========================================
# SECURITY GROUP FOR VPC ENDPOINT (OPTIONAL)
# ========================================
resource "aws_security_group" "neptune_graph_sg" {
  count       = var.create_neptune_graph && length(var.vpc_id) > 0 ? 1 : 0
  name_prefix = "${var.project_name}-neptune-graph-"
  vpc_id      = var.vpc_id

  ingress {
    description = "Neptune GraphRAG port"
    from_port   = 8182
    to_port     = 8182
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name = "${var.project_name}-neptune-graph-sg"
  })
}

# ========================================
# DEPENDENCY WAITER
# ========================================
resource "time_sleep" "wait_graph_ready" {
  count           = var.create_neptune_graph ? 1 : 0
  depends_on      = [aws_neptune_graph.graphrag_graph]
  create_duration = "300s"
  destroy_duration = "300s"
}

# ========================================
# OUTPUTS
# ========================================
output "neptune_graph_id" {
  description = "Neptune Analytics Graph ID"
  value       = var.create_neptune_graph ? aws_neptune_graph.graphrag_graph[0].id : null
}

output "neptune_graph_arn" {
  description = "Neptune Analytics Graph ARN"
  value       = var.create_neptune_graph ? aws_neptune_graph.graphrag_graph[0].arn : null
}

output "neptune_graph_endpoint" {
  description = "Neptune Graph endpoint for Gremlin queries"
  value       = var.create_neptune_graph ? aws_neptune_graph.graphrag_graph[0].endpoint_details[0].endpoint[0].endpoint : null
}

output "neptune_vector_index_name" {
  description = "Recommended vector index name for Bedrock KB"
  value       = var.vector_index_name
}

output "neptune_embedding_dimensions" {
  description = "Embeddings dimensions matching Bedrock model"
  value       = local.target_dimensions
}

output "neptune_iam_policy_arn" {
  description = "IAM policy for Neptune + Bedrock integration"
  value       = var.create_neptune_graph ? aws_iam_policy.neptune_graph_policy[0].arn : null
}
