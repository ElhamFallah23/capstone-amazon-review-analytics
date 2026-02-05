

output "database_name" {
  description = "Created Snowflake database name."
  value       = snowflake_database.this.name
}

output "warehouse_name" {
  description = "Created Snowflake warehouse name."
  value       = snowflake_warehouse.this.name
}

output "schema_raw" {
  value = snowflake_schema.raw.name
}

output "schema_stage" {
  value = snowflake_schema.stage.name
}

output "schema_mart" {
  value = snowflake_schema.mart.name
}

output "role_raw" {
  value = snowflake_account_role.raw.name
}

output "role_transform" {
  value = snowflake_account_role.transform.name
}

output "role_analytics" {
  value = snowflake_account_role.analytics.name
}

output "service_user_name" {
  value = snowflake_user.service.name
}




