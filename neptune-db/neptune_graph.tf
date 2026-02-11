resource "aws_neptune_cluster" "kb_neptune" {
  cluster_identifier          = "bedrock-kb-neptune"
  engine                      = "neptune"
  neptune_version             = "1.3.0"
  iam_database_auth_enabled   = true
  
  apply_immediately           = true
  skip_final_snapshot         = true
  deletion_protection         = false
}

resource "aws_neptune_cluster_instance" "kb_neptune_instance" {
  count              = 1
  identifier         = "bedrock-kb-neptune-instance"
  cluster_identifier = aws_neptune_cluster.kb_neptune.id
  instance_class     = "db.r6g.large"
  engine             = aws_neptune_cluster.kb_neptune.engine
  neptune_version    = aws_neptune_cluster.kb_neptune.neptune_version
}
