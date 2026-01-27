# The name of the created S3 ingestion bucket
output "s3_ingestion_bucket_name" {
  description = "s3 ingestion bucket name"
  value       = aws_s3_bucket.ingestion.bucket # <resource_type>.<resource_name>.<attribute>
}