


output "role_arn" {
  description = "ARN of the Snowflake integration IAM role"
  value       = aws_iam_role.this.arn
}

output "role_name" {
  description = "Name of the Snowflake integration IAM role"
  value       = aws_iam_role.this.name
}

