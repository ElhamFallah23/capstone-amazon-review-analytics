
output "glue_database_name" {
  value = aws_glue_catalog_database.reviews_db.name
}

output "glue_crawler_name" {
  value = aws_glue_crawler.reviews_crawler.name
}

#############################################
#  Output for Glue Job 
#############################################

output "glue_job_name" {
  description = "Name of the Glue Job to be invoked by Step Functions"
  value       = aws_glue_job.reviews_etl_job.name
}

output "glue_job_arn" {
  description = "ARN of the Glue Job"
  value       = aws_glue_job.reviews_etl_job.arn
}
