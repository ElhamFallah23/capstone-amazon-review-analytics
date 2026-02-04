########################################
# Naming helpers
########################################
locals {
  env_upper = upper(var.environment)

  db_name = "${var.database_name}_${local.env_upper}"
  wh_name = "${var.warehouse_name}_${local.env_upper}"

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
# Warehouse (SYSADMIN)
########################################
resource "snowflake_warehouse" "this" {
  provider = snowflake.sysadmin

  name           = local.wh_name
  warehouse_size = var.warehouse_size

  auto_suspend = var.warehouse_auto_suspend
  auto_resume  = var.warehouse_auto_resume

  comment = "Compute warehouse for DBT, Airflow and BI workloads"
}

########################################
# Roles (SECURITYADMIN)
########################################
resource "snowflake_account_role" "raw" {
  provider = snowflake.securityadmin

  name    = local.role_raw
  comment = "Role for RAW layer access"
}

resource "snowflake_account_role" "transform" {
  provider = snowflake.securityadmin

  name    = local.role_transform
  comment = "Role for DBT / Airflow transformations"
}

resource "snowflake_account_role" "analytics" {
  provider = snowflake.securityadmin

  name    = local.role_analytics
  comment = "Read-only analytics / BI role"
}

########################################
# Role hierarchy
# TRANSFORM inherits RAW
########################################
resource "snowflake_grant" "transform_inherits_raw" {
  provider  = snowflake.securityadmin
  privilege = "USAGE"

  on_role {
    name = snowflake_account_role.raw.name
  }

  roles = [snowflake_account_role.transform.name]
}

########################################
# Database USAGE grants
########################################
resource "snowflake_grant" "db_usage_raw" {
  provider  = snowflake.securityadmin
  privilege = "USAGE"

  on {
    database_name = snowflake_database.this.name
  }

  roles = [snowflake_account_role.raw.name]
}

resource "snowflake_grant" "db_usage_transform" {
  provider  = snowflake.securityadmin
  privilege = "USAGE"

  on {
    database_name = snowflake_database.this.name
  }

  roles = [snowflake_account_role.transform.name]
}

resource "snowflake_grant" "db_usage_analytics" {
  provider  = snowflake.securityadmin
  privilege = "USAGE"

  on {
    database_name = snowflake_database.this.name
  }

  roles = [snowflake_account_role.analytics.name]
}

########################################
# Schema USAGE grants
########################################
resource "snowflake_grant" "raw_schema_usage" {
  provider  = snowflake.securityadmin
  privilege = "USAGE"

  on {
    schema {
      database_name = snowflake_database.this.name
      schema_name   = snowflake_schema.raw.name
    }
  }

  roles = [
    snowflake_account_role.raw.name,
    snowflake_account_role.transform.name
  ]
}

resource "snowflake_grant" "stage_schema_usage" {
  provider  = snowflake.securityadmin
  privilege = "USAGE"

  on {
    schema {
      database_name = snowflake_database.this.name
      schema_name   = snowflake_schema.stage.name
    }
  }

  roles = [snowflake_account_role.transform.name]
}

resource "snowflake_grant" "mart_schema_usage" {
  provider  = snowflake.securityadmin
  privilege = "USAGE"

  on {
    schema {
      database_name = snowflake_database.this.name
      schema_name   = snowflake_schema.mart.name
    }
  }

  roles = [
    snowflake_account_role.transform.name,
    snowflake_account_role.analytics.name
  ]
}

########################################
# Warehouse grants
########################################
resource "snowflake_grant" "wh_usage_transform" {
  provider  = snowflake.securityadmin
  privilege = "USAGE"

  on {
    warehouse_name = snowflake_warehouse.this.name
  }

  roles = [snowflake_account_role.transform.name]
}

resource "snowflake_grant" "wh_operate_transform" {
  provider  = snowflake.securityadmin
  privilege = "OPERATE"

  on {
    warehouse_name = snowflake_warehouse.this.name
  }

  roles = [snowflake_account_role.transform.name]
}

resource "snowflake_grant" "wh_usage_analytics" {
  provider  = snowflake.securityadmin
  privilege = "USAGE"

  on {
    warehouse_name = snowflake_warehouse.this.name
  }

  roles = [snowflake_account_role.analytics.name]
}