# Create database to hold crawled tables
resource "aws_glue_catalog_database" "reviews_db" {
  name = "${var.database_name}_${var.environment}"
}

# Define a Glue Crawler to scan data in S3 and create table in the above database

resource "aws_glue_crawler" "reviews_crawler" {
  name          = "${var.crawler_name}_${var.environment}"
  role          = var.iam_role_arn # IAM Role with permissions to access S3 and Glue
  database_name = aws_glue_catalog_database.reviews_db.name

  # Define the S3 location wher the data to crawl stored
  s3_target {
    path = var.s3_input_path
  }

  # Crawler will run on daily schedue
  schedule = var.schedule_expression

  classifiers = []

  schema_change_policy {
    delete_behavior = "LOG"
    update_behavior = "UPDATE_IN_DATABASE"
  }

  # Additional configuration: retain existing partition behavior
  configuration = jsonencode({
    Version = 1.0
    CrawlerOutput = {
      Partitions = {
        AddOrUpdateBehavior = "InheritFromTable"
      }
    }
  })
}


