resource "aws_bedrockagent_knowledge_base" "graphrag_kb" {
  name        = "neptune-graphrag-kb"
  description = "GraphRAG KB with Neptune Analytics"
  role_arn    = aws_iam_role.bedrock_kb_role.arn

  knowledge_base_configuration {
    type = "GRAPH"  # For GraphRAG with Neptune
    graph_knowledge_base_configuration {
      vector_knowledge_base_configuration {
        embedding_model_arn = "arn:aws:bedrock:us-east-1::foundation-model/amazon.titan-embed-text-v2:0"
      }
    }
  }

  storage_configuration {
    type = "NEPTUNE_ANALYTICS"
    neptune_analytics_configuration {
      cluster_arn          = aws_neptune_cluster.kb_neptune.arn
      vector_index_name    = "bedrock-graph-index"
      field_mapping = {
        vector_field     = "embedding"
        text_field       = "text"
        metadata_field   = "metadata"
      }
    }
  }

  depends_on = [aws_iam_role_policy.bedrock_kb_policy]
}
