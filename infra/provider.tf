terraform {
  required_providers {
    snowflake = {
      source  = "Snowflake-Labs/snowflake"
      version = "~> 0.90"
    }
  }
}

provider "snowflake" {
  account       = var.snowflake_account
  user          = var.snowflake_user
  role          = "SYSADMIN"
  authenticator = "SNOWFLAKE_JWT"
  private_key   = file(var.snowflake_private_key_path)
}

provider "snowflake" {
  alias         = "securityadmin"
  account       = var.snowflake_account
  user          = var.snowflake_user
  role          = "SECURITYADMIN"
  authenticator = "SNOWFLAKE_JWT"
  private_key   = file(var.snowflake_private_key_path)
}




