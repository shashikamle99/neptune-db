variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs for Neptune"
  type        = list(string)
}

variable "vpc_security_group_ids" {
  description = "List of VPC security group IDs"
  type        = list(string)
}

variable "engine_version" {
  description = "Neptune engine version"
  type        = string
  default     = "1.3.2.1"
}

variable "neptune_port" {
  description = "Port for Neptune cluster"
  type        = number
  default     = 8182
}

variable "neptune_min_capacity" {
  description = "Minimum Neptune Capacity Units (NCUs) for serverless (min: 1)"
  type        = number
  default     = 1

  validation {
    condition     = var.neptune_min_capacity >= 1 && var.neptune_min_capacity <= 128
    error_message = "neptune_min_capacity must be between 1 and 128."
  }
}

variable "neptune_max_capacity" {
  description = "Maximum Neptune Capacity Units (NCUs) for serverless (max: 128)"
  type        = number
  default     = 128

  validation {
    condition     = var.neptune_max_capacity >= 1 && var.neptune_max_capacity <= 128
    error_message = "neptune_max_capacity must be between 1 and 128."
  }
}

variable "instance_count" {
  description = "Number of Neptune cluster instances"
  type        = number
  default     = 1
}

variable "apply_immediately" {
  description = "Apply changes immediately or during maintenance window"
  type        = bool
  default     = false
}

variable "deletion_protection" {
  description = "Enable deletion protection"
  type        = bool
  default     = true
}

variable "skip_final_snapshot" {
  description = "Skip final snapshot on deletion"
  type        = bool
  default     = false
}

variable "backup_retention_period" {
  description = "Days to retain automated backups"
  type        = number
  default     = 7
}

variable "preferred_backup_window" {
  description = "Preferred backup window (UTC)"
  type        = string
  default     = "02:00-03:00"
}

variable "preferred_maintenance_window" {
  description = "Preferred maintenance window"
  type        = string
  default     = "sun:05:00-sun:06:00"
}

variable "tags" {
  description = "Common tags"
  type        = map(string)
  default     = {}
}
