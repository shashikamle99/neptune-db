output "kb_id" {
  value = aws_bedrockagent_knowledge_base.graphrag_kb.id
}

output "kb_arn" {
  value = aws_bedrockagent_knowledge_base.graphrag_kb.arn
}

output "s3_bucket" {
  value = aws_s3_bucket.kb_data.bucket
}
