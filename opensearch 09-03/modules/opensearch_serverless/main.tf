################################################################################
# Module: opensearch_serverless
# Resources:
#   - Encryption Policy
#   - OpenSearch Serverless Collection
#   - Network Policy
#   - VPC Endpoint
#   - Data Access Policy
################################################################################

locals {
  collection_name         = var.collection_name
  encryption_policy_name  = var.encryption_policy_name
  network_policy_name     = var.network_policy_name
  vpc_endpoint_name       = var.vpc_endpoint_name
  data_access_policy_name = var.data_access_policy_name
}


# 1. Encryption Policy

resource "aws_opensearchserverless_security_policy" "encryption" {
  name        = local.encryption_policy_name
  type        = "encryption"
  description = "Encryption policy for ${local.collection_name} collection"

  policy = jsonencode({
    Rules = [
      {
        Resource     = ["collection/${local.collection_name}"]
        ResourceType = "collection"
      }
    ]
    AWSOwnedKey = var.kms_key_arn == null ? true : false
    # If a customer-managed KMS key is provided, attach it
    KmsARN = var.kms_key_arn != null ? var.kms_key_arn : null
  })
}


# 2. OpenSearch Serverless Collection

resource "aws_opensearchserverless_collection" "this" {
  name             = local.collection_name
  description      = var.collection_description
  type             = var.collection_type
  standby_replicas = var.standby_replicas

  tags = var.tags

  # Collection depends on encryption policy existing first
  depends_on = [
    aws_opensearchserverless_security_policy.encryption,
    aws_opensearchserverless_security_policy.network
  ]
}


# 3. Network Policy

resource "aws_opensearchserverless_security_policy" "network" {
  name        = local.network_policy_name
  type        = "network"
  description = "Network policy for ${local.collection_name} collection"

  policy = jsonencode(
    var.create_vpc_endpoint && var.network_access_type == "VPC" ? [
      {
        Rules = [
          {
            Resource     = ["collection/${local.collection_name}"]
            ResourceType = "collection"
          },
          {
            Resource     = ["collection/${local.collection_name}"]
            ResourceType = "dashboard"
          }
        ]
        AllowFromPublic = false
        SourceVPCEs     = [aws_opensearchserverless_vpc_endpoint.this[0].id]
      }
    ] : [
      {
        Rules = [
          {
            Resource     = ["collection/${local.collection_name}"]
            ResourceType = "collection"
          },
          {
            Resource     = ["collection/${local.collection_name}"]
            ResourceType = "dashboard"
          }
        ]
        AllowFromPublic = true
      }
    ]
  )

  depends_on = [aws_opensearchserverless_vpc_endpoint.this]
}


# 4. VPC Endpoint

resource "aws_opensearchserverless_vpc_endpoint" "this" {
  count = var.create_vpc_endpoint ? 1 : 0

  name               = local.vpc_endpoint_name
  vpc_id             = var.vpc_id
  subnet_ids         = var.subnet_ids
  security_group_ids = var.security_group_ids
}


# 5. Data Access Policy

resource "aws_opensearchserverless_access_policy" "this" {
  name        = local.data_access_policy_name
  type        = "data"
  description = "Data access policy for ${local.collection_name} collection"

  policy = jsonencode([
    {
      Rules = [
        # Index-level permissions
        {
          Resource = [
            "index/${local.collection_name}/*"
          ]
          Permission = [
            "aoss:CreateIndex",
            "aoss:DeleteIndex",
            "aoss:UpdateIndex",
            "aoss:DescribeIndex",
            "aoss:ReadDocument",
            "aoss:WriteDocument"
          ]
          ResourceType = "index"
        },
        # Collection-level permissions
        {
          Resource = [
            "collection/${local.collection_name}"
          ]
          Permission = [
            "aoss:CreateCollectionItems",
            "aoss:DeleteCollectionItems",
            "aoss:UpdateCollectionItems",
            "aoss:DescribeCollectionItems"
          ]
          ResourceType = "collection"
        }
      ]
      # Combine IAM principals and optional SAML principal
      Principal = concat(
        var.data_access_principals,
        var.saml_provider_arn != null ? ["saml/${data.aws_caller_identity.current.account_id}/${var.saml_provider_arn}"] : []
      )
    }
  ])
}


# Data Sources

data "aws_caller_identity" "current" {}
