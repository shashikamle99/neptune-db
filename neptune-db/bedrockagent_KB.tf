resource "aws_bedrockagent_knowledge_base_data_source" "s3_data_source" {
  knowledge_base_id = aws_bedrockagent_knowledge_base.graphrag_kb.id
  name              = "s3-datasource"

  data_source_configuration {
    type = "S3"
    s3_configuration {
      bucket_arn = aws_s3_bucket.kb_data.arn
      inclusion_prefixes = ["/data/"]
    }
  }
}

resource "aws_bedrockagent_knowledge_base_ingestion_job" "initial_sync" {
  knowledge_base_id = aws_bedrockagent_knowledge_base.graphrag_kb.id
  data_source_id    = aws_bedrockagent_knowledge_base_data_source.s3_data_source.id
  description       = "Initial data sync"
  
  depends_on = [aws_bedrockagent_knowledge_base_data_source.s3_data_source]
}
