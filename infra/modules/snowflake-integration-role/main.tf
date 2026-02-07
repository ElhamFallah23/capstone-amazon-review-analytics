


########################################
# IAM Role for Snowflake Storage Integration
# Bootstrap version (temporary trust)
########################################

resource "aws_iam_role" "this" {
  name = var.role_name

  ########################################
  # Temporary trust policy (bootstrap)
  # Will be tightened after Snowflake integration is created
  ########################################
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          #AWS = "*" # AWS = "*"  : Bootstrap
          type        = "AWS"
          identifiers = [var.integration_aws_iam_user_arn]
        }
        Action = "sts:AssumeRole"
        condition = {
          values = [var.integration_external_id]
        }
      }
    ]
  })

  tags = var.tags
}

########################################
# IAM Policy: Allow Snowflake to read S3
########################################
resource "aws_iam_policy" "s3_read" {
  name        = "${var.role_name}-s3-read"
  description = "Allow Snowflake to read data from S3"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:GetObjectVersion"
        ]
        Resource = flatten([
          for arn in var.s3_bucket_arn : [
            arn,
            "${arn}/*"
          ]
        ])
      },
      {
        Effect = "Allow"
        Action = [
          "s3:ListBucket"
        ]
        Resource = var.s3_bucket_arn
      }
    ]
  })
}

########################################
# Attach policy to role
########################################
resource "aws_iam_role_policy_attachment" "attach_s3_read" {
  role       = aws_iam_role.this.name
  policy_arn = aws_iam_policy.s3_read.arn
}







