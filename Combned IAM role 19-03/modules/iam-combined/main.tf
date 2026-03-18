# ============================================================
# Combined IAM Role & Policy
# Covers: Neptune Serverless + OpenSearch Serverless + Bedrock KB
# ============================================================

# ── Trust Policy ─────────────────────────────────────────────
# All three service principals in one trust policy
data "aws_iam_policy_document" "combined_trust" {
  statement {
    sid     = "CombinedServiceTrust"
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type = "Service"
      identifiers = [
        "rds.amazonaws.com",      # Neptune
        "lambda.amazonaws.com",   # OpenSearch / app layer
        "bedrock.amazonaws.com",  # Bedrock Knowledge Base
      ]
    }

    # Confused-deputy guard — scoped to Bedrock KB ARNs in this account
    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"
      values   = [var.account_id]
    }
  }
}

resource "aws_iam_role" "combined" {
  name               = "${var.prefix}-ai-role"
  assume_role_policy = data.aws_iam_policy_document.combined_trust.json
  tags               = var.tags
}

# ── Combined Permission Policy ────────────────────────────────
data "aws_iam_policy_document" "combined_permissions" {

  # ── Neptune: S3 bulk-load (conditional) ────────────────────
  dynamic "statement" {
    for_each = length(var.neptune_s3_bucket_arns) > 0 ? [1] : []
    content {
      sid    = "NeptuneS3BulkLoad"
      effect = "Allow"
      actions = [
        "s3:GetObject",
        "s3:ListBucket",
        "s3:GetBucketLocation",
      ]
      resources = flatten([
        var.neptune_s3_bucket_arns,
        [for arn in var.neptune_s3_bucket_arns : "${arn}/*"],
      ])
    }
  }

  # ── Neptune + Bedrock: CloudWatch logs ─────────────────────
  statement {
    sid    = "CloudWatchLogs"
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:DescribeLogStreams",
    ]
    resources = [
      "arn:aws:logs:${var.aws_region}:${var.account_id}:log-group:/aws/neptune/*",
      "arn:aws:logs:${var.aws_region}:${var.account_id}:log-group:/aws/bedrock/*",
    ]
  }

  # ── OpenSearch Serverless: data-plane access ────────────────
  statement {
    sid     = "AOSSAPIAccess"
    effect  = "Allow"
    actions = ["aoss:APIAccessAll"]
    resources = length(var.aoss_collection_arns) > 0 ? var.aoss_collection_arns : ["*"]
  }

  statement {
    sid    = "AOSSDescribe"
    effect = "Allow"
    actions = [
      "aoss:DescribeCollection",
      "aoss:ListCollections",
    ]
    resources = ["*"]
  }

  # ── Bedrock KB: S3 document source ─────────────────────────
  statement {
    sid    = "BedrockKBS3Read"
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:ListBucket",
    ]
    resources = flatten([
      var.bedrock_s3_bucket_arns,
      [for arn in var.bedrock_s3_bucket_arns : "${arn}/*"],
    ])
  }

  # ── Bedrock KB: invoke embedding model ─────────────────────
  statement {
    sid    = "BedrockEmbeddingModel"
    effect = "Allow"
    actions = ["bedrock:InvokeModel"]
    resources = [
      "arn:aws:bedrock:${var.aws_region}::foundation-model/${var.bedrock_embedding_model_id}",
    ]
  }
}

resource "aws_iam_policy" "combined" {
  name        = "${var.prefix}-ai-policy"
  description = "Combined policy for Neptune Serverless, OpenSearch Serverless, and Bedrock Knowledge Base"
  policy      = data.aws_iam_policy_document.combined_permissions.json
  tags        = var.tags
}

resource "aws_iam_role_policy_attachment" "combined" {
  role       = aws_iam_role.combined.name
  policy_arn = aws_iam_policy.combined.arn
}
