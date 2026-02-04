########################################
# Naming helpers
########################################
locals {
  env_upper = upper(var.environment)

  database_name  = "${var.database_name}_${local.env_upper}"
  warehouse_name = "${var.warehouse_name}_${local.env_upper}"

  role_raw       = "${var.role_prefix}_RAW_${local.env_upper}"
  role_transform = "${var.role_prefix}_TRANSFORM_${local.env_upper}"
  role_analytics = "${var.role_prefix}_ANALYTICS_${local.env_upper}"
}

########################################
# Database
########################################
resource "snowflake_database" "this" {
  provider = snowflake.sysadmin

  name    = local.database_name
  comment = "Main database for Amazon Review Analytics project"
}

########################################
# Schemas
########################################
resource "snowflake_schema" "raw" {
  provider = snowflake.sysadmin

  database = snowflake_database.this.name
  name     = "RAW"
  comment  = "Raw ingestion layer"
}

resource "snowflake_schema" "stage" {
  provider = snowflake.sysadmin

  database = snowflake_database.this.name
  name     = "STAGE"
  comment  = "Staging / transformation layer"
}

resource "snowflake_schema" "mart" {
  provider = snowflake.sysadmin

  database = snowflake_database.this.name
  name     = "MART"
  comment  = "Analytics / BI layer"
}

########################################
# Warehouse
########################################
resource "snowflake_warehouse" "this" {
  provider = snowflake.sysadmin

  name           = local.warehouse_name
  warehouse_size = var.warehouse_size

  auto_suspend = var.warehouse_auto_suspend
  auto_resume  = var.warehouse_auto_resume

  comment = "Compute warehouse for DBT, Airflow and BI workloads"
}

########################################
# Roles
########################################
resource "snowflake_account_role" "raw" {
  provider = snowflake.securityadmin

  name    = local.role_raw
  comment = "Role for RAW layer read/write access"
}

resource "snowflake_account_role" "transform" {
  provider = snowflake.securityadmin

  name    = local.role_transform
  comment = "Role for transforming data (DBT / Airflow)"
}

resource "snowflake_account_role" "analytics" {
  provider = snowflake.securityadmin

  name    = local.role_analytics
  comment = "Read-only role for BI / analytics"
}

########################################
# Role hierarchy
# TRANSFORM inherits RAW
########################################
resource "snowflake_grant_role_to_role" "transform_inherits_raw" {
  provider = snowflake.securityadmin

  role_name        = snowflake_account_role.raw.name
  parent_role_name = snowflake_account_role.transform.name
}

########################################
# Database USAGE grants
########################################
resource "snowflake_grant_privileges_to_role" "db_usage_raw" {
  provider   = snowflake.securityadmin
  role_name  = snowflake_account_role.raw.name
  privileges = ["USAGE"]

  on_database {
    database_name = snowflake_database.this.name
  }
}

resource "snowflake_grant_privileges_to_role" "db_usage_transform" {
  provider   = snowflake.securityadmin
  role_name  = snowflake_account_role.transform.name
  privileges = ["USAGE"]

  on_database {
    database_name = snowflake_database.this.name
  }
}

resource "snowflake_grant_privileges_to_role" "db_usage_analytics" {
  provider   = snowflake.securityadmin
  role_name  = snowflake_account_role.analytics.name
  privileges = ["USAGE"]

  on_database {
    database_name = snowflake_database.this.name
  }
}

########################################
# Schema grants
########################################
resource "snowflake_grant_privileges_to_role" "raw_schema_usage" {
  provider   = snowflake.securityadmin
  role_name  = snowflake_account_role.raw.name
  privileges = ["USAGE"]

  on_schema {
    database_name = snowflake_database.this.name
    schema_name   = snowflake_schema.raw.name
  }
}

resource "snowflake_grant_privileges_to_role" "stage_schema_usage" {
  provider   = snowflake.securityadmin
  role_name  = snowflake_account_role.transform.name
  privileges = ["USAGE"]

  on_schema {
    database_name = snowflake_database.this.name
    schema_name   = snowflake_schema.stage.name
  }
}

resource "snowflake_grant_privileges_to_role" "mart_schema_usage_transform" {
  provider   = snowflake.securityadmin
  role_name  = snowflake_account_role.transform.name
  privileges = ["USAGE"]

  on_schema {
    database_name = snowflake_database.this.name
    schema_name   = snowflake_schema.mart.name
  }
}

resource "snowflake_grant_privileges_to_role" "mart_schema_usage_analytics" {
  provider   = snowflake.securityadmin
  role_name  = snowflake_account_role.analytics.name
  privileges = ["USAGE"]

  on_schema {
    database_name = snowflake_database.this.name
    schema_name   = snowflake_schema.mart.name
  }
}

########################################
# Warehouse grants
########################################
resource "snowflake_grant_privileges_to_role" "warehouse_transform" {
  provider   = snowflake.securityadmin
  role_name  = snowflake_account_role.transform.name
  privileges = ["USAGE", "OPERATE"]

  on_warehouse {
    warehouse_name = snowflake_warehouse.this.name
  }
}

resource "snowflake_grant_privileges_to_role" "warehouse_analytics" {
  provider   = snowflake.securityadmin
  role_name  = snowflake_account_role.analytics.name
  privileges = ["USAGE"]

  on_warehouse {
    warehouse_name = snowflake_warehouse.this.name
  }
}
