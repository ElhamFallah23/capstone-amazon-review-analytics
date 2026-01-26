variable "database_name" {
  description = "Name of the Glue database"
  type = string
}

variable "crawler_name" {
  description = "Name of the Glue crawler"
  type = string
}

variable "s3_input_path" {
  description = "S3 path for the data to be crawled"
  type = string
}

variable "schedule_expression" {
  description = "Schedule for Glue crawler (e.g., cron)"
  type = string
  default = null    # crawler will be triggeres manually   # "cron(0 12 * * ? *)"     # Every day at 12 UTC
}

variable "iam_role_arn" {
  description = "IAM Role ARN for the crawler to access resources"    # This Role has allowed to run the crawler.
  type = string
}

variable "environment" {
  description = "Deployment environment, e.g, dev or prod"
  type        = string
}