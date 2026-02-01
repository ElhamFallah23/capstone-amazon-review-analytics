
output "glue_crawler_role_arn" {
  description = "ARN of the IAM Role for the Glue Crawler"
  value       = aws_iam_role.glue_crawler_role.arn
}

output "sns_fullaccess_policy_arn" {
  value = aws_iam_policy.sns_full_access.arn
}

output "github_oidc_role_arn" {
  description = "ARN of the Github OIDC IAM Role"
  value       = aws_iam_role.github_actions_oidc.arn
}


output "glue_job_role_arn" {
  description = "ARN of the IAM role used by Glue ETL job"
  value       = aws_iam_role.glue_job_role.arn
}

output "lambda_role_arn" {
  description = "IAM role ARN for Lambda"
  value       = aws_iam_role.lambda_role.arn
}