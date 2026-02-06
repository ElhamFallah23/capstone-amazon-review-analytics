
# Output the ARN of the created SNS topic
output "sns_topic_arn" {
  description = "ARN of the SNS topic"
  value       = aws_sns_topic.job_notifications.arn
}

