# # IAM role for Neptune S3 access (add to main.tf)
# resource "aws_iam_role" "neptune_s3_role" {
#   name = "${var.cluster_name}-s3-role"
#   assume_role_policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [{
#       Action = "sts:AssumeRole"
#       Effect = "Allow"
#       Principal = {
#         Service = "rds.amazonaws.com"
#       }
#     }]
#   })
# }

# resource "aws_iam_role_policy" "neptune_s3_policy" {
#   name = "${var.cluster_name}-s3-policy"
#   role = aws_iam_role.neptune_s3_role.id
#   policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [{
#       Effect = "Allow"
#       Action = ["s3:GetObject", "s3:ListBucket"]
#       Resource = ["arn:aws:s3:::your-bucket/*", "arn:aws:s3:::your-bucket"]
#     }]
#   })
# }

# # Updated Neptune cluster with IAM role
# resource "aws_neptune_cluster" "production" {
#   # ... existing config ...
#   iam_roles = [aws_iam_role.neptune_s3_role.arn]
#   iam_database_auth_enabled = true
# }
