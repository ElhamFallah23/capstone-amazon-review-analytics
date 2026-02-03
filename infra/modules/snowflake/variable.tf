

############################
# Snowflake connection
############################

variable "snowflake_account" {
  description = "Snowflake account identifier"
  type        = string
}

variable "snowflake_username" {
  description = "Snowflake username"
  type        = string
}

variable "snowflake_password" {
  description = "Snowflake password (store in GitHub Secrets / TF vars securely)"
  type        = string
  sensitive   = true
}

variable "snowflake_region" {
  description = "Snowflake region"
  type        = string
}

variable "snowflake_sysadmin_role" {
  description = "Role used for creating DB/Schema/Warehouse (usually SYSADMIN)"
  type        = string
  default     = "SYSADMIN"
}

variable "snowflake_securityadmin_role" {
  description = "Role used for creating Roles/Grants (usually SECURITYADMIN)"
  type        = string
  default     = "SECURITYADMIN"
}

############################
# Project configuration
############################

variable "environment" {
  description = "Deployment environment (dev, staging, prod)"
  type        = string
}

variable "database_name" {
  description = "Base name of the Snowflake database"
  type        = string
}

############################
# Warehouse configuration
############################

variable "warehouse_name" {
  description = "Base name of the Snowflake warehouse"
  type        = string
  default     = "WH_AMAZON_REVIEW_ANALYTICS"
}

variable "warehouse_size" {
  description = "Snowflake warehouse size (e.g. XSMALL, SMALL, MEDIUM)"
  type        = string
  default     = "XSMALL"
}

variable "warehouse_auto_suspend" {
  description = "Auto suspend in seconds (cost control)"
  type        = number
  default     = 60
}

variable "warehouse_auto_resume" {
  description = "Auto resume warehouse on query"
  type        = bool
  default     = true
}

############################
# Role naming
############################

variable "role_prefix" {
  description = "Prefix for project roles"
  type        = string
  default     = "ARA" # Amazon Review Analytics
}





