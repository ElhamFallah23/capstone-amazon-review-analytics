

output "database_name" {
  description = "Snowflake database name"
  value       = snowflake_database.this.name
}

output "warehouse_name" {
  description = "Snowflake warehouse name"
  value       = snowflake_warehouse.this.name
}

output "role_raw" {
  description = "Role name for RAW layer access"
  value       = snowflake_role.raw.name
}

output "role_transform" {
  description = "Role name for DBT/Airflow transformations"
  value       = snowflake_role.transform.name
}

output "role_analytics" {
  description = "Role name for BI/analytics read access"
  value       = snowflake_role.analytics.name
}

output "raw_schema" {
  value = snowflake_schema.raw.name
}

output "stage_schema" {
  value = snowflake_schema.stage.name
}

output "mart_schema" {
  value = snowflake_schema.mart.name
}





