variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "cluster_identifier" {
  description = "Neptune cluster identifier"
  type        = string
  default     = "prod-neptune-cluster"
}

variable "instance_class" {
  description = "Neptune instance class"
  type        = string
  default     = "db.r6g.large"
}
