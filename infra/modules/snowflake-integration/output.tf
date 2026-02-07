


output "integration_name" {
  value       = snowflake_storage_integration.this.name
  description = "Name of the Snowflake storage integration"
}

output "integration_aws_iam_user_arn" {
  value       = snowflake_storage_integration.this.storage_aws_iam_user_arn
  description = "Snowflake AWS IAM user ARN (for trust policy validation)"
}

output "integration_external_id" {
  value       = snowflake_storage_integration.this.storage_aws_external_id
  description = "External ID Snowflake uses when assuming the IAM role"
}
