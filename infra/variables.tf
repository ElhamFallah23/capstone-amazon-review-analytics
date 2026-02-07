
variable "notification_email" {
  description = "Email to receive Glue job notifications"
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


########################################
# Environment
########################################

variable "environment" {
  description = "The environment to deploy to (e.g. dev, staging,prod)"
  type        = string
}






########################################
# Snowflake connection
########################################
variable "snowflake_account" {
  description = "Snowflake account identifier (e.g. xy12345.eu-central-1)"
  type        = string
}

variable "snowflake_username" {
  description = "Snowflake user used by Terraform (must have SYSADMIN + SECURITYADMIN)"
  type        = string
}

#variable "snowflake_region" {
# description = "Snowflake region (e.g. eu-central-1)"
#type        = string
#}

variable "snowflake_private_key" {
  description = "Path to RSA private key used for JWT authentication"
  type        = string
  sensitive   = true
}



########################################
# Snowflake core objects
########################################
variable "database_name" {
  description = "Base database name (env suffix will be added)"
  type        = string
}

variable "warehouse_name" {
  description = "Base warehouse name (env suffix will be added)"
  type        = string
}

########################################
# Service user (DBT + Airflow)
########################################
variable "service_user_name" {
  description = "Snowflake service user name"
  type        = string
}

variable "service_user_login_name" {
  description = "Login name for service user"
  type        = string
}

variable "service_user_rsa_public_key" {
  description = "RSA public key for service user"
  type        = string
  sensitive   = true
}

########################################
# Snoflake-Integration
########################################

variable "s3_bucket_arn" {
  description = "List of S3 bucket ARNs Snowflake can access"
  type        = list(string)
}

variable "s3_prefixes" {
  description = ""
  type        = list(string)
}