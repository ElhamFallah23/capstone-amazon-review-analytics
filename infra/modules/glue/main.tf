# Create database to hold crawled tables
resource "aws_glue_catalog_database" "reviews_db" {
  name = "${var.glue_database_name}_${var.environment}"
}

# Define a Glue Crawler to scan data in S3 and create table in the above database
resource "aws_glue_crawler" "reviews_crawler" {
  name          = "${var.crawler_name}_${var.environment}"
  role          = var.iam_role_arn_crawler                  # IAM Role with permissions to access S3 and Glue
  database_name = aws_glue_catalog_database.reviews_db.name #!!!!

  # Define the S3 location where the data to crawl stored
  s3_target {
    path = var.raw_s3_path
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



#############################################
# AWS Glue Job
# This job processes raw Amazon review JSON
# files from S3 and writes flattened Parquet
# data back to S3 for downstream analytics.
#############################################

resource "aws_glue_job" "reviews_etl_job" {

  # Name of the Glue Job (used by Step Function)
  name = "${var.glue_job_name}_${var.environment}"

  # IAM role assumed by Glue at runtime
  role_arn = var.iam_role_arn_glue_job

  # Glue version (recommended stable version)
  glue_version = "4.0"

  # Number of workers allocated to the job
  number_of_workers = var.number_of_workers

  # Worker type (G.1X is common for ETL jobs)
  worker_type = "G.1X"

  # Max execution time in minutes
  timeout = var.job_timeout

  ###########################################
  # Command configuration
  ###########################################
  command {

    # Glue Spark job
    name = "glueetl"

    # S3 path where the PySpark script is stored
    script_location = var.script_s3_path

    # Python version used by Glue
    python_version = "3"
  }

  ###########################################
  # Default arguments passed to the job
  ###########################################
  default_arguments = {

    # Required by Glue
    "--job-language" = "python"

    # Enable CloudWatch logs
    "--enable-continuous-cloudwatch-log" = "true"

    # Enable Spark UI for debugging
    "--enable-spark-ui" = "true"

    # CloudWatch log group name
    "--continuous-log-logGroup" = "/aws/glue/${var.glue_job_name}"

    # Temp directory used by Glue
    "--TempDir" = var.temp_s3_path

    "--glue_database_name" = var.glue_database_name
    "--glue_table_name"    = var.glue_table_name

    # Custom job parameters
    "--raw_input_path"        = var.raw_s3_path
    "--processed_output_path" = var.processed_s3_path
    "--environment"           = var.environment
  }


  depends_on = [
    var.glue_script_s3_object_dependency
  ]

  ###########################################
  # Retry behavior (Glue-level)
  # Step Function will also handle retries
  ###########################################
  max_retries = 0

  ###########################################
  # Tags for cost tracking and ownership
  ###########################################
  tags = {
    Project     = "amazon-review-analytics"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}






