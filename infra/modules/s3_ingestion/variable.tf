variable "bucket_name" {
  description = "Name of the ingestion S3 bucket"
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
  description = "enable versioning for s3 bucket"
  type        = bool
  default     = true
}