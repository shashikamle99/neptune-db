# terraform.tfvars - Override defaults here
project_name        = "my-company"
environment         = "dev"
aws_region          = "us-east-1"

s3_bucket_name      = "mycompany-graphrag-data-2026"
neptune_instance_class = "db.r6g.xlarge"
embedding_model_arn = "arn:aws:bedrock:us-east-1::foundation-model/amazon.titan-embed-text-v1:0"
embedding_dimensions = 1536

run_initial_ingestion = true
enable_cloudwatch_logs = true

tags = {
  Project     = "GraphRAG"
  Environment = "dev"
  Owner       = "data-team"
  ManagedBy   = "terraform"
}
