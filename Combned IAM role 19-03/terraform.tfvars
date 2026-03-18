project     = "mpg-dev-ai-gpt"
environment = "dev"
aws_region  = "us-east-2"

neptune_s3_bucket_arns = [
  "arn:aws:s3:::mpg-dev-ai-gpt-neptune-data",
]

# Populate after AOSS collection is created; leave empty on first apply
aoss_collection_arns = []
# aoss_collection_arns = [
#   "arn:aws:aoss:us-east-2:123456789012:collection/mpg-dev-ai-gpt-collection",
# ]

bedrock_s3_bucket_arns = [
  "arn:aws:s3:::mpg-dev-ai-gpt-kb-docs",
]

bedrock_embedding_model_id = "amazon.titan-embed-text-v2:0"

tags = {
  Owner      = "devops"
  CostCenter = "mpg"
}
