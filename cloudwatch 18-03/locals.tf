locals {
  prefix = "${var.project}-${var.env}"

  common_tags = {
    Project     = var.project
    Environment = var.env
    ManagedBy   = "terraform"
  }

  alarm_actions = [var.sns_topic_arn]
  ok_actions    = [var.sns_topic_arn]

  # ── Neptune Serverless Alarms ────────────────────────────────────────────────
  # Namespace  : AWS/Neptune
  # Latency    : ReadLatency / WriteLatency  (unit: Milliseconds)
  # High Load  : ServerlessDatabaseCapacity  (unit: Count – NCUs, max 128)
  # Errors     : ReadLatency spike sustained → treated as latency-error proxy
  #              (Neptune does not publish a native error-count metric)
  neptune_alarms = {

    neptune_read_latency_high = {
      alarm_name          = "${local.prefix}-neptune-read-latency-high"
      alarm_description   = "Neptune read latency exceeded ${var.neptune_read_latency_threshold_ms} ms"
      namespace           = "AWS/Neptune"
      metric_name         = "ReadLatency"
      dimensions          = { DBClusterIdentifier = var.neptune_cluster_id }
      statistic           = "Average"
      period              = 60
      evaluation_periods  = 3
      threshold           = var.neptune_read_latency_threshold_ms
      comparison_operator = "GreaterThanOrEqualToThreshold"
      treat_missing_data  = "notBreaching"
      alarm_actions       = local.alarm_actions
      ok_actions          = local.ok_actions
      tags                = merge(local.common_tags, { Service = "Neptune", AlarmType = "LatencyHigh" })
    }

    neptune_write_latency_high = {
      alarm_name          = "${local.prefix}-neptune-write-latency-high"
      alarm_description   = "Neptune write latency exceeded ${var.neptune_write_latency_threshold_ms} ms"
      namespace           = "AWS/Neptune"
      metric_name         = "WriteLatency"
      dimensions          = { DBClusterIdentifier = var.neptune_cluster_id }
      statistic           = "Average"
      period              = 60
      evaluation_periods  = 3
      threshold           = var.neptune_write_latency_threshold_ms
      comparison_operator = "GreaterThanOrEqualToThreshold"
      treat_missing_data  = "notBreaching"
      alarm_actions       = local.alarm_actions
      ok_actions          = local.ok_actions
      tags                = merge(local.common_tags, { Service = "Neptune", AlarmType = "LatencyHigh" })
    }

    neptune_high_load = {
      alarm_name          = "${local.prefix}-neptune-high-load"
      alarm_description   = "Neptune Serverless NCU capacity >= ${var.neptune_serverless_capacity_threshold} NCUs"
      namespace           = "AWS/Neptune"
      metric_name         = "ServerlessDatabaseCapacity"
      dimensions          = { DBClusterIdentifier = var.neptune_cluster_id }
      statistic           = "Maximum"
      period              = 60
      evaluation_periods  = 2
      threshold           = var.neptune_serverless_capacity_threshold
      comparison_operator = "GreaterThanOrEqualToThreshold"
      treat_missing_data  = "notBreaching"
      alarm_actions       = local.alarm_actions
      ok_actions          = local.ok_actions
      tags                = merge(local.common_tags, { Service = "Neptune", AlarmType = "HighLoad" })
    }

    neptune_latency_error = {
      alarm_name          = "${local.prefix}-neptune-latency-error"
      alarm_description   = "Neptune p99 write latency critically high – possible error storm (>= ${var.neptune_write_latency_threshold_ms * 5} ms)"
      namespace           = "AWS/Neptune"
      metric_name         = "WriteLatency"
      dimensions          = { DBClusterIdentifier = var.neptune_cluster_id }
      statistic           = "p99"
      period              = 60
      evaluation_periods  = 2
      threshold           = var.neptune_write_latency_threshold_ms * 5
      comparison_operator = "GreaterThanOrEqualToThreshold"
      treat_missing_data  = "notBreaching"
      alarm_actions       = local.alarm_actions
      ok_actions          = local.ok_actions
      tags                = merge(local.common_tags, { Service = "Neptune", AlarmType = "LatencyError" })
    }
  }

  # ── OpenSearch Serverless Alarms ─────────────────────────────────────────────
  # Namespace  : AWS/AOSS
  # Latency    : SearchRequestTime  (unit: Milliseconds)
  # High Load  : SearchOCU          (unit: Count – OCU consumption)
  # Errors     : 5xx                (unit: Count – server-side HTTP errors)
  aoss_alarms = {

    aoss_search_latency_high = {
      alarm_name          = "${local.prefix}-aoss-search-latency-high"
      alarm_description   = "AOSS search request latency exceeded ${var.aoss_search_latency_threshold_ms} ms"
      namespace           = "AWS/AOSS"
      metric_name         = "SearchRequestTime"
      dimensions          = { CollectionId = var.aoss_collection_id, CollectionName = var.aoss_collection_name }
      statistic           = "Average"
      period              = 60
      evaluation_periods  = 3
      threshold           = var.aoss_search_latency_threshold_ms
      comparison_operator = "GreaterThanOrEqualToThreshold"
      treat_missing_data  = "notBreaching"
      alarm_actions       = local.alarm_actions
      ok_actions          = local.ok_actions
      tags                = merge(local.common_tags, { Service = "AOSS", AlarmType = "LatencyHigh" })
    }

    aoss_indexing_latency_high = {
      alarm_name          = "${local.prefix}-aoss-indexing-latency-high"
      alarm_description   = "AOSS indexing request latency exceeded ${var.aoss_search_latency_threshold_ms} ms"
      namespace           = "AWS/AOSS"
      metric_name         = "IndexingRequestTime"
      dimensions          = { CollectionId = var.aoss_collection_id, CollectionName = var.aoss_collection_name }
      statistic           = "Average"
      period              = 60
      evaluation_periods  = 3
      threshold           = var.aoss_search_latency_threshold_ms
      comparison_operator = "GreaterThanOrEqualToThreshold"
      treat_missing_data  = "notBreaching"
      alarm_actions       = local.alarm_actions
      ok_actions          = local.ok_actions
      tags                = merge(local.common_tags, { Service = "AOSS", AlarmType = "LatencyHigh" })
    }

    aoss_high_load = {
      alarm_name          = "${local.prefix}-aoss-high-load"
      alarm_description   = "AOSS SearchOCU consumption >= ${var.aoss_search_ocu_threshold} OCUs"
      namespace           = "AWS/AOSS"
      metric_name         = "SearchOCU"
      dimensions          = { CollectionId = var.aoss_collection_id, CollectionName = var.aoss_collection_name }
      statistic           = "Maximum"
      period              = 60
      evaluation_periods  = 2
      threshold           = var.aoss_search_ocu_threshold
      comparison_operator = "GreaterThanOrEqualToThreshold"
      treat_missing_data  = "notBreaching"
      alarm_actions       = local.alarm_actions
      ok_actions          = local.ok_actions
      tags                = merge(local.common_tags, { Service = "AOSS", AlarmType = "HighLoad" })
    }

    aoss_5xx_errors = {
      alarm_name          = "${local.prefix}-aoss-5xx-errors"
      alarm_description   = "AOSS 5xx server errors >= ${var.aoss_5xx_error_threshold} in 1 minute"
      namespace           = "AWS/AOSS"
      metric_name         = "5xx"
      dimensions          = { CollectionId = var.aoss_collection_id, CollectionName = var.aoss_collection_name }
      statistic           = "Sum"
      period              = 60
      evaluation_periods  = 2
      threshold           = var.aoss_5xx_error_threshold
      comparison_operator = "GreaterThanOrEqualToThreshold"
      treat_missing_data  = "notBreaching"
      alarm_actions       = local.alarm_actions
      ok_actions          = local.ok_actions
      tags                = merge(local.common_tags, { Service = "AOSS", AlarmType = "LatencyError" })
    }
  }

  # ── Bedrock Knowledge Base Alarms ────────────────────────────────────────────
  # Namespace  : AWS/Bedrock
  # Latency    : InvocationLatency   (unit: Milliseconds)
  # High Load  : InvocationThrottles (unit: Count)
  # Errors     : InvocationServerErrors / InvocationClientErrors (unit: Count)
  bedrock_alarms = {

    bedrock_kb_latency_high = {
      alarm_name          = "${local.prefix}-bedrock-kb-latency-high"
      alarm_description   = "Bedrock KB invocation latency exceeded ${var.bedrock_latency_threshold_ms} ms"
      namespace           = "AWS/Bedrock"
      metric_name         = "InvocationLatency"
      dimensions          = { KnowledgeBaseId = var.bedrock_kb_id }
      statistic           = "Average"
      period              = 60
      evaluation_periods  = 3
      threshold           = var.bedrock_latency_threshold_ms
      comparison_operator = "GreaterThanOrEqualToThreshold"
      treat_missing_data  = "notBreaching"
      alarm_actions       = local.alarm_actions
      ok_actions          = local.ok_actions
      tags                = merge(local.common_tags, { Service = "Bedrock", AlarmType = "LatencyHigh" })
    }

    bedrock_kb_high_load = {
      alarm_name          = "${local.prefix}-bedrock-kb-high-load"
      alarm_description   = "Bedrock KB invocation throttles >= ${var.bedrock_throttle_threshold} – request rate too high"
      namespace           = "AWS/Bedrock"
      metric_name         = "InvocationThrottles"
      dimensions          = { KnowledgeBaseId = var.bedrock_kb_id }
      statistic           = "Sum"
      period              = 60
      evaluation_periods  = 2
      threshold           = var.bedrock_throttle_threshold
      comparison_operator = "GreaterThanOrEqualToThreshold"
      treat_missing_data  = "notBreaching"
      alarm_actions       = local.alarm_actions
      ok_actions          = local.ok_actions
      tags                = merge(local.common_tags, { Service = "Bedrock", AlarmType = "HighLoad" })
    }

    bedrock_kb_server_errors = {
      alarm_name          = "${local.prefix}-bedrock-kb-server-errors"
      alarm_description   = "Bedrock KB server-side errors >= ${var.bedrock_server_error_threshold}"
      namespace           = "AWS/Bedrock"
      metric_name         = "InvocationServerErrors"
      dimensions          = { KnowledgeBaseId = var.bedrock_kb_id }
      statistic           = "Sum"
      period              = 60
      evaluation_periods  = 2
      threshold           = var.bedrock_server_error_threshold
      comparison_operator = "GreaterThanOrEqualToThreshold"
      treat_missing_data  = "notBreaching"
      alarm_actions       = local.alarm_actions
      ok_actions          = local.ok_actions
      tags                = merge(local.common_tags, { Service = "Bedrock", AlarmType = "LatencyError" })
    }

    bedrock_kb_client_errors = {
      alarm_name          = "${local.prefix}-bedrock-kb-client-errors"
      alarm_description   = "Bedrock KB client-side errors >= ${var.bedrock_server_error_threshold}"
      namespace           = "AWS/Bedrock"
      metric_name         = "InvocationClientErrors"
      dimensions          = { KnowledgeBaseId = var.bedrock_kb_id }
      statistic           = "Sum"
      period              = 60
      evaluation_periods  = 2
      threshold           = var.bedrock_server_error_threshold
      comparison_operator = "GreaterThanOrEqualToThreshold"
      treat_missing_data  = "notBreaching"
      alarm_actions       = local.alarm_actions
      ok_actions          = local.ok_actions
      tags                = merge(local.common_tags, { Service = "Bedrock", AlarmType = "LatencyError" })
    }
  }
}
