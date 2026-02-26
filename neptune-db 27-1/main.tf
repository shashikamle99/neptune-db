module "vpc" {
  source = "./modules/vpc"

  project_name         = var.project_name
  environment          = var.environment
  vpc_cidr             = var.vpc_cidr
  private_subnet_cidrs = var.private_subnet_cidrs
  availability_zones   = var.availability_zones
  tags                 = var.tags
}

module "security_group" {
  source = "./modules/security_group"

  project_name = var.project_name
  environment  = var.environment
  vpc_id       = module.vpc.vpc_id
  vpc_cidr     = var.vpc_cidr
  tags         = var.tags
}

module "neptune" {
  source = "./modules/neptune"

  project_name                 = var.project_name
  environment                  = var.environment
  subnet_ids                   = module.vpc.private_subnet_ids
  vpc_security_group_ids       = [module.security_group.neptune_sg_id]
  neptune_min_capacity         = var.neptune_min_capacity
  neptune_max_capacity         = var.neptune_max_capacity
  neptune_port                 = var.neptune_port
  apply_immediately            = var.apply_immediately
  deletion_protection          = var.deletion_protection
  skip_final_snapshot          = var.skip_final_snapshot
  backup_retention_period      = var.backup_retention_period
  preferred_backup_window      = var.preferred_backup_window
  preferred_maintenance_window = var.preferred_maintenance_window
  tags                         = var.tags
}
