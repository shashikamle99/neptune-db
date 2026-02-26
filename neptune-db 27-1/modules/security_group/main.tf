resource "aws_security_group" "neptune" {
  name        = "${var.project_name}-${var.environment}-neptune-sg"
  description = "Security group for Neptune DB cluster"
  vpc_id      = var.vpc_id

  tags = merge(var.tags, {
    Name = "${var.project_name}-${var.environment}-neptune-sg"
  })
}

resource "aws_security_group_rule" "neptune_ingress" {
  type              = "ingress"
  from_port         = var.neptune_port
  to_port           = var.neptune_port
  protocol          = "tcp"
  cidr_blocks       = [var.vpc_cidr]
  security_group_id = aws_security_group.neptune.id
  description       = "Allow Neptune traffic from within VPC"
}

resource "aws_security_group_rule" "neptune_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.neptune.id
  description       = "Allow all outbound traffic"
}
