variable "role_name" {
  description = "IAM role name for Snowflake storage integration"
  type        = string
}

variable "s3_bucket_arn" {
  description = "ARN of the S3 bucket Snowflake will access"
  type        = list(string)
}

variable "s3_prefixes" {
  description = "List of S3 prefixes Snowflake is allowed to read"
  type        = list(string)
}

variable "tags" {
  description = "Common tags"
  type        = map(string)
  default     = {}
}

variable "integration_aws_iam_user_arn" {
  description = "Snowflake AWS IAM User ARN DESC INTEGRATION"
  type        = string
}

variable "integration_external_id" {
  description = "Snowflake external ID from DESC INTEGRATION"
  type        = string
}


