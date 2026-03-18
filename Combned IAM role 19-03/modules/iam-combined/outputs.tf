output "role_arn" {
  description = "ARN of the combined IAM role"
  value       = aws_iam_role.combined.arn
}

output "role_name" {
  description = "Name of the combined IAM role"
  value       = aws_iam_role.combined.name
}

output "policy_arn" {
  description = "ARN of the combined IAM policy"
  value       = aws_iam_policy.combined.arn
}
