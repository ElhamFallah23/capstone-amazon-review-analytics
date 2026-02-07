variable "integration_name" {
  description = "Name of the Snowflake storage integration"
  type        = string
}

variable "aws_role_arn" {
  description = "IAM Role ARN that Snowflake assumes"
  type        = string
}

variable "allowed_locations" {
  description = "List of S3 locations Snowflake can access"
  type        = list(string)
}

variable "comment" {
  description = "Optional comment for the integration"
  type        = string
  default     = "Storage integration for Snowflake access to S3"
}




       