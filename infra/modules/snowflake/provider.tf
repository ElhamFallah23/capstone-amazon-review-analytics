terraform {
  required_providers {
    snowflake = {
      source = "snowflakedb/snowflake"

      configuration_aliases = [
        snowflake.sysadmin,
        snowflake.securityadmin
      ]
    }
  }
}