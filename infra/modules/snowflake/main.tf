
########################################
# Naming helpers
########################################
locals {
  env_upper = upper(var.environment)

  # Core objects
  db_name = "${var.database_name}_${local.env_upper}"
  wh_name = "${var.warehouse_name}_${local.env_upper}"

  # Account roles (Snowflake "account roles")
  role_raw       = "${var.role_prefix}_RAW_${local.env_upper}"
  role_transform = "${var.role_prefix}_TRANSFORM_${local.env_upper}"
  role_analytics = "${var.role_prefix}_ANALYTICS_${local.env_upper}"

  # Schemas
  schema_raw   = "RAW"
  schema_stage = "STAGE"
  schema_mart  = "MART"

  # Service user role mapping
  default_role_name = (
    upper(var.service_user_default_role) == "RAW" ? local.role_raw :
    upper(var.service_user_default_role) == "ANALYTICS" ? local.role_analytics :
    local.role_transform
  )
}

########################################
# Database (SYSADMIN)
########################################
resource "snowflake_database" "this" {
  provider = snowflake.sysadmin

  name    = local.db_name
  comment = "Main database for Amazon Review Analytics project (${local.env_upper})"
}

########################################
# Schemas (SYSADMIN)
########################################
resource "snowflake_schema" "raw" {
  provider = snowflake.sysadmin

  database = snowflake_database.this.name
  name     = local.schema_raw
  comment  = "Raw data layer"
}

resource "snowflake_schema" "stage" {
  provider = snowflake.sysadmin

  database = snowflake_database.this.name
  name     = local.schema_stage
  comment  = "Staging / intermediate transformations"
}

resource "snowflake_schema" "mart" {
  provider = snowflake.sysadmin

  database = snowflake_database.this.name
  name     = local.schema_mart
  comment  = "Business-ready analytics marts"
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

  comment = "Compute warehouse for DBT/Airflow/BI workloads"
}

########################################
# Account Roles (SECURITYADMIN)
# NOTE: With snowflakedb/snowflake, use account roles (not deprecated snowflake_role).
########################################
resource "snowflake_account_role" "raw" {
  provider = snowflake.securityadmin

  name    = local.role_raw
  comment = "Account role for RAW layer access"
}

resource "snowflake_account_role" "transform" {
  provider = snowflake.securityadmin

  name    = local.role_transform
  comment = "Account role for transformations (DBT + Airflow)"
}

resource "snowflake_account_role" "analytics" {
  provider = snowflake.securityadmin

  name    = local.role_analytics
  comment = "Account role for BI/analytics read access"
}

########################################
# Role hierarchy (SECURITYADMIN)
# Optional: TRANSFORM inherits RAW
########################################
resource "snowflake_grant_account_role" "transform_inherits_raw" {
  provider = snowflake.securityadmin
  count    = var.enable_transform_inherits_raw ? 1 : 0

  role_name        = snowflake_account_role.raw.name
  parent_role_name = snowflake_account_role.transform.name
}

########################################
# Service user (SECURITYADMIN)
# - No password, key-pair auth (RSA public key stored in Snowflake user)
########################################
resource "snowflake_user" "service" {
  provider = snowflake.securityadmin

  name         = var.service_user_name
  login_name   = var.service_user_login_name
  display_name = var.service_user_display_name

  # Key-pair auth (preferred for automation)
  rsa_public_key = var.service_user_rsa_public_key

  default_warehouse = local.wh_name
  disabled          = false
  comment           = "Service user for DBT + Airflow (Terraform-managed)"
}

########################################
# Bind default role to service user
########################################
resource "snowflake_grant_account_role" "service_user_role" {
  provider = snowflake.securityadmin

  role_name = (
    local.default_role_name == local.role_raw ? snowflake_account_role.raw.name :
    local.default_role_name == local.role_analytics ? snowflake_account_role.analytics.name :
    snowflake_account_role.transform.name
  )

  user_name = snowflake_user.service.name
}

########################################
# Set defaults for the service user (SYSADMIN)
# Default role + default warehouse help DBT/Airflow run without extra session SQL.
########################################
resource "snowflake_user" "service_defaults" {
  provider = snowflake.sysadmin

  name = snowflake_user.service.name

  default_role = (
    local.default_role_name == local.role_raw ? snowflake_account_role.raw.name :
    local.default_role_name == local.role_analytics ? snowflake_account_role.analytics.name :
    snowflake_account_role.transform.name
  )

  default_warehouse = var.service_user_default_warehouse ? snowflake_warehouse.this.name : null

  # Keep this user "patch" safe: do not override auth fields here.
  lifecycle {
    ignore_changes = [
      rsa_public_key,
      login_name,
      display_name,
      comment,
      disabled
    ]
  }

  depends_on = [snowflake_user.service]
}

########################################
# Grants (SECURITYADMIN) - Phase 1 essentials
# We grant ONLY what is needed for Phase 2 connectivity and DBT/Airflow operation.
########################################

# ---- Database USAGE ----
resource "snowflake_grant_privileges_to_account_role" "db_usage_raw" {
  provider   = snowflake.securityadmin
  privileges = ["USAGE"]

  on_account_object {
    object_type = "DATABASE"
    object_name = snowflake_database.this.name
  }

  account_role_name = snowflake_account_role.raw.name
}

resource "snowflake_grant_privileges_to_account_role" "db_usage_transform" {
  provider   = snowflake.securityadmin
  privileges = ["USAGE", "CREATE SCHEMA"]

  on_account_object {
    object_type = "DATABASE"
    object_name = snowflake_database.this.name
  }

  account_role_name = snowflake_account_role.transform.name
}

resource "snowflake_grant_privileges_to_account_role" "db_usage_analytics" {
  provider   = snowflake.securityadmin
  privileges = ["USAGE"]

  on_account_object {
    object_type = "DATABASE"
    object_name = snowflake_database.this.name
  }

  account_role_name = snowflake_account_role.analytics.name
}

# ---- Schema USAGE ----
resource "snowflake_grant_privileges_to_account_role" "schema_usage_raw" {
  provider   = snowflake.securityadmin
  privileges = ["USAGE"]

  on_schema {
    schema_name = "${snowflake_database.this.name}.${snowflake_schema.raw.name}"
  }

  account_role_name = snowflake_account_role.raw.name
}

resource "snowflake_grant_privileges_to_account_role" "schema_usage_stage" {
  provider   = snowflake.securityadmin
  privileges = ["USAGE"]

  on_schema {
    schema_name = "${snowflake_database.this.name}.${snowflake_schema.stage.name}"
  }

  account_role_name = snowflake_account_role.transform.name
}

resource "snowflake_grant_privileges_to_account_role" "schema_usage_mart_transform" {
  provider   = snowflake.securityadmin
  privileges = ["USAGE"]

  on_schema {
    schema_name = "${snowflake_database.this.name}.${snowflake_schema.mart.name}"
  }

  account_role_name = snowflake_account_role.transform.name
}

resource "snowflake_grant_privileges_to_account_role" "schema_usage_mart_analytics" {
  provider   = snowflake.securityadmin
  privileges = ["USAGE"]

  on_schema {
    schema_name = "${snowflake_database.this.name}.${snowflake_schema.mart.name}"
  }

  account_role_name = snowflake_account_role.analytics.name
}

# ---- Warehouse privileges ----
# TRANSFORM: USAGE + OPERATE (DBT/Airflow can start/stop and use warehouse)
resource "snowflake_grant_privileges_to_account_role" "wh_usage_transform" {
  provider   = snowflake.securityadmin
  privileges = ["USAGE", "OPERATE"]

  on_account_object {
    object_type = "WAREHOUSE"
    object_name = snowflake_warehouse.this.name
  }

  account_role_name = snowflake_account_role.transform.name
}

# ANALYTICS: USAGE only
resource "snowflake_grant_privileges_to_account_role" "wh_usage_analytics" {
  provider   = snowflake.securityadmin
  privileges = ["USAGE"]

  on_account_object {
    object_type = "WAREHOUSE"
    object_name = snowflake_warehouse.this.name
  }

  account_role_name = snowflake_account_role.analytics.name
}

############# extra objects that are needed according to dbt needs and errors #############
###########################################################################################
###########################################################################################

### grant usage on database 



### grant usage on schema staging 


resource "snowflake_grant_privileges_to_account_role" "schema_stage_transform" {
  provider   = snowflake.securityadmin
  privileges = ["USAGE", "CREATE TABLE", "CREATE VIEW"]

  on_schema {
    schema_name = "${snowflake_database.this.name}.${local.schema_stage}"
  }

  account_role_name = snowflake_account_role.transform.name
}



### grant create view on schema staging 

resource "snowflake_grant_privileges_to_account_role" "schema_raw_select_transform" {
  provider   = snowflake.securityadmin
  privileges = ["USAGE"]

  on_schema {
    schema_name = "${snowflake_database.this.name}.${local.schema_raw}"
  }

  account_role_name = snowflake_account_role.transform.name
}



####### ljojljljljljljljljKHKHKHKH










########################################
# Phase 1 note:
# Table-level grants and future grants (e.g., SELECT on future tables) are usually
# applied by DBT when it creates objects, OR added later in Phase 2 as needed.
########################################



########################################
# DBT essentials - Database-level
########################################
resource "snowflake_grant_privileges_to_account_role" "db_create_temp_table_transform" {
  provider          = snowflake.securityadmin
  privileges        = ["CREATE TEMPORARY TABLE"]
  account_role_name = snowflake_account_role.transform.name

  on_account_object {
    object_type = "DATABASE"
    object_name = snowflake_database.this.name
  }
}





########################################
# DBT essentials - Schema-level (create objects)
########################################
resource "snowflake_grant_privileges_to_account_role" "stage_create_transform" {
  provider          = snowflake.securityadmin
  account_role_name = snowflake_account_role.transform.name
  privileges        = ["CREATE TABLE", "CREATE VIEW"]

  on_schema {
    schema_name = "${snowflake_database.this.name}.${snowflake_schema.stage.name}"
  }
}

resource "snowflake_grant_privileges_to_account_role" "mart_create_transform" {
  provider          = snowflake.securityadmin
  account_role_name = snowflake_account_role.transform.name
  privileges        = ["CREATE TABLE", "CREATE VIEW"]

  on_schema {
    schema_name = "${snowflake_database.this.name}.${snowflake_schema.mart.name}"
  }
}






########################################
# DBT essentials - RAW read access (existing objects)
########################################
resource "snowflake_grant_privileges_to_account_role" "raw_select_all_tables_raw" {
  provider          = snowflake.securityadmin
  account_role_name = snowflake_account_role.raw.name
  privileges        = ["SELECT"]

  on_schema_object {
    all {
      object_type_plural = "TABLES"
      schema_name        = "${snowflake_database.this.name}.${snowflake_schema.raw.name}"
    }
  }
}

resource "snowflake_grant_privileges_to_account_role" "raw_select_all_views_raw" {
  provider          = snowflake.securityadmin
  account_role_name = snowflake_account_role.raw.name
  privileges        = ["SELECT"]

  on_schema_object {
    all {
      object_type_plural = "VIEWS"
      schema_name        = "${snowflake_database.this.name}.${snowflake_schema.raw.name}"
    }
  }
}

resource "snowflake_grant_privileges_to_account_role" "raw_select_all_external_tables_raw" {
  provider          = snowflake.securityadmin
  account_role_name = snowflake_account_role.raw.name
  privileges        = ["SELECT"]

  on_schema_object {
    all {
      object_type_plural = "EXTERNAL TABLES"
      schema_name        = "${snowflake_database.this.name}.${snowflake_schema.raw.name}"
    }
  }
}








########################################
# DBT essentials - RAW read access (future objects)
########################################
resource "snowflake_grant_privileges_to_account_role" "raw_select_future_tables_raw" {
  provider          = snowflake.securityadmin
  account_role_name = snowflake_account_role.raw.name
  privileges        = ["SELECT"]

  on_schema_object {
    future {
      object_type_plural = "TABLES"
      schema_name        = "${snowflake_database.this.name}.${snowflake_schema.raw.name}"
    }
  }
}

resource "snowflake_grant_privileges_to_account_role" "raw_select_future_views_raw" {
  provider          = snowflake.securityadmin
  account_role_name = snowflake_account_role.raw.name
  privileges        = ["SELECT"]

  on_schema_object {
    future {
      object_type_plural = "VIEWS"
      schema_name        = "${snowflake_database.this.name}.${snowflake_schema.raw.name}"
    }
  }
}

resource "snowflake_grant_privileges_to_account_role" "raw_select_future_external_tables_raw" {
  provider          = snowflake.securityadmin
  account_role_name = snowflake_account_role.raw.name
  privileges        = ["SELECT"]

  on_schema_object {
    future {
      object_type_plural = "EXTERNAL TABLES"
      schema_name        = "${snowflake_database.this.name}.${snowflake_schema.raw.name}"
    }
  }
}





