module "bedrock_neptune_kb" {
  source  = "aws-ia/bedrock/aws"
  version = "0.0.31"

  create_neptune_analytics_config = true
  create_s3_data_source           = true
  create_default_kb               = true  # Creates Neptune GraphRAG KB
  
  # S3 data
  s3_bucket_name                  = "my-kb-data-tf"
  
  # Embeddings
  kb_embedding_model_arn          = "arn:aws:bedrock:us-east-1::foundation-model/amazon.titan-embed-text-v2:0"
  embedding_model_dimensions      = 1536
  
  # Neptune config
  neptune_cluster_arn             = aws_neptune_cluster.kb_neptune.arn
}
