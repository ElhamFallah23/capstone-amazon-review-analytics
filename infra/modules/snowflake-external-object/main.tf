

terraform {
  required_providers {
    snowflake = {
      source = "snowflakedb/snowflake"
    }
  }
}

##############################################
# Snowflake File Format (Parquet)
##############################################

resource "snowflake_file_format" "parquet_format" {
  name     = "${var.stage_name}_PARQUET_FORMAT"
  database = var.database_name
  schema   = var.schema_name

  format_type = "PARQUET"
}

##############################################
# Snowflake Stage
##############################################

resource "snowflake_stage" "external_stage" {
  name     = var.stage_name
  database = var.database_name
  schema   = var.schema_name

  url                 = var.s3_url
  storage_integration = var.storage_integration_name
  file_format         = snowflake_file_format.parquet_format.name
}

##############################################
# Snowflake External Table
##############################################

resource "snowflake_external_table" "external_table" {
  name     = var.external_table_name
  database = var.database_name
  schema   = var.schema_name

  location    = "@${snowflake_stage.external_stage.name}"
  file_format = snowflake_file_format.parquet_format.name

  auto_refresh         = var.auto_refresh
  notification_channel = var.notification_channel

  dynamic "column" {
    for_each = var.columns
    content {
      name = column.value.name
      type = column.value.type
      as   = column.value.expression
    }
  }
}

##############################################
# Grants for Transform Role
##############################################

resource "snowflake_table_grant" "external_table_select" {
  database_name = var.database_name
  schema_name   = var.schema_name
  table_name    = var.external_table_name

  privilege = "SELECT"
  roles     = [var.transform_role_name]
}





