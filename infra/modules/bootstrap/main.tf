
## Comment this file if bootstrap already done
## Create S3 bucket for Terraform remote state
#resource "aws_s3_bucket" "tf_state" {
#  bucket = "${var.bucket_name}-${var.environment}"

#  tags = { 
#    Name = "${var.bucket_name}-${var.environment}"
#    Environment = var.environment}
#}

## Recommended: block public access to the bucket
#resource "aws_s3_bucket_public_access_block" "tf_state" {
#  bucket = aws_s3_bucket.tf_state.id

#  block_public_acls       = true
#  block_public_policy     = true
#  ignore_public_acls      = true
#  restrict_public_buckets = true
#}

## Optional: enable versioning when requested
#resource "aws_s3_bucket_versioning" "tf_state" {
#  bucket = aws_s3_bucket.tf_state.id

#  versioning_configuration {
#    status = var.enable_versioning ? "Enabled" : "Suspended"
#  }
#}

## Recommended: server-side encryption (SSE-S3)
#resource "aws_s3_bucket_server_side_encryption_configuration" "tf_state" {
#  bucket = aws_s3_bucket.tf_state.id

#  rule {
#    apply_server_side_encryption_by_default {
#      sse_algorithm = "AES256"
#    }
#  }
#}

## DynamoDB table for state locking
#resource "aws_dynamodb_table" "tf_lock" {
#    name = "${var.lock_table_name}-${var.environment}"
#    billing_mode = "PAY_PER_REQUEST"
#    hash_key = "LockID"

#    attribute {
#        name = "LockID"
#        type = "S"
#    }
#    tags = { 
#      Name = "${var.lock_table_name}-${var.environment}"
#      Environment = var.environment
#    }
#}


