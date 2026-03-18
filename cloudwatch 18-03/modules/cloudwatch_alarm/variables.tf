variable "alarms" {
  description = "Map of CloudWatch alarm configurations"
  type = map(object({
    alarm_name          = string
    alarm_description   = string
    namespace           = string
    metric_name         = string
    dimensions          = map(string)
    statistic           = string
    period              = number
    evaluation_periods  = number
    threshold           = number
    comparison_operator = string
    treat_missing_data  = string
    alarm_actions       = list(string)
    ok_actions          = list(string)
    tags                = map(string)
  }))
  default = {}
}
