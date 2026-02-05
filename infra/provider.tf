

terraform {
  required_version = ">= 1.5.0"

  required_providers {
    snowflake = {
      source  = "snowflakedb/snowflake"
      version = "~> 0.100"
    }
  }
}

########################################
# SYSADMIN provider
# - Used for databases, schemas, warehouses, user defaults
########################################
provider "snowflake" {
  alias = "sysadmin"

  account = var.snowflake_account
  user    = var.snowflake_username
  role    = "SYSADMIN"
  #region  = var.snowflake_region

  authenticator = "SNOWFLAKE_JWT"
  private_key   = var.snowflake_private_key
}

########################################
# SECURITYADMIN provider
# - Used for roles, grants, service user
########################################
provider "snowflake" {
  alias = "securityadmin"

  account = var.snowflake_account
  user    = var.snowflake_username
  role    = "SECURITYADMIN"
  #region  = var.snowflake_region

  authenticator = "SNOWFLAKE_JWT"
  private_key   = var.snowflake_private_key
}




