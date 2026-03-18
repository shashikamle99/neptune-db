# ── Environment ───────────────────────────────────────────────────────────────
env     = "dev"
project = "mpg"
region  = "us-east-2"

# ── SNS topic (replace with your actual ARN) ────────────────────────────────
sns_topic_arn = "arn:aws:sns:us-east-2:123456789012:mpg-dev-alerts"

# ── Neptune ──────────────────────────────────────────────────────────────────
neptune_cluster_id                    = "mpg-dev-ai-gpt-neptune-cluster"
neptune_read_latency_threshold_ms     = 200
neptune_write_latency_threshold_ms    = 200
neptune_serverless_capacity_threshold = 80     # NCUs – max is 128

# ── OpenSearch Serverless ────────────────────────────────────────────────────
aoss_collection_id               = "abcdef123456"           # replace with real ID
aoss_collection_name             = "mpg-dev-ai-gpt-aoss"
aoss_search_latency_threshold_ms = 500
aoss_search_ocu_threshold        = 7                        # max default is 8 OCUs
aoss_5xx_error_threshold         = 10

# ── Bedrock Knowledge Base ───────────────────────────────────────────────────
bedrock_kb_id                  = "XXXXXXXXXX"               # replace with real KB ID
bedrock_latency_threshold_ms   = 3000
bedrock_throttle_threshold     = 5
bedrock_server_error_threshold = 3
