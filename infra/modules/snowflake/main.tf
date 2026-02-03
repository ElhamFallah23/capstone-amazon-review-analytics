


########################################
# Naming helpers
########################################
locals {
  env_upper = upper(var.environment)
  db_name   = "${var.database_name}_${local.env_upper}"
  wh_name   = "${var.warehouse_name}_${local.env_upper}"

  role_raw       = "${var.role_prefix}_RAW_${local.env_upper}"
  role_transform = "${var.role_prefix}_TRANSFORM_${local.env_upper}"
  role_analytics = "${var.role_prefix}_ANALYTICS_${local.env_upper}"
}

########################################
# Database (SYSADMIN)
########################################
resource "snowflake_database" "this" {
  provider = snowflake.sysadmin

  name    = local.db_name
  comment = "Main database for Amazon Review Analytics project"
}

########################################
# Schemas (SYSADMIN)
########################################
resource "snowflake_schema" "raw" {
  provider = snowflake.sysadmin

  database = snowflake_database.this.name
  name     = "RAW"
  comment  = "Raw data layer"
}

resource "snowflake_schema" "stage" {
  provider = snowflake.sysadmin

  database = snowflake_database.this.name
  name     = "STAGE"
  comment  = "Staging / intermediate transformations"
}

resource "snowflake_schema" "mart" {
  provider = snowflake.sysadmin

  database = snowflake_database.this.name
  name     = "MART"
  comment  = "Business-ready analytics marts"
}

########################################
# Warehouse (SYSADMIN)
# Needed for DBT/Airflow/BI queries
########################################
resource "snowflake_warehouse" "this" {
  provider = snowflake.sysadmin

  name           = local.wh_name
  warehouse_size = var.warehouse_size

  auto_suspend = var.warehouse_auto_suspend
  auto_resume  = var.warehouse_auto_resume

  comment = "Compute warehouse for Amazon Review Analytics workloads"
}

########################################
# Roles (SECURITYADMIN)
########################################
resource "snowflake_role" "raw" {
  provider = snowflake.securityadmin

  name    = local.role_raw
  comment = "Role for reading/writing RAW layer objects"
}

resource "snowflake_role" "transform" {
  provider = snowflake.securityadmin

  name    = local.role_transform
  comment = "Role for transforming data from RAW -> STAGE -> MART (DBT/Airflow)"
}

resource "snowflake_role" "analytics" {
  provider = snowflake.securityadmin

  name    = local.role_analytics
  comment = "Role for BI/analytics read-only access (QuickSight/analysts)"
}

########################################
# Role hierarchy (SECURITYADMIN)
# analytics can read marts, transform can build stage/mart, raw is lowest layer.
# You can choose whether to inherit or keep separate. Here we keep them separate
# to enforce least privilege.
########################################

# OPTIONAL: if you want TRANSFORM to also read RAW easily, you can grant RAW to TRANSFORM:
resource "snowflake_role_grants" "transform_inherits_raw" {
  provider = snowflake.securityadmin

  role_name = snowflake_role.transform.name
  roles     = [snowflake_role.raw.name]
}

# OPTIONAL: if you want ANALYTICS to read MART but not RAW/STAGE, do NOT inherit transform.
# We keep analytics isolated.

########################################
# Grants: Database usage (SECURITYADMIN)
########################################
resource "snowflake_database_grant" "db_usage_raw" {
  provider      = snowflake.securityadmin
  database_name = snowflake_database.this.name
  privilege     = "USAGE"
  roles         = [snowflake_role.raw.name]
}

resource "snowflake_database_grant" "db_usage_transform" {
  provider      = snowflake.securityadmin
  database_name = snowflake_database.this.name
  privilege     = "USAGE"
  roles         = [snowflake_role.transform.name]
}

resource "snowflake_database_grant" "db_usage_analytics" {
  provider      = snowflake.securityadmin
  database_name = snowflake_database.this.name
  privilege     = "USAGE"
  roles         = [snowflake_role.analytics.name]
}

########################################
# Grants: Schema usage (SECURITYADMIN)
########################################
resource "snowflake_schema_grant" "raw_schema_usage" {
  provider      = snowflake.securityadmin
  database_name = snowflake_database.this.name
  schema_name   = snowflake_schema.raw.name
  privilege     = "USAGE"
  roles         = [snowflake_role.raw.name, snowflake_role.transform.name]
}

resource "snowflake_schema_grant" "stage_schema_usage" {
  provider      = snowflake.securityadmin
  database_name = snowflake_database.this.name
  schema_name   = snowflake_schema.stage.name
  privilege     = "USAGE"
  roles         = [snowflake_role.transform.name]
}

resource "snowflake_schema_grant" "mart_schema_usage" {
  provider      = snowflake.securityadmin
  database_name = snowflake_database.this.name
  schema_name   = snowflake_schema.mart.name
  privilege     = "USAGE"
  roles         = [snowflake_role.transform.name, snowflake_role.analytics.name]
}

########################################
# Grants: Warehouse usage (SECURITYADMIN)
# - TRANSFORM needs USAGE + OPERATE (DBT runs queries)
# - ANALYTICS typically needs USAGE only
########################################
resource "snowflake_warehouse_grant" "wh_usage_transform" {
  provider       = snowflake.securityadmin
  warehouse_name = snowflake_warehouse.this.name
  privilege      = "USAGE"
  roles          = [snowflake_role.transform.name]
}

resource "snowflake_warehouse_grant" "wh_operate_transform" {
  provider       = snowflake.securityadmin
  warehouse_name = snowflake_warehouse.this.name
  privilege      = "OPERATE"
  roles          = [snowflake_role.transform.name]
}

resource "snowflake_warehouse_grant" "wh_usage_analytics" {
  provider       = snowflake.securityadmin
  warehouse_name = snowflake_warehouse.this.name
  privilege      = "USAGE"
  roles          = [snowflake_role.analytics.name]
}














