variable "environment" {
  description = "Deployment environment name (e.g., dev, prod)."
  type        = string
}

variable "database_name" {
  description = "Base database name (env suffix will be appended). Example: ARA"
  type        = string
}

variable "warehouse_name" {
  description = "Base warehouse name (env suffix will be appended). Example: ARA_WH"
  type        = string
}

variable "warehouse_size" {
  description = "Snowflake warehouse size. Example: XSMALL, SMALL, MEDIUM..."
  type        = string
  default     = "XSMALL"
}

variable "warehouse_auto_suspend" {
  description = "Auto suspend in seconds."
  type        = number
  default     = 60
}

variable "warehouse_auto_resume" {
  description = "Auto resume warehouse when queries arrive."
  type        = bool
  default     = true
}

variable "role_prefix" {
  description = "Role name prefix. Example: ARA"
  type        = string
  default     = "ARA"
}

variable "enable_transform_inherits_raw" {
  description = "If true, TRANSFORM role inherits RAW role."
  type        = bool
  default     = true
}

# ----------------------------
# Service user (DBT + Airflow)
# ----------------------------
variable "service_user_name" {
  description = "Single service user for DBT + Airflow."
  type        = string
}

variable "service_user_login_name" {
  description = "Login name for the service user. Usually same as user name."
  type        = string
}

variable "service_user_display_name" {
  description = "Display name for the service user."
  type        = string
  default     = "DBT+Airflow Service User"
}

variable "service_user_rsa_public_key" {
  description = "RSA public key for key-pair authentication (no password)."
  type        = string
  sensitive   = true
}

variable "service_user_default_role" {
  description = "Default role for the service user. Typically TRANSFORM."
  type        = string
  default     = "TRANSFORM"
}

variable "service_user_default_warehouse" {
  description = "Whether to set default warehouse for the service user."
  type        = bool
  default     = true
}




