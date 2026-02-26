project_name = "gpt-demo"
environment  = "dev"
aws_region   = "us-east-2"

vpc_cidr             = "10.0.0.0/16"
private_subnet_cidrs = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
availability_zones   = ["us-east-1a", "us-east-1b", "us-east-1c"]

neptune_min_capacity = 1
neptune_max_capacity = 8
neptune_port         = 8182

apply_immediately            = false
deletion_protection          = true
skip_final_snapshot          = false
backup_retention_period      = 7
preferred_backup_window      = "02:00-03:00"
preferred_maintenance_window = "sun:05:00-sun:06:00"

tags = {
  Project     = "gpt-demo"
  Environment = "dev"
  ManagedBy   = "terraform"
}