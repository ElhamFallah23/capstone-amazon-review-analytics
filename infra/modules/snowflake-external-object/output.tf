
output "stage_name" {
value = snowflake_stage.external_stage.name
}

output "external_table_name" {
value = snowflake_external_table.external_table.name
}

