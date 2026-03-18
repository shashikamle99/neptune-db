terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }

  # ── Remote state (align with your existing MPG backend config) ────────────────
  backend "s3" {
    bucket         = "mpg-terraform-state"
    key            = "cloudwatch-alarms/terraform.tfstate"
    region         = "us-east-2"
    dynamodb_table = "mpg-terraform-locks"
    encrypt        = true
  }
}

provider "aws" {
  region = var.region
}

# ── Neptune Alarms ─────────────────────────────────────────────────────────────
module "neptune_alarms" {
  source = "./modules/cloudwatch_alarm"
  alarms = local.neptune_alarms
}

# ── OpenSearch Serverless Alarms ───────────────────────────────────────────────
module "aoss_alarms" {
  source = "./modules/cloudwatch_alarm"
  alarms = local.aoss_alarms
}

# ── Bedrock Knowledge Base Alarms ─────────────────────────────────────────────
module "bedrock_alarms" {
  source = "./modules/cloudwatch_alarm"
  alarms = local.bedrock_alarms
}
