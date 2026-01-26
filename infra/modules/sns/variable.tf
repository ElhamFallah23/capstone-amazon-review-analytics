
// Deployment environment (e.g., dev, prod)
variable "environment" {
description = "The deployment environment (e.g., dev, prod)"
type = string
}

// Email address to subscribe to the SNS topic
variable "notification_email" {
description = "Email address to receive SNS notifications"
type = string
}