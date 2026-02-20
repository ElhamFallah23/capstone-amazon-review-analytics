provider "aws" {
  region = "eu-central-1"
}

module "bootstrap" {
  source          = "./modules/bootstrap"
  bucket_name     = "capstone-terraform-state-bucket"
  lock_table_name = "capstone-tf-locks"
  environment     = var.environment
}

module "s3_ingestion" {
  source      = "./modules/s3_ingestion"
  environment = var.environment

  raw_bucket_name          = "amazon-ingestion"
  glue_scripts_bucket_name = "amazon-glue-scripts-bucket"
  processed_bucket_name    = "amazon-processed-bucket"

  tags = {
    Project     = "amazon-review-analytics"
    Environment = var.environment
    ManagedBy   = "terraform"
  }
  enable_versioning = true
}


# ============================================================
# Glue Module
# This module provisions:
# - Glue Catalog Database
# - Glue Crawler (raw zone)
# - Glue ETL Job (raw -> processed)
#
# It is a core part of the ETL pipeline shown in the architecture:
# S3 (raw) -> Glue Crawler -> Glue Catalog -> Glue Job -> S3 (processed)
# ============================================================

module "glue" {
  source      = "./modules/glue"
  environment = var.environment

  glue_script_s3_object_dependency = module.s3_ingestion.glue_script_s3_object_id

  glue_database_name   = "amazon_reviews_crawler"             # Glue Catalog Database: This database will hold tables created by the crawler
  crawler_name         = "amazon-reviews-raw-crawler"         # The crawler scans raw S3 data and creates catalog tables
  raw_s3_path          = "s3://amazon-ingestion-dev/reviews/" # "s3://${module.s3_ingestion.s3_ingestion_bucket_name}/raw/reviews/"      # "s3://amazon-ingestion-dev/reviews/"
  iam_role_arn_crawler = module.iam.glue_crawler_role_arn


  # Optional: run crawler on schedule (can be null for manual runs)
  # schedule_expression = null #  "cron(0 12 * * ? *)"

  glue_job_name         = "amazon-reviews-etl" # Glue ETL Job configuration: This job flattens raw JSON and writes Parquet to processed zone
  script_s3_path        = "s3://${module.s3_ingestion.glue_scripts_bucket_name}/glue-scripts/review-job/reviews_etl_job.py"
  processed_s3_path     = "s3://${module.s3_ingestion.processed_bucket_name}/processed/reviews/"
  iam_role_arn_glue_job = module.iam.glue_job_role_arn

  temp_s3_path = "s3://${module.s3_ingestion.glue_scripts_bucket_name}/glue-temp/${var.environment}/"

  # ------------------------------------------------------------
  # Glue Catalog table name
  # This table is created by the crawler and later read by the Glue job
  # ------------------------------------------------------------
  review_glue_table_name = "reviews"



  ######## Add crawler for meta input file #########
  ##################################################
  crawler_name_meta = "amazon-meta-raw-crawler"         # The crawler scans raw S3 data and creates catalog tables
  raw_s3_path_meta  = "s3://amazon-ingestion-dev/meta/" # "s3://${module.s3_ingestion.s3_ingestion_bucket_name}/raw/reviews/"      # "s3://amazon-ingestion-dev/reviews/"

  glue_job_name_meta     = "amazon-meta-etl" # Glue ETL Job configuration: This job flattens raw JSON and writes Parquet to processed zone
  script_s3_path_meta    = "s3://${module.s3_ingestion.glue_scripts_bucket_name}/glue-scripts/meta-job/meta_etl_job.py"
  processed_s3_path_meta = "s3://${module.s3_ingestion.processed_bucket_name}/processed/meta/"


  meta_glue_table_name = "meta"
  ##################################################

}


#ugugugu



module "iam" {
  source      = "./modules/iam"
  environment = var.environment

  github_repo   = var.github_repo
  github_branch = var.github_branch

  raw_bucket_arn       = module.s3_ingestion.raw_bucket_arn       # ok
  processed_bucket_arn = module.s3_ingestion.processed_bucket_arn # okkk
  scripts_bucket_arn   = module.s3_ingestion.scripts_bucket_arn

  project_tag          = "AmazonReviewAnalytics"
  sns_topic_arn        = module.sns.sns_topic_arn
  lambda_function_name = "glue_job_status_checker"


  state_machine_name        = "reviews-etl-workflow"
  glue_job_arn              = module.glue.glue_job_arn
  lambda_status_checker_arn = module.iam.lambda_role_arn


}

module "sns" {
  source             = "./modules/sns"
  environment        = var.environment
  notification_email = var.notification_email
}

# Attach the SNS full access policy to local terraform IAM user *****
resource "aws_iam_user_policy_attachment" "sns_user_attach" {
  user       = "capston-terraform-user"
  policy_arn = module.iam.sns_fullaccess_policy_arn
}

module "lambda" {
  source = "./modules/lambda"

  environment     = var.environment
  project_tag     = "AmazonReviewAnalytics"
  glue_job_name   = module.glue.glue_job_name
  sns_topic_arn   = module.sns.sns_topic_arn
  lambda_role_arn = module.iam.lambda_role_arn
}


module "glue_status_lambda" {
  source = "./modules/lambda"

  # General environment configuration
  environment = var.environment

  # Lambda function configuration 
  lambda_function_name = "glue_job_status_checker"

  # Glue integration 
  glue_job_name = module.glue.glue_job_name

  # IAM Role created in IAM module 
  lambda_role_arn = module.iam.lambda_role_arn

  # SNS integration for notifications
  sns_topic_arn = module.sns.sns_topic_arn

  project_tag = "AmazonReviewAnalytics"
}



module "stepfunction" {
  source = "./modules/stepfunction"

  environment = var.environment
  project_tag = "AmazonReviewAnalytics"


  state_machine_name    = "reviews-etl-workflow"
  stepfunction_role_arn = module.iam.stepfunction_role_arn

  glue_job_name = module.glue.glue_job_name
  #glue_job_arn              = module.iam.glue_job_role_arn
  lambda_status_checker_arn = module.lambda.lambda_function_arn

  poll_interval_seconds = 60
  enable_logging        = true

  # Optional: pass Glue args overrides if you want to override defaults at runtime
  glue_arguments_override = {}
}




########################################
# Snowflake infrastructure (Phase 1)
########################################
module "snowflake" {
  source = "./modules/snowflake"

  ####################################
  # Providers
  ####################################
  providers = {
    snowflake.sysadmin      = snowflake.sysadmin
    snowflake.securityadmin = snowflake.securityadmin
  }

  ####################################
  # Environment
  ####################################
  environment = var.environment

  ####################################
  # Core objects
  ####################################
  database_name  = var.database_name
  warehouse_name = var.warehouse_name

  ####################################
  # Roles
  ####################################
  role_prefix = "ARA"

  ####################################
  # Service user
  ####################################
  service_user_name           = var.service_user_name
  service_user_login_name     = var.service_user_login_name
  service_user_display_name   = "DBT + Airflow Service User"
  service_user_rsa_public_key = var.service_user_rsa_public_key

  # DBT/Airflow should operate & transform
  service_user_default_role = "TRANSFORM"
}


####################################
# snowflake_integration_role
####################################

module "snowflake_integration_role" {
  source = "./modules/snowflake-integration-role"


  integration_aws_iam_user_arn = var.integration_aws_iam_user_arn
  integration_external_id      = var.integration_external_id


  role_name = "snowflake-s3-integration-role"
  s3_bucket_arn = [
    module.s3_ingestion.raw_bucket_arn,
    module.s3_ingestion.processed_bucket_arn
  ]
  s3_prefixes = [
    "raw/",
    "stage/"
  ]

}




####################################
# snowflake_integration
####################################

module "snowflake_storage_integration" {
  source = "./modules/snowflake-integration"

  integration_name = "ARA_S3_INTEGRATION"

  aws_role_arn = module.snowflake_integration_role.role_arn


  allowed_locations = [
    "s3://${module.s3_ingestion.s3_ingestion_bucket_name}/",
    "s3://${module.s3_ingestion.processed_bucket_name}/"
  ]

  providers = {
    snowflake.accountadmin = snowflake.accountadmin
  }
}




####################################################
# QuickSight Snowflake Access (BI Layer)
####################################################

module "snowflake_quicksight_access" {
  source = "./modules/snowflake-quicksight-access"
  providers = {
    snowflake.accountadmin  = snowflake.accountadmin
    snowflake.sysadmin      = snowflake.sysadmin
    snowflake.securityadmin = snowflake.securityadmin

  }

  quicksight_role_name     = var.quicksight_role_name
  quicksight_user_name     = var.quicksight_user_name
  quicksight_user_password = var.quicksight_user_password

  warehouse_name = "COMPUTE_WH"
  database_name  = "AMAZON_REVIEW_ANALYTICS_DEV"
  schema_name    = var.mart_schema_name
}



####################################################
# EventBridge 
####################################################

module "eventbridge_trigger" {
  source = "./modules/eventbridge"

  environment       = var.environment
  bucket_name       = module.s3_ingestion.s3_ingestion_bucket_name
  state_machine_arn = module.stepfunction.state_machine_arn
}

