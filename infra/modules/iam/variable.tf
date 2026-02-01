
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

variable "lambda_function_name" {
  description = "The name of lambda function"
  type        = string
}




############################################
# Step Functions IAM inputs
############################################

variable "stepfunction_state_machine_name" {
  description = "Base name of the Step Functions state machine (env suffix may be appended in root)"
  type        = string
}

variable "lambda_status_checker_arn" {
  description = "ARN of the Lambda function that Step Functions will invoke"
  type        = string
}

variable "glue_job_arn" {
  description = "ARN of the Glue job that Step Functions will start"
  type        = string
}

variable "enable_stepfunction_logging" {
  description = "Whether Step Functions logging permissions should be included"
  type        = bool
  default     = true
}




