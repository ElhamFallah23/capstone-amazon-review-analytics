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


  authenticator = "SNOWFLAKE_JWT"
  private_key   = var.snowflake_private_key
}
########################################
# SECURITYADMIN provider
# - Used for roles, grants, service user
########################################
provider "snowflake" {
  alias   = "securityadmin"
  account = var.snowflake_account
  user    = var.snowflake_username
  role    = "SECURITYADMIN"

  authenticator = "SNOWFLAKE_JWT"
  private_key   = var.snowflake_private_key
}

########################################
# ACCOUNTADMIN provider
# - Used for roles, grants, service user
########################################

provider "snowflake" {
  alias   = "accountadmin"
  account = var.snowflake_account
  user    = var.snowflake_username
  role    = "ACCOUNTADMIN"

  authenticator = "SNOWFLAKE_JWT"
  private_key   = var.snowflake_private_key
}


