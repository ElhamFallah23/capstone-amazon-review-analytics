// Creates an SNS topic for job notifications
resource "aws_sns_topic" "job_notifications" {
  name = "glue-job-notifications-${var.environment}"
}

// Creates an email subscription for the SNS topic
// The provided email will receive a confirmation email from AWS

resource "aws_sns_topic_subscription" "email_subscription" {
  topic_arn = aws_sns_topic.job_notifications.arn
  protocol = "email" // Email-based subscription
  endpoint = var.notification_email // Email address to receive notifications
}

