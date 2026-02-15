

variable "quicksight_role_name" {
  description = "Name of Snowflake role for QuickSight"
  type        = string
}

variable "quicksight_user_name" {
  description = "Snowflake username for QuickSight"
  type        = string
}

variable "quicksight_user_password" {
  description = "Password for Snowflake QuickSight user"
  type        = string
  sensitive   = true
}

variable "warehouse_name" {
  description = "Snowflake warehouse name"
  type        = string
}

variable "database_name" {
  description = "Snowflake database name"
  type        = string
}

variable "schema_name" {
  description = "Snowflake schema name (MART)"
  type        = string
}


