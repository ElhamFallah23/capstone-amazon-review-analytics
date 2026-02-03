
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
# Global environment configuration
########################################

variable "environment" {
  description = "The environment to deploy to (e.g. dev, staging,prod)"
  type        = string
}



########################################
# Snowflake naming
########################################

variable "snowflake_database_name" {
  description = "Base name of the Snowflake database (environment suffix will be added)"
  type        = string
}

variable "snowflake_warehouse_name" {
  description = "Base name of the Snowflake warehouse (environment suffix will be added)"
  type        = string
}

variable "snowflake_role_prefix" {
  description = "Prefix for Snowflake roles (e.g. AMAZON_REVIEW)"
  type        = string
}

########################################
# Snowflake warehouse configuration
########################################

variable "snowflake_warehouse_size" {
  description = "Snowflake warehouse size (e.g. XSMALL, SMALL, MEDIUM)"
  type        = string
}

variable "snowflake_warehouse_auto_suspend" {
  description = "Auto suspend time in seconds for Snowflake warehouse"
  type        = number
}

variable "snowflake_warehouse_auto_resume" {
  description = "Whether Snowflake warehouse should auto resume"
  type        = bool
}

########################################
# Snowflake service user (runtime user)
########################################

variable "snowflake_service_user_name" {
  description = "Service user used by DBT and Airflow to access Snowflake"
  type        = string
}

variable "snowflake_service_user_rsa_public_key" {
  description = "RSA public key for Snowflake service user (used for key-pair authentication)"
  type        = string
}



############################



########################################
# Snowflake provider authentication
########################################

variable "snowflake_account" {
  description = "Snowflake account identifier (e.g. xy12345.eu-central-1)"
  type        = string
}

variable "snowflake_region" {
  description = "Snowflake region"
  type        = string
}

variable "snowflake_username" {
  description = "Snowflake admin username used by Terraform"
  type        = string
}

variable "snowflake_role" {
  description = "Snowflake role used by Terraform (SYSADMIN / SECURITYADMIN)"
  type        = string
}

variable "snowflake_private_key_path" {
  description = "Path to Snowflake private key file (PEM)"
  type        = string
}







