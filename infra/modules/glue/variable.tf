
#############################################
# Common variables
#############################################

variable "environment" {
  description = "Deployment environment (e.g. dev, staging, prod)"
  type        = string
}


#############################################
# Glue Catalog Database configuration
#############################################
variable "glue_database_name" {
  description = "Name of the Glue database"
  type        = string
}

variable "glue_table_name" {
  description = "Glue Catalog table created by crawler"
  type        = string
}


#############################################
# Glue Crawler configuration
#############################################

variable "crawler_name" {
  description = "Name of the Glue crawler"
  type        = string
}

variable "raw_s3_path" {
  description = "S3 path for the data to be crawled"
  type        = string
}

variable "schedule_expression" {
  description = "Schedule for Glue crawler (e.g., cron)"
  type        = string
  default     = null # crawler will be triggeres manually   # "cron(0 12 * * ? *)"     # Every day at 12 UTC
}

variable "iam_role_arn_crawler" {
  description = "IAM Role ARN for the crawler to access resources" # This Role has allowed to run the crawler.
  type        = string
}

#############################################
# Glue Job configuration
#############################################

variable "glue_job_name" {
  description = "Base name of the Glue ETL job"
  type        = string
}

variable "iam_role_arn_glue_job" {
  description = "IAM Role ARN assumed by the Glue Job"
  type        = string
}

variable "number_of_workers" {
  description = "Number of workers allocated to the Glue Job"
  type        = number
  default     = 2
}

variable "job_timeout" {
  description = "Maximum execution time for the Glue Job in minutes"
  type        = number
  default     = 60
}

#############################################
# S3 paths used by the Glue Job
#############################################

variable "script_s3_path" {
  description = "S3 path where the Glue ETL Python script is stored"
  type        = string
}

variable "temp_s3_path" { # ??? why it is needed
  description = "Temporary S3 directory used by Glue during execution"
  type        = string
}

variable "raw_s3_path" {
  description = "S3 path containing raw Amazon review data" # Both Glue Job (read from this) and Crawler (crawl) use this main source 
  type        = string
}

variable "processed_s3_path" {
  description = "S3 path where processed/flattened data will be written"
  type        = string
}

variable "pglue_script_s3_object_dependency" {
  description = "SUsed only to enforce creation orderbetween s3 object and Glue job"
  type        = any
}