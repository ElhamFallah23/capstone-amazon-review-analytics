
variable "environment" {
  description = "Deployment environment (e.g., dev, prod)"
  type        = string
}

variable "lambda_function_name" {
  description = "The name of lambda function"
  type        = string
}

variable "lambda_role_arn" {
  description = "The IAM Role ARN that Lambda will use"
  type        = string
}

variable "sns_topic_arn" {
  description = "ARN of the SNS topic to send notifications"
  type        = string
}

variable "glue_job_name" {
  description = "Name of the Glue job to track status"
  type        = string
}


variable "stepfunction_arn" {
  description = "ARN of the Step Function that triggers this Lambda"
  type        = string
}

variable "project_tag" {
  description = "Project name or tag"
  type        = string
  default     = "amazon-review-analytics"
}

