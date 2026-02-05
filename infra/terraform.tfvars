notification_email = "fallah.elham@gmail.com"
github_repo        = "ElhamFallah23/capstone-amazon-review-analytics"
github_branch      = "main"

########################################
# Environment
########################################

environment = "dev"


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





########################################
# Snowflake connection
########################################
snowflake_account  = "KEMXMAE-OW63667"
snowflake_username = "TERRAFORM_USER"
snowflake_region   = "eu-central-1"
#snowflake_private_key_path = ".../public_private_key_snowflake/snowflake_tf_private_key.pem"

########################################
# Snowflake objects
########################################
database_name  = "AMAZON_REVIEW_ANALYTICS"
warehouse_name = "ARA_WH"

########################################
# Service user (DBT + Airflow)
########################################
service_user_name       = "DBT_AIRFLOW_SVC"
service_user_login_name = "DBT_AIRFLOW_SVC"

# PUBLIC key only (safe for git)

service_user_rsa_public_key = <<EOF
-----BEGIN PUBLIC KEY-----
"MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAsQgsjwKAXOw3WoQ5XY3qyKaIfMYbWJTG/+jTLc41gtBBhNDLSRKQCzUght0EG72V8VwitAkTmAXTNvQiaKxRlz/qACCosWY9sK/0ghvMONhMdLrBmpct4wImzYLX3IZkHaNYpTahiinHGSJn1l2i8fLOBJThu9oVU2pYnRsKotKkUr+N1i108m/CHi7vB14Albw97A2awIUo11EoGw6ZSUEs4VmBOwRhT5Jd+zTOIC8pPnN809yz2WmLI1YQq3C5Mrk9B/Es5mT7Q0BNOznqGzJH+HNe1ex4NG85RwankEgZQl7Ji2clCZMvWDTQAdjI5nvm9oYhn2ieIBj3IHsEcwIDAQAB"
-----END PUBLIC KEY-----
EOF








