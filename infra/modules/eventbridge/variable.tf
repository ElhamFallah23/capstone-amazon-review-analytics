

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "bucket_name" {
  description = "Name of S3 ingestion bucket"
  type        = string
}

variable "state_machine_arn" {
  description = "ARN of Step Function"
  type        = string
}
