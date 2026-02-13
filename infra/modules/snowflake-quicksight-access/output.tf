

output "quicksight_role_name" {
  value = snowflake_role.quicksight_role.name
}

output "quicksight_user_name" {
  value = snowflake_user.quicksight_user.name
}
