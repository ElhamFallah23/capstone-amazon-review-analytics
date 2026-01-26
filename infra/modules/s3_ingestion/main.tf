# Create S3 bucket for ingestion
resource "aws_s3_bucket" "ingestion" {
  bucket = "${var.bucket_name}-${var.environment}"

  tags = { 
    Name = "Ingestion Bucket"
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
  bucket = aws_s3_bucket.ingestion.id         # for s3: .id == .bucket in other words, attribute "id" is unique resource identifier used to reference that specific resource from other resources.

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




