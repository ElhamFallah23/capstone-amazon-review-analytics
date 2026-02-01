variable "raw_bucket_name" {
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


variable "glue_scripts_bucket_name" {
  description = "Name of Glue scripts S3 bucket"
  type        = string
}


variable "processed_bucket_name" {
  description = "Name of Processed Data S3 Bucket"
  type        = string
}