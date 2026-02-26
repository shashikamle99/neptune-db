variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block of the VPC for ingress rules"
  type        = string
}

variable "neptune_port" {
  description = "Port for Neptune DB"
  type        = number
  default     = 8182
}

variable "tags" {
  description = "Common tags"
  type        = map(string)
  default     = {}
}
