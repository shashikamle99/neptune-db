# ============================================================
# Single IAM Module
# Creates roles & policies for:
#   1. Neptune Serverless DB
#   2. OpenSearch Serverless (AOSS)
#   3. Bedrock Knowledge Base
# ============================================================

# ────────────────────────────────────────────────────────────
# 1. NEPTUNE SERVERLESS
# ────────────────────────────────────────────────────────────
data "aws_iam_policy_document" "neptune_trust" {
  statement {
    sid     = "NeptuneTrust"
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["rds.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "neptune" {
  name               = "${var.prefix}-neptune-role"
  assume_role_policy = data.aws_iam_policy_document.neptune_trust.json
  tags               = var.tags
}

data "aws_iam_policy_document" "neptune_permissions" {
  # S3 bulk-load (conditional)
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

  # CloudWatch logs
  statement {
    sid    = "NeptuneCloudWatch"
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:DescribeLogStreams",
    ]
    resources = ["arn:aws:logs:${var.aws_region}:${var.account_id}:log-group:/aws/neptune/*"]
  }
}

resource "aws_iam_policy" "neptune" {
  name        = "${var.prefix}-neptune-policy"
  description = "Permissions for Neptune Serverless DB"
  policy      = data.aws_iam_policy_document.neptune_permissions.json
  tags        = var.tags
}

resource "aws_iam_role_policy_attachment" "neptune" {
  role       = aws_iam_role.neptune.name
  policy_arn = aws_iam_policy.neptune.arn
}

# ────────────────────────────────────────────────────────────
# 2. OPENSEARCH SERVERLESS (AOSS)
# ────────────────────────────────────────────────────────────
data "aws_iam_policy_document" "aoss_trust" {
  statement {
    sid     = "AOSSTrust"
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com", "bedrock.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "aoss" {
  name               = "${var.prefix}-aoss-role"
  assume_role_policy = data.aws_iam_policy_document.aoss_trust.json
  tags               = var.tags
}

data "aws_iam_policy_document" "aoss_permissions" {
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
}

resource "aws_iam_policy" "aoss" {
  name        = "${var.prefix}-aoss-policy"
  description = "Data-plane access to OpenSearch Serverless collection"
  policy      = data.aws_iam_policy_document.aoss_permissions.json
  tags        = var.tags
}

resource "aws_iam_role_policy_attachment" "aoss" {
  role       = aws_iam_role.aoss.name
  policy_arn = aws_iam_policy.aoss.arn
}

# ────────────────────────────────────────────────────────────
# 3. BEDROCK KNOWLEDGE BASE
# ────────────────────────────────────────────────────────────
data "aws_iam_policy_document" "bedrock_kb_trust" {
  statement {
    sid     = "BedrockKBTrust"
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["bedrock.amazonaws.com"]
    }

    # Confused-deputy protection
    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"
      values   = [var.account_id]
    }

    condition {
      test     = "ArnLike"
      variable = "aws:SourceArn"
      values   = ["arn:aws:bedrock:${var.aws_region}:${var.account_id}:knowledge-base/*"]
    }
  }
}

resource "aws_iam_role" "bedrock_kb" {
  name               = "${var.prefix}-bedrock-kb-role"
  assume_role_policy = data.aws_iam_policy_document.bedrock_kb_trust.json
  tags               = var.tags
}

data "aws_iam_policy_document" "bedrock_kb_permissions" {
  # S3: read documents from KB data source
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

  # AOSS: read/write vector index
  statement {
    sid     = "BedrockKBAOSS"
    effect  = "Allow"
    actions = ["aoss:APIAccessAll"]
    resources = length(var.aoss_collection_arns) > 0 ? var.aoss_collection_arns : ["*"]
  }

  # Bedrock: invoke embedding model
  statement {
    sid    = "BedrockEmbeddingModel"
    effect = "Allow"
    actions = ["bedrock:InvokeModel"]
    resources = [
      "arn:aws:bedrock:${var.aws_region}::foundation-model/${var.bedrock_embedding_model_id}",
    ]
  }

  # CloudWatch: ingestion job logs
  statement {
    sid    = "BedrockKBCloudWatch"
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]
    resources = ["arn:aws:logs:${var.aws_region}:${var.account_id}:log-group:/aws/bedrock/*"]
  }
}

resource "aws_iam_policy" "bedrock_kb" {
  name        = "${var.prefix}-bedrock-kb-policy"
  description = "Permissions for Bedrock Knowledge Base (S3 + AOSS + embedding model)"
  policy      = data.aws_iam_policy_document.bedrock_kb_permissions.json
  tags        = var.tags
}

resource "aws_iam_role_policy_attachment" "bedrock_kb" {
  role       = aws_iam_role.bedrock_kb.name
  policy_arn = aws_iam_policy.bedrock_kb.arn
}
