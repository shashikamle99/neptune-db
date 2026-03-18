output "alarm_arns" {
  description = "Map of alarm name to ARN"
  value       = { for k, v in aws_cloudwatch_metric_alarm.this : k => v.arn }
}

output "alarm_names" {
  description = "List of all created alarm names"
  value       = [for v in aws_cloudwatch_metric_alarm.this : v.alarm_name]
}
