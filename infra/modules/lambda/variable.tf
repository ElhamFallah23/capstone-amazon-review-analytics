
variable "environment" {
  description = "Deployment environment (e.g., dev, prod)"
  type        = string
}

variable "lambda_role_arn" {
  description = "IAM role ARN for the Lambda function"
  type        = string
}

variable "sns_topic_arn" {
  description = "SNS Topic ARN to send status notifications"
  type        = string
}

variable "glue_job_name" {
  description = "Name of the Glue job to track status"
  type        = string
}




