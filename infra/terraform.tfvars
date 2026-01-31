notification_email = "fallah.elham@gmail.com"
github_repo        = "ElhamFallah23/capstone-amazon-review-analytics"
github_branch      = "main"
environment        = "dev"


# Logical name for the Lambda function
lambda_function_name = "amazon-review-lambda"

# IAM role that the Lambda function will assume
lambda_role_name = "amazon-review-lambda-role"

# S3 bucket where your Lambda zip file is stored (already uploaded manually or by pipeline)
lambda_s3_bucket = "capstone-dev-ingestion-bucket"

# Path to the ZIP file inside the S3 bucket
lambda_s3_key = "lambda/lambda.zip"

# Lambda runtime environment
lambda_runtime = "python3.9"

# Lambda handler: filename.method (your Lambda zip must contain 'main.py' with a 'handler' function)
lambda_handler = "main.handler"

# Optional environment variables for Lambda function
lambda_environment_variables = {
  STAGE     = "dev"
  LOG_LEVEL = "INFO"
}





