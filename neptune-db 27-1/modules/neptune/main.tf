resource "aws_neptune_subnet_group" "neptune_sg" {
  name        = "${var.project_name}-${var.environment}-neptune-subnet-group"
  description = "Neptune subnet group for ${var.project_name} ${var.environment}"
  subnet_ids  = var.subnet_ids

  tags = merge(var.tags, {
    Name = "${var.project_name}-${var.environment}-neptune-subnet-group"
  })
}

resource "aws_neptune_cluster_parameter_group" "neptune_cluster_pg" {
  family      = "neptune1.3"
  name        = "${var.project_name}-${var.environment}-neptune-cluster-params"
  description = "Neptune cluster parameter group for ${var.project_name} ${var.environment}"

  parameter {
    name  = "neptune_enable_audit_log"
    value = "1"
  }

  tags = merge(var.tags, {
    Name = "${var.project_name}-${var.environment}-neptune-cluster-params"
  })
}

resource "aws_neptune_parameter_group" "neptune_pg" {
  family      = "neptune1.3"
  name        = "${var.project_name}-${var.environment}-neptune-params"
  description = "Neptune parameter group for ${var.project_name} ${var.environment}"

  tags = merge(var.tags, {
    Name = "${var.project_name}-${var.environment}-neptune-params"
  })
}

resource "aws_neptune_cluster" "neptune_cluster" {
  cluster_identifier                  = "${var.project_name}-${var.environment}-neptune"
  engine                              = "neptune"
  engine_version                      = var.engine_version
  port                                = var.neptune_port
  neptune_subnet_group_name           = aws_neptune_subnet_group.neptune_sg.name
  vpc_security_group_ids              = var.vpc_security_group_ids
  neptune_cluster_parameter_group_name = aws_neptune_cluster_parameter_group.neptune_cluster_pg.name

  # Serverless configuration
  serverless_v2_scaling_configuration {
    min_capacity = var.neptune_min_capacity
    max_capacity = var.neptune_max_capacity
  }

  backup_retention_period      = var.backup_retention_period
  preferred_backup_window      = var.preferred_backup_window
  preferred_maintenance_window = var.preferred_maintenance_window

  apply_immediately   = var.apply_immediately
  deletion_protection = var.deletion_protection
  skip_final_snapshot = var.skip_final_snapshot
  final_snapshot_identifier = var.skip_final_snapshot ? null : "${var.project_name}-${var.environment}-neptune-final-snapshot"

  storage_encrypted = true

  tags = merge(var.tags, {
    Name = "${var.project_name}-${var.environment}-neptune"
  })
}

resource "aws_neptune_cluster_instance" "neptune_instance" {
  count = var.instance_count

  identifier           = "${var.project_name}-${var.environment}-neptune-${count.index + 1}"
  cluster_identifier   = aws_neptune_cluster.neptune_cluster.id
  engine               = "neptune"
  instance_class       = "db.serverless"
  neptune_parameter_group_name = aws_neptune_parameter_group.neptune_pg.name

  apply_immediately            = var.apply_immediately
  preferred_maintenance_window = var.preferred_maintenance_window

  tags = merge(var.tags, {
    Name = "${var.project_name}-${var.environment}-neptune-instance-${count.index + 1}"
  })
}
