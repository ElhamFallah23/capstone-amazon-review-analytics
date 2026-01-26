
output "glue_database_name" {
  value = aws_glue_catalog_database.reviews_db.name
}

output "glue_crawler_name" {
  value = aws_glue_crawler.reviews_crawler.name
}

