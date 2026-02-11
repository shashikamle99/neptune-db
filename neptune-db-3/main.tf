module "neptune_graph" {
  source = "./neptune-graph.tf"
  
  project_name     = var.project_name
  environment      = var.environment
  aws_region       = var.aws_region
  embedding_model_arn = var.embedding_model_arn
  create_neptune_graph = true
  
  tags             = var.tags
}

# Reference in Bedrock KB
resource "awscc_bedrock_knowledge_base" "kb" {
  # ...
  storage_configuration {
    type = "NEPTUNE_ANALYTICS"
    neptune_analytics_configuration {
      graph_arn = module.neptune_graph.neptune_graph_arn
      vector_index_name = module.neptune_graph.neptune_vector_index_name
    }
  }
}
