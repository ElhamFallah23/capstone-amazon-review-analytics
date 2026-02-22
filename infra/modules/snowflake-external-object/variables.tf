variable "database_name" {
description = "Name of the Snowflake database"
type = string
}

variable "schema_name" {
description = "Schema where stage and external table will be created"
type = string
}

variable "storage_integration_name" {
description = "Snowflake storage integration name"
type = string
}

variable "stage_name" {
description = "Name of the Snowflake stage"
type = string
}

variable "external_table_name" {
description = "Name of the external table"
type = string
}

variable "s3_url" {
description = "Full S3 URL including prefix (must end with /)"
type = string
}

variable "columns" {
description = "List of external table columns"
type = list(object({
name = string
type = string
expression = string
}))
}

variable "transform_role_name" {
description = "Role that will have read access to the external table"
type = string
}

variable "auto_refresh" {
description = "Enable auto refresh for external table"
type = bool
default = false
}

variable "notification_channel" {
description = "SNS topic ARN for Snowflake auto refresh"
type = string
default = null
}




