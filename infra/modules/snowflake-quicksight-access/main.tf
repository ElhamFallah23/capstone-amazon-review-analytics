#############################################
# Snowflake QuickSight Access Module
# This module provisions:
# - Snowflake role for QuickSight
# - Snowflake user for QuickSight
# - Warehouse usage grant
# - Database usage grant
# - Schema usage grant
# - Select on all tables & views in MART schema
#############################################

#############################################
# Create Snowflake Role for QuickSight
#############################################

resource "snowflake_account_role" "quicksight_role" {
  provider = snowflake.securityadmin
  name     = var.quicksight_role_name
  comment  = "Read-only role for AWS QuickSight access"
}

#############################################
# Create Snowflake User for QuickSight
#############################################

resource "snowflake_user" "quicksight_user" {
  provider = snowflake.securityadmin

  name              = var.quicksight_user_name
  password          = var.quicksight_user_password
  default_role      = snowflake_account_role.quicksight_role.name
  default_warehouse = var.warehouse_name

  must_change_password = false
  disabled             = false

  comment = "Service user for AWS QuickSight"
}

#############################################
# Grant Role to User
#############################################

resource "snowflake_grant_account_role" "grant_role_to_user" {
  provider = snowflake.securityadmin

  role_name = snowflake_account_role.quicksight_role.name
  user_name = snowflake_user.quicksight_user.name
}

#############################################
# Grant USAGE on Warehouse
#############################################

resource "snowflake_grant_privileges_to_account_role" "warehouse_usage" {
  provider = snowflake.securityadmin

  account_role_name = snowflake_account_role.quicksight_role.name
  privileges        = ["USAGE"]

  on_account_object {
    object_type = "WAREHOUSE"
    object_name = var.warehouse_name
  }
}

#############################################
# Grant USAGE on Database
#############################################

resource "snowflake_grant_privileges_to_account_role" "database_usage" {
  provider = snowflake.securityadmin

  account_role_name = snowflake_account_role.quicksight_role.name
  privileges        = ["USAGE"]

  on_account_object {
    object_type = "DATABASE"
    object_name = var.database_name
  }
}

#############################################
# Grant USAGE on Schema (MART)
#############################################

resource "snowflake_grant_privileges_to_account_role" "schema_usage" {
  provider = snowflake.securityadmin

  account_role_name = snowflake_account_role.quicksight_role.name
  privileges        = ["USAGE"]

  on_schema {
    schema_name = "${var.database_name}.${var.schema_name}"
  }
}

#############################################
# Grant SELECT on all TABLES in MART schema
#############################################

resource "snowflake_grant_privileges_to_account_role" "select_tables" {
  provider = snowflake.securityadmin

  account_role_name = snowflake_account_role.quicksight_role.name
  privileges        = ["SELECT"]

  on_schema_object {
    all {
      object_type_plural = "TABLES"
      in_schema          = "${var.database_name}.${var.schema_name}"
    }
  }
}




resource "snowflake_schema_grant" "mart_usage" {
  database_name = var.database_name
  schema_name   = var.schema_name
  privilege     = "USAGE"
  roles         = [var.quicksight_role_name]
}

resource "snowflake_table_grant" "mart_select" {
  database_name = var.database_name
  schema_name   = var.schema_name
  privilege     = "SELECT"
  roles         = [var.quicksight_role_name]
  on_future     = true
}

#############################################
# Grant SELECT on all VIEWS in MART schema
#############################################

resource "snowflake_grant_privileges_to_account_role" "select_views" {
  provider = snowflake.securityadmin

  account_role_name = snowflake_account_role.quicksight_role.name
  privileges        = ["SELECT"]

  on_schema_object {
    all {
      object_type_plural = "VIEWS"
      in_schema          = "${var.database_name}.${var.schema_name}"
    }
  }
}




