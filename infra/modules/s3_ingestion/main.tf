# Create S3 bucket for ingestion
resource "aws_s3_bucket" "ingestion" {
  bucket = "${var.raw_bucket_name}-${var.environment}"

  tags = {
    Name        = "Ingestion Bucket"
    Environment = var.environment
  }
}

# Recommended: block public access to the bucket
resource "aws_s3_bucket_public_access_block" "block_public_access" {
  bucket = aws_s3_bucket.ingestion.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Optional: enable versioning when requested
resource "aws_s3_bucket_versioning" "versioning" {
  bucket = aws_s3_bucket.ingestion.id # for s3: .id == .bucket in other words, attribute "id" is unique resource identifier used to reference that specific resource from other resources.

  versioning_configuration {
    status = var.enable_versioning ? "Enabled" : "Suspended"
  }
}

# Recommended: server-side encryption (SSE-S3)
resource "aws_s3_bucket_server_side_encryption_configuration" "sse" {
  bucket = aws_s3_bucket.ingestion.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}


# Create S3 bucket for Glue scripts
resource "aws_s3_bucket" "glue_scripts" {
  bucket = "${var.glue_scripts_bucket_name}-${var.environment}"

  tags = {
    Name        = "Glue scripts Bucket"
    Environment = var.environment
  }
}


# Create S3 bucket for Output of Glue Job
resource "aws_s3_bucket" "processed_data" {
  bucket = "${var.processed_bucket_name}-${var.environment}"

  tags = {
    Name        = "Processed Data Bucket"
    Environment = var.environment
  }
}



# ------------------------------------------------------------
# Upload Glue ETL script to S3
# This script will be executed by AWS Glue Job
# ------------------------------------------------------------
resource "aws_s3_object" "glue_job_script" {
  bucket = aws_s3_bucket.glue_scripts.bucket

  # S3 key (path) where the script will be stored
  key = "glue/reviews_etl_job.py"

  # Local path to the Glue ETL Python script
  source = "${path.module}/glue/reviews_etl_job.py"

  # Ensures Terraform detects script changes and re-uploads
  etag = filemd5("${path.module}/glue/reviews_etl_job.py") ### To track changes that occer in Python file; Glue Job always run the up-to-date script
}