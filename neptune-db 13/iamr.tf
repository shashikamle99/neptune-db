# IAM Policy for Neptune database access
resource "aws_iam_policy" "neptune_access" {
  name        = "NeptuneDBAccessPolicy"
  description = "Policy for IAM auth access to Neptune cluster"
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "neptune-db:*"
        ]
        Resource = [
          "arn:aws:neptune-db:${var.aws_region}:${data.aws_caller_identity.current.account_id}:cluster-${var.cluster_identifier}/*"
        ]
      }
    ]
  })
}

# Data source for account ID
data "aws_caller_identity" "current" {}

# IAM Role for Neptune clients (EC2, Lambda, etc.)
resource "aws_iam_role" "neptune_client" {
  name = "NeptuneClientRole"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = [
            "ec2.amazonaws.com",
            "lambda.amazonaws.com"
          ]
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

# Attach policy to role
resource "aws_iam_role_policy_attachment" "neptune_policy_attach" {
  role       = aws_iam_role.neptune_client.name
  policy_arn = aws_iam_policy.neptune_access.arn
}

# Instance profile for EC2 bastion
resource "aws_iam_instance_profile" "neptune_client_profile" {
  name = "NeptuneClientProfile"
  role = aws_iam_role.neptune_client.name
}
