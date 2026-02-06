variable "bucket_name" {
  description = "Name of the S3 bucket to store Terraform state"
  type        = string
}

variable "lock_table_name" {
  description = "Name of the DynamoDB table for Terraform state lock"
  type        = string
}

variable "tags" {
  description = "Map of tags to attach to the bucket"
  type        = map(string)
  default     = {}
}

variable "environment" {
  description = "Deployment environment, e.g, dev or prod"
  type        = string
}

variable "enable_versioning" {
  description = "enable versioning for s3"
  type        = bool
  default     = true
}