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
  bucket_name = "amazon-ingestion"
  environment = var.environment
}

module "glue" {
  source = "./modules/glue"

  database_name = "amazon_reviews_db"
  crawler_name  = "amazon_reviews_crawler"
  s3_input_path = "s3://amazon-ingestion-dev/reviews/"
  # schedule_expression = "cron(0 12 * * ? *)"
  iam_role_arn = module.iam.glue_crawler_role_arn
  environment  = var.environment
}

module "iam" {
  source        = "./modules/iam"
  environment   = var.environment
  github_repo   = "your-username/your-repo"
  github_branch = "main"
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

# I have a question
#module "oidc_role" {
# source = "./modules/iam"
#environment = var.environment
#github_repo = "your-username/your-repo"
#github_branch = "main"
#}

















#module "lambda" {
# lambda_role_arn = module.iam.lambda_role_arn
#sns_topic_arn = module.sns.topic_arn
#glue_job_name = "amazon_review_etl_${var.environment}"
# environment = terraform.workspace
#}