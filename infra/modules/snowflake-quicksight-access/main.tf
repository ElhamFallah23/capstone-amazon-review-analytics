
##############################################
# Create Role for QuickSight
##############################################

resource "snowflake_role" "quicksight_role" {
  name = var.quicksight_role_name
}

##############################################
# Create User for QuickSight
##############################################

resource "snowflake_user" "quicksight_user" {
  name                 = var.quicksight_user_name
  password             = var.quicksight_user_password
  default_role         = snowflake_role.quicksight_role.name
  default_warehouse    = var.warehouse_name
  must_change_password = false
}

##############################################
# Grant Role to User
##############################################

resource "snowflake_role_grants" "grant_role_to_user" {
  role_name = snowflake_role.quicksight_role.name
  users     = [snowflake_user.quicksight_user.name]
}

##############################################
# Grant USAGE on Database
##############################################

resource "snowflake_database_grant" "database_usage" {
  database_name = var.snowflake_database
  privilege     = "USAGE"
  roles         = [snowflake_role.quicksight_role.name]
}

##############################################
# Grant USAGE on Schema
##############################################

resource "snowflake_schema_grant" "schema_usage" {
  database_name = var.snowflake_database
  schema_name   = var.snowflake_schema
  privilege     = "USAGE"
  roles         = [snowflake_role.quicksight_role.name]
}

##############################################
# Grant SELECT on all existing tables
##############################################

resource "snowflake_table_grant" "select_tables" {
  database_name = var.snowflake_database
  schema_name   = var.snowflake_schema
  privilege     = "SELECT"
  roles         = [snowflake_role.quicksight_role.name]
  on_all        = true
}

##############################################
# Grant SELECT on future tables
##############################################

resource "snowflake_table_grant" "future_select_tables" {
  database_name = var.snowflake_database
  schema_name   = var.snowflake_schema
  privilege     = "SELECT"
  roles         = [snowflake_role.quicksight_role.name]
  on_future     = true
}

##############################################
# Grant USAGE on Warehouse
##############################################

resource "snowflake_warehouse_grant" "warehouse_usage" {
  warehouse_name = var.warehouse_name
  privilege      = "USAGE"
  roles          = [snowflake_role.quicksight_role.name]
}



#khihi
