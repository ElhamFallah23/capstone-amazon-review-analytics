

terraform {
  required_providers {
    snowflake = {
      source  = "snowflakedb/snowflake"
      version = "~> 0.100"

      configuration_aliases = [
        snowflake.accountadmin
      ]
    }
  }
}

