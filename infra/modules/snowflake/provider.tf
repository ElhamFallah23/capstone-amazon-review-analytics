terraform {
  required_providers {
    snowflake = {
      source  = "Snowflake-Labs/snowflake"
      version = "~> 0.90"
    }
  }
}

########################################
# SYSADMIN provider:
# - Used for databases, schemas, warehouses
########################################
provider "snowflake" {
  alias    = "sysadmin"
  account  = var.snowflake_account
  username = var.snowflake_username
  password = var.snowflake_password
  role     = var.snowflake_sysadmin_role
  region   = var.snowflake_region
}

########################################
# SECURITYADMIN provider:
# - Used for roles and grants
########################################
provider "snowflake" {
  alias    = "securityadmin"
  account  = var.snowflake_account
  username = var.snowflake_username
  password = var.snowflake_password
  role     = var.snowflake_securityadmin_role
  region   = var.snowflake_region
}


