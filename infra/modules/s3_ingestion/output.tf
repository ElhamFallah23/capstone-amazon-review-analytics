# The name of the created S3 ingestion bucket
output "s3_ingestion_bucket_name" {
  description = "s3 ingestion bucket name"
  value       = aws_s3_bucket.ingestion.bucket # <resource_type>.<resource_name>.<attribute>
}



output "processed_bucket_name" {
  description = "S3 Bucket for Processed Glue output"
  value       = aws_s3_bucket.processed_data.bucket
}

output "glue_scripts_bucket_name" {
  description = "S3 bucket for Glue ETL scripts"
  value       = aws_s3_bucket.glue_scripts.bucket
}


output "glue_script_s3_object_id" {
  value = aws_s3_object.glue_job_script.id
}

output "processed_bucket_arn" {
  description = "ARN of Processed data bucket"
  value       = aws_s3_bucket.processed_data.arn
}


output "raw_bucket_arn" {
  description = "ARN of raw ingestion bucket"
  value       = aws_s3_bucket.ingestion.arn
}