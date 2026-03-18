# ── Neptune ───────────────────────────────────
output "neptune_role_arn"  { value = aws_iam_role.neptune.arn }
output "neptune_role_name" { value = aws_iam_role.neptune.name }
output "neptune_policy_arn" { value = aws_iam_policy.neptune.arn }

# ── OpenSearch Serverless ──────────────────────
output "aoss_role_arn"    { value = aws_iam_role.aoss.arn }
output "aoss_role_name"   { value = aws_iam_role.aoss.name }
output "aoss_policy_arn"  { value = aws_iam_policy.aoss.arn }

# ── Bedrock Knowledge Base ─────────────────────
output "bedrock_kb_role_arn"   { value = aws_iam_role.bedrock_kb.arn }
output "bedrock_kb_role_name"  { value = aws_iam_role.bedrock_kb.name }
output "bedrock_kb_policy_arn" { value = aws_iam_policy.bedrock_kb.arn }
