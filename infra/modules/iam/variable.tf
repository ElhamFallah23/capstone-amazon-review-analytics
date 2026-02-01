
variable "environment" {
  description = "Deployment environment (e.g., dev, staging, prod)"
  type        = string
}

variable "github_repo" {
  description = "GitHub repo in the format 'username/repo'"
  type        = string
}

variable "github_branch" {
  description = "Branch name used for deployment"
  type        = string
}


variable "raw_bucket_arn" {
  description = "ARN of the S3 bucket containing raw input data"
  type        = string
}

variable "processed_bucket_arn" {
  description = "ARN of the S3 bucket for processed/flattened output data"
  type        = string
}


variable "project_tag" {
  description = "Project Tag"
  type        = string
}


variable "sns_topic_arn" {
  description = "SNS Topic ARN"
  type        = string
}
