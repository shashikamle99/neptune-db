# outputs.tf - Complete Outputs for Neptune GraphRAG + Bedrock Setup
# All critical ARNs, endpoints, IDs, and connection strings

# ========================================
# BEDROCK KNOWLEDGE BASE OUTPUTS
# ========================================
output "knowledge_base_id" {
  description = "Bedrock Knowledge Base ID (use for Retrieve API)"
  value       = var.create_module_kb ? module.bedrock_neptune_module[0].knowledge_base_id : try(awscc_bedrock_knowledge_base.graphrag_kb[0].id, null)
}

output "knowledge_base_arn" {
  description = "Bedrock Knowledge Base ARN"
  value       = var.create_module_kb ? module.bedrock_neptune_module[0].knowledge_base_arn : try(awscc_bedrock_knowledge_base.graphrag_kb[0].attr_arn, null)
}

output "knowledge_base_name" {
  description = "Knowledge Base name"
  value       = var.kb_name
}

# ========================================
# NEPTUNE ANALYTICS GRAPH OUTPUTS
# ========================================
output "neptune_graph_id" {
  description = "Neptune Analytics Graph ID"
  value       = try(aws_neptune_graph.graphrag_graph[0].id, module.neptune_graph.neptune_graph_id, null)
}

output "neptune_graph_arn" {
  description = "Neptune Analytics Graph ARN (pass to Bedrock KB)"
  value       = try(aws_neptune_graph.graphrag_graph[0].arn, module.neptune_graph.neptune_graph_arn, null)
}

output "neptune_graph_endpoint" {
  description = "Public Gremlin endpoint for Neptune Graph"
  value       = try(aws_neptune_graph.graphrag_graph[0].endpoint_details[0].endpoint[0].endpoint, module.neptune_graph.neptune_graph_endpoint, null)
}

output "neptune_graph_port" {
  description = "Neptune Graph port"
  value       = 8182
}

output "neptune_vector_index_name" {
  description = "Vector index name used by Bedrock (auto-created)"
  value       = var.vector_index_name
}

output "neptune_embedding_dimensions" {
  description = "Embedding dimensions matching Bedrock model"
  value       = try(local.target_dimensions, var.embedding_dimensions)
}

# ========================================
# S3 DATA SOURCE OUTPUTS
# ========================================
output "s3_bucket_name" {
  description = "S3 bucket for knowledge base data"
  value       = var.create_s3_bucket ? aws_s3_bucket.kb_data[0].bucket : var.s3_bucket_name
}

output "s3_bucket_arn" {
  description = "S3 bucket ARN"
  value       = var.create_s3_bucket ? aws_s3_bucket.kb_data[0].arn : "${var.s3_bucket_name}:*"
}

output "s3_data_prefix" {
  description = "S3 folder path for uploading documents"
  value       = var.s3_data_prefix
}

output "data_source_id" {
  description = "Bedrock Data Source ID"
  value       = try(aws_bedrockagent_knowledge_base_data_source.s3_data_source[0].id, null)
}

# ========================================
# IAM OUTPUTS
# ========================================
output "bedrock_kb_role_arn" {
  description = "IAM role ARN for Bedrock Knowledge Base"
  value       = var.create_iam_role ? aws_iam_role.bedrock_kb_role[0].arn : var.kb_role_name
}

output "bedrock_kb_role_name" {
  description = "IAM role name"
  value       = var.create_iam_role ? aws_iam_role.bedrock_kb_role[0].name : null
}

output "neptune_iam_policy_arn" {
  description = "IAM policy ARN for Neptune + Bedrock integration"
  value       = try(aws_iam_policy.neptune_graph_policy[0].arn, null)
}

# ========================================
# NETWORKING & ENDPOINTS
# ========================================
output "neptune_connection_string" {
  description = "Full Gremlin connection string for Neptune Graph"
  value = try(
    "wss://${aws_neptune_graph.graphrag_graph[0].endpoint_details[0].endpoint[0].endpoint}:8182/gremlin",
    null
  )
}

output "neptune_read_endpoint" {
  description = "Neptune read endpoint (if using replicas)"
  value       = try(aws_neptune_graph.graphrag_graph[0].endpoint_details[0].endpoint[0].endpoint, null)
}

output "vpc_security_group_ids" {
  description = "Security group IDs for VPC networking"
  value       = try(aws_security_group.neptune_graph_sg[0].id, [])
}

# ========================================
# DATA INGESTION STATUS
# ========================================
output "ingestion_job_id" {
  description = "Latest ingestion job ID"
  value       = try(aws_bedrockagent_knowledge_base_ingestion_job.initial_sync[0].id, null)
}

output "data_source_status" {
  description = "Current data source sync status"
  value       = "Check AWS Console - Bedrock > Knowledge bases > Data sources"
}

# ========================================
# MONITORING OUTPUTS
# ========================================
output "cloudwatch_log_group_name" {
  description = "CloudWatch log group for Bedrock KB operations"
  value       = var.enable_cloudwatch_logs ? aws_cloudwatch_log_group.kb_logs[0].name : null
}

output "neptune_graph_notebook_url" {
  description = "SageMaker Studio Lab notebook URL for graph exploration"
  value = try(
    "https://studiolab.sagemaker.aws/import/github/aws/graph-notebook/blob/master/amazonneptune/examples/notebooks/GraphRAG/${var.project_name}.ipynb",
    null
  )
}

# ========================================
# API QUICK START COMMANDS
# ========================================
output "retrieve_api_command" {
  description = "Copy-paste AWS CLI command to test retrieval"
  value = <<-EOT
    aws bedrock-agent-runtime retrieve \\
      --knowledge-base-id ${var.create_module_kb ? "module-output" : try(awscc_bedrock_knowledge_base.graphrag_kb[0].id, "TBD")} \\
      --retrieval-query '{"text":"What are the main entities in my data?"}' \\
      --retrieval-configuration '{"vectorSearchConfiguration":{"numberOfResults":5}}'
  EOT
}

output "generate_api_command" {
  description = "RetrieveAndGenerate API command with Claude model"
  value = <<-EOT
    aws bedrock-agent-runtime retrieve-and-generate \\
      --input '{"text": "Summarize key relationships in the graph"}' \\
      --retrieve-and-generate-configuration '{
        "type": "KNOWLEDGE_BASE",
        "knowledgeBaseConfiguration": {
          "knowledgeBaseId": "${var.create_module_kb ? "module-output" : try(awscc_bedrock_knowledge_base.graphrag_kb[0].id, "TBD")}",
          "modelArn": "arn:aws:bedrock:us-east-1::foundation-model/anthropic.claude-3-sonnet-20240229-v1:0",
          "retrievalConfiguration": {"vectorSearchConfiguration": {"numberOfResults": 5}}
        }
      }'
  EOT
}

# ========================================
# SUMMARY OUTPUTS
# ========================================
output "graphrag_setup_summary" {
  description = "Complete GraphRAG infrastructure summary"
  value = <<-EOT
    🚀 GraphRAG Setup Complete!
    
    📊 Knowledge Base: ${var.kb_name} (ID: ${var.create_module_kb ? "module-output" : try(awscc_bedrock_knowledge_base.graphrag_kb[0].id, "TBD")})
    🗺️  Neptune Graph: ${local.neptune_graph_name} (${try(aws_neptune_graph.graphrag_graph[0].arn, "TBD")})
    📦 S3 Data: s3://${var.create_s3_bucket ? aws_s3_bucket.kb_data[0].bucket : var.s3_bucket_name}/${var.s3_data_prefix}
    
    🔗 Gremlin Endpoint: ${try(aws_neptune_graph.graphrag_graph[0].endpoint_details[0].endpoint[0].endpoint, "TBD")}:8182
    📏 Vector Dimensions: ${try(local.target_dimensions, var.embedding_dimensions)}
    
    Next Steps:
    1. Upload documents: aws s3 sync ./docs/ s3://${var.create_s3_bucket ? aws_s3_bucket.kb_data[0].bucket : var.s3_bucket_name}/${var.s3_data_prefix}
    2. Run sync: terraform apply (if run_initial_ingestion=true)
    3. Test: Copy 'retrieve_api_command' above
    
    Console Links:
    - Bedrock KB: https://us-east-1.console.aws.amazon.com/bedrock/home?region=us-east-1#/knowledge-base/${var.create_module_kb ? "module-output" : try(awscc_bedrock_knowledge_base.graphrag_kb[0].id, "TBD")}
    - Neptune Graph: https://us-east-1.console.aws.amazon.com/neptune-graph/home?region=us-east-1
  EOT
}

# ========================================
# JSON OUTPUT FOR CI/CD
# ========================================
output "graphrag_resources_json" {
  description = "JSON export of all GraphRAG resources"
  value = {
    knowledge_base = {
      id   = var.create_module_kb ? module.bedrock_neptune_module[0].knowledge_base_id : try(awscc_bedrock_knowledge_base.graphrag_kb[0].id, null)
      arn  = var.create_module_kb ? module.bedrock_neptune_module[0].knowledge_base_arn : try(awscc_bedrock_knowledge_base.graphrag_kb[0].attr_arn, null)
      name = var.kb_name
    }
    neptune_graph = {
      id       = try(aws_neptune_graph.graphrag_graph[0].id, null)
      arn      = try(aws_neptune_graph.graphrag_graph[0].arn, null)
      endpoint = try(aws_neptune_graph.graphrag_graph[0].endpoint_details[0].endpoint[0].endpoint, null)
    }
    s3_bucket = {
      name = var.create_s3_bucket ? aws_s3_bucket.kb_data[0].bucket : var.s3_bucket_name
      arn  = var.create_s3_bucket ? aws_s3_bucket.kb_data[0].arn : null
    }
    iam_role = var.create_iam_role ? aws_iam_role.bedrock_kb_role[0].arn : null
  }
}
