# VPC for Neptune
resource "aws_vpc" "neptune_vpc" {
  cidr_block = var.vpc_cidr
  tags = {
    Name = "${var.cluster_name}-vpc"
  }
}

# Public subnet
resource "aws_subnet" "public_subnet" {
  vpc_id     = aws_vpc.neptune_vpc.id
  cidr_block = var.public_subnet_cidr
  availability_zone = "${var.aws_region}a"
  tags = {
    Name = "${var.cluster_name}-public-subnet"
  }
}

# Private subnet for Neptune
resource "aws_subnet" "private_subnet" {
  vpc_id     = aws_vpc.neptune_vpc.id
  cidr_block = var.private_subnet_cidr
  availability_zone = "${var.aws_region}a"
  tags = {
    Name = "${var.cluster_name}-private-subnet"
  }
}



# Neptune cluster
resource "aws_neptune_cluster" "production" {
  cluster_identifier                  = var.cluster_name
  engine                              = "neptune"
  backup_retention_period             = 7
  preferred_backup_window             = "07:00-09:00"
  preferred_maintenance_window        = "Sun:23:00-Sun:03:00"
  iam_database_authentication_enabled = true
  storage_encrypted                   = true
  apply_immediately                   = true
  skip_final_snapshot                 = false
  deletion_protection                 = true
  final_snapshot_identifier           = "${var.cluster_name}-final-snapshot"
  vpc_security_group_ids              = [aws_security_group.neptune_sg.id]
  # db_subnet_group_name                = aws_db_subnet_group.neptune_subnet_group.name

  tags = {
    Name = var.cluster_name
    Environment = "production"
  }
}

# Neptune subnet group
resource "aws_db_subnet_group" "neptune_subnet_group" {
  name       = "${var.cluster_name}-subnet-group"
  subnet_ids = [aws_subnet.private_subnet.id]

  tags = {
    Name = "${var.cluster_name}-subnet-group"
  }
}

# Neptune cluster instance
resource "aws_neptune_cluster_instance" "production_instances" {
  count              = 2
  identifier         = "${var.cluster_name}-instance-${count.index}"
  cluster_identifier = aws_neptune_cluster.production.id
  instance_class     = var.instance_class
  engine             = "neptune"
  apply_immediately  = true

  tags = {
    Name = "${var.cluster_name}-instance-${count.index}"
  }
}
