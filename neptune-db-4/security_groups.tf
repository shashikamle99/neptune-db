# Neptune security group
resource "aws_security_group" "neptune_sg" {
  name_prefix = "${var.cluster_name}-sg"
  vpc_id      = aws_vpc.neptune_vpc.id

  ingress {
    from_port = 8182
    to_port   = 8182
    protocol  = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.cluster_name}-neptune-sg"
  }
}