variable "snowflake_database" {
  description = "Target Snowflake database name"
  type        = string
}

variable "snowflake_schema" {
  description = "Target schema for analytics (e.g., STAGE_MART)"
  type        = string
}

variable "warehouse_name" {
  description = "Warehouse to be used by QuickSight"
  type        = string
}

variable "quicksight_role_name" {
  description = "Role name for QuickSight read access"
  type        = string
  default     = "QS_READER_ROLE"
}

variable "quicksight_user_name" {
  description = "User name for QuickSight"
  type        = string
  default     = "QS_READER_USER"
}

variable "quicksight_user_password" {
  description = "Password for QuickSight user (if using password auth)"
  type        = string
  sensitive   = true
}



