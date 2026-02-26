output "neptune_sg_id" {
  description = "ID of the Neptune security group"
  value       = aws_security_group.neptune.id
}
