output "neptune_alarm_arns" {
  description = "ARNs of Neptune CloudWatch alarms"
  value       = module.neptune_alarms.alarm_arns
}

output "aoss_alarm_arns" {
  description = "ARNs of OpenSearch Serverless CloudWatch alarms"
  value       = module.aoss_alarms.alarm_arns
}

output "bedrock_alarm_arns" {
  description = "ARNs of Bedrock Knowledge Base CloudWatch alarms"
  value       = module.bedrock_alarms.alarm_arns
}

output "all_alarm_names" {
  description = "All alarm names across all services"
  value = concat(
    module.neptune_alarms.alarm_names,
    module.aoss_alarms.alarm_names,
    module.bedrock_alarms.alarm_names
  )
}
