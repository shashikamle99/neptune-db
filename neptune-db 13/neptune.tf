# Neptune Cluster (production: backups, multi-AZ, encryption)
resource "aws_neptune_cluster" "main" {
  cluster_identifier      = var.cluster_identifier
  engine                  = "neptune"
  backup_retention_period = 7
  preferred_backup_window = "07:00-09:00"
  skip_final_snapshot     = false
  deletion_protection     = true
  iam_database_authentication_enabled = true
  storage_encrypted       = true
  apply_immediately       = true
  neptune_subnet_group_name = aws_neptune_subnet_group.main.name
  vpc_security_group_ids  = [aws_security_group.neptune.id]

  tags = {
    Name = "prod-neptune-cluster"
  }
}

# Neptune Instance (writer)
resource "aws_neptune_cluster_instance" "writer" {
  identifier         = "${var.cluster_identifier}-writer"
  cluster_identifier = aws_neptune_cluster.main.id
  instance_class     = var.instance_class
  engine             = "neptune"
  apply_immediately  = true
}

# Neptune Read Replica (for HA)
resource "aws_neptune_cluster_instance" "reader" {
  identifier         = "${var.cluster_identifier}-reader"
  cluster_identifier = aws_neptune_cluster.main.id
  instance_class     = var.instance_class
  engine             = "neptune"
  apply_immediately  = true
}