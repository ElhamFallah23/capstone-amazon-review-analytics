

resource "snowflake_storage_integration" "this" {
  provider = snowflake.accountadmin

  name    = var.integration_name
  type    = "EXTERNAL_STAGE"
  enabled = true

  storage_provider     = "S3"
  storage_aws_role_arn = var.aws_role_arn

  storage_allowed_locations = var.allowed_locations

  comment = var.comment
}

