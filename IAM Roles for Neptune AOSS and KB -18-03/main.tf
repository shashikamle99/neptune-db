terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

data "aws_caller_identity" "current" {}

locals {
  prefix = "${var.project}-${var.environment}"

  common_tags = merge(var.tags, {
    Project     = var.project
    Environment = var.environment
    ManagedBy   = "terraform"
  })
}

module "iam" {
  source = "./modules/iam"

  prefix     = local.prefix
  aws_region = var.aws_region
  account_id = data.aws_caller_identity.current.account_id

  neptune_s3_bucket_arns     = var.neptune_s3_bucket_arns
  aoss_collection_arns       = var.aoss_collection_arns
  bedrock_s3_bucket_arns     = var.bedrock_s3_bucket_arns
  bedrock_embedding_model_id = var.bedrock_embedding_model_id

  tags = local.common_tags
}
