

terraform {
  required_version = ">= 1.5.0"
  required_providers {
    snowflake = {
      source  = "Snowflakedb/snowflake"
      version = "~> 0.90"
    }
  }
}



########################################
# Snowflake provider
########################################
########################################
# SYSADMIN provider:
# - Used for databases, schemas, warehouses
########################################
provider "snowflake" {
  alias    = "sysadmin"
  account  = var.snowflake_account
  username = var.snowflake_username
  role     = "SYSADMIN"
  region   = var.snowflake_region

  private_key_path = var.snowflake_private_key_path
}

########################################
# SECURITYADMIN provider:
# - Used for roles and grants
########################################
provider "snowflake" {
  alias    = "securityadmin"
  account  = var.snowflake_account
  username = var.snowflake_username
  role     = "SECURITYADMIN"
  region   = var.snowflake_region

  private_key_path = var.snowflake_private_key_path
}




