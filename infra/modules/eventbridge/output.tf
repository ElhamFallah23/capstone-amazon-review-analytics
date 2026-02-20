


output "event_rule_arn" {
  description = "ARN of the EventBridge rule."
  value       = aws_cloudwatch_event_rule.s3_object_created.arn
}

output "eventbridge_role_arn" {
  description = "ARN of the IAM role assumed by EventBridge."
  value       = aws_iam_role.eventbridge_invoke_sfn.arn
}




