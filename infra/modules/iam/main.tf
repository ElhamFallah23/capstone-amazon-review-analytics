
# Create IAM Role for Glue Crawler
resource "aws_iam_role" "glue_crawler_role" {
  name = "glue-crawler-role-${var.environment}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "glue.amazonaws.com" # <--- assume_role_policy define which AWS service can use or is allowed to assume this IAM Role
        }
      }
    ]
  })

  tags = {
    Name        = "Glue Crawler Role"
    Environment = var.environment
  }
}

# Attach AWS managed policy for Glue service access to S3
resource "aws_iam_role_policy_attachment" "glue_service" {
  role       = aws_iam_role.glue_crawler_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSGlueServiceRole"
}
resource "aws_iam_role_policy_attachment" "glue_s3_access" {
  role       = aws_iam_role.glue_crawler_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
}
#######################



# Create IAM Policy for SNS permissions
resource "aws_iam_policy" "sns_full_access" {
  name        = "sns_full_access-${var.environment}"
  description = " Policy for SNS access for Terraform user"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        Effect = "Allow",
        Action = [
          "sns:GetTopicAttributes",
          "sns:SetTopicAttributes",
          "sns:CreateTopic",
          "sns:Subscribe",
          "sns:Publish",
          "sns:ListSubscriptionsByTopic",
          "sns:DeleteTopic",
          "sns:ListTagsForResource",
          "sns:GetSubscriptionAttributes",
          "sns:SetSubscriptionAttributes"
        ],
        Resource = "*"
      }
    ]
  })

  tags = {
    Name        = "SNS Full Access"
    Environment = var.environment
  }
}




# -----------------

# Create an OpenID Connect (OIDC) provider for GitHub Actions
# This tells AWS to trust tokens issued by GitHub Actions
resource "aws_iam_openid_connect_provider" "github" {

  # GitHub's OIDC token issuer URL
  url = "https://token.actions.githubusercontent.com"

  # List of client IDs (audiences) that are allowed
  client_id_list = [
    "sts.amazonaws.com"
  ]

  # GitHub OIDC root certificate thumbprint
  thumbprint_list = [
    "6938fd4d98bab03faadb97b34396831e3780aea1"
  ]
}


# Get current AWS Account ID for building the trust policy 
data "aws_caller_identity" "current" {}

# Create IAM role to be assumed by GitHub Actions via OIDC
resource "aws_iam_role" "github_actions_oidc" {
  name = "github-actions-oidc-role-${var.environment}"

  assume_role_policy = jsonencode({ #who can assume this Role
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        #federated principle = OIDC provider(Github)
        Principal = { # who = token.actions.githubusercontent.com
          Federated = aws_iam_openid_connect_provider.github.arn
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        "Condition" : {
          "StringEquals" : {
            "token.actions.githubusercontent.com:aud" : "sts.amazonaws.com"
          },
          "StringLike" : {
            "token.actions.githubusercontent.com:sub" : [
              #"repo:ElhamFallah23/capstone-amazon-review-analytics:ref:refs/heads/main",
              #"repo:ElhamFallah23/capstone-amazon-review-analytics:pull_request",
              #"repo:ElhamFallah23/capstone-amazon-review-analytics:ref:refs/heads/*",
              "repo:ElhamFallah23/capstone-amazon-review-analytics:*",
              #"repo:ElhamFallah23/capstone-amazon-review-analytics:environment:dev-approve"
            ]
          }
        }
      }
    ]
  })

  tags = {
    Name        = "GitHub Actions OIDC Role"
    Environment = var.environment
  }
}

# Policy for allowing full access to manage Terraform resources
resource "aws_iam_policy" "terraform_access" {
  name        = "terraform-access-policy-${var.environment}"
  description = "Allows Terraform to manage AWS resources"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = "*"
        Resource = "*"
      }
    ]
  })
}


# Attach the terraform_access policy to github_actions_oidc Role to manage Terraform resources
resource "aws_iam_role_policy_attachment" "attach_terraform_access" {
  role       = aws_iam_role.github_actions_oidc.name
  policy_arn = aws_iam_policy.terraform_access.arn
}





# ------------------------------------------------------------
# IAM Role for AWS Glue ETL Job
# This role is assumed by Glue Job to read/write data in S3
# and publish logs to CloudWatch.
# ------------------------------------------------------------

resource "aws_iam_role" "glue_job_role" {
  name = "glue-job-role-${var.environment}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "glue.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Project     = "amazon-review-analytics"
    Environment = var.environment
    Service     = "glue"
    RoleType    = "glue-job"
  }
}

# ------------------------------------------------------------
# IAM Policy for Glue Job
# ------------------------------------------------------------
resource "aws_iam_policy" "glue_job_policy" {
  name        = "glue-job-policy-${var.environment}"
  description = "Permissions for Glue ETL job to access S3 and CloudWatch logs"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [

      # ------------------------------------------------------
      # Allow Glue Job to read raw data from S3 and access to script bucket to read glue job scripts
      # ------------------------------------------------------
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:ListBucket"
        ]
        Resource = [
          var.raw_bucket_arn,
          "${var.raw_bucket_arn}/*"
        ]
      },

      # ------------------------------------------------------
      # Allow Glue Job to write processed data to S3
      # ------------------------------------------------------
      {
        Effect = "Allow"
        Action = [
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:GetObject",
        ]
        Resource = [
          "${var.processed_bucket_arn}/*"
        ]
      },

      {
        Effect = "Allow"
        Action = [
          "s3:ListBucket"
        ]
        Resource = [
          "${var.processed_bucket_arn}"
        ]
      },


      # ------------------------------------------------------
      # Allow Glue Job to write logs to CloudWatch
      # ------------------------------------------------------
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "*"
      },
      # ------------------------------------------------------
      # Allow access to script bucket to read glue job scripts
      # ------------------------------------------------------
      {
        #Sid    = "AllowGlueToReadScripts"
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:ListBucket"
        ]
        Resource = [
          var.scripts_bucket_arn,
          "${var.scripts_bucket_arn}/*"
        ]
      },

      {
        Sid    = "AllowGlueCatalogAccess"
        Effect = "Allow"
        Action = [
          "glue:GetDatabase",
          "glue:GetDatabases",
          "glue:GetTable",
          "glue:GetTables",
          "glue:GetPartition",
          "glue:GetPartitions"
        ]
        Resource = "*"
      }



    ]
  })
}

# ------------------------------------------------------------
# Attach policy to Glue Job role
# ------------------------------------------------------------
resource "aws_iam_role_policy_attachment" "glue_job_policy_attachment" {
  role       = aws_iam_role.glue_job_role.name
  policy_arn = aws_iam_policy.glue_job_policy.arn
}

###########################

# ------------------------------------------------------------
# IAM Role for Lambda
# ------------------------------------------------------------

resource "aws_iam_role" "lambda_role" {
  name = "${var.lambda_function_name}-role-${var.environment}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Environment = var.environment
    Project     = var.project_tag
  }
}

# ------------------------------------------------------------
# IAM Policy for Lambda
# ------------------------------------------------------------


resource "aws_iam_policy" "lambda_policy" {
  name = "${var.lambda_function_name}-policy-${var.environment}"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      # CloudWatch Logs
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "*"
      },

      # Glue read access
      {
        Effect = "Allow"
        Action = [
          "glue:GetJob",
          "glue:GetJobRun"
        ]
        Resource = "*"
      },

      # SNS publish
      {
        Effect   = "Allow"
        Action   = "sns:Publish"
        Resource = var.sns_topic_arn
      }
    ]
  })
}


# ------------------------------------------------------------
# Attach IAM Policy To Role for Lambda
# ------------------------------------------------------------


resource "aws_iam_role_policy_attachment" "lambda_attach" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_policy.arn
}




############################################
# IAM Role for Step Functions
############################################

resource "aws_iam_role" "stepfunction_role" {
  # A clear and unique role name helps operations & debugging
  name = "role-stepfunctions-${var.state_machine_name}-${var.environment}"

  # Step Functions service assumes this role at runtime
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "states.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })

  tags = {
    Project     = var.project_tag
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

############################################
# IAM Policy for Step Functions
# - Start Glue job
# - Invoke Lambda status checker
# - (Optional) Allow logging delivery permissions for Step Functions
############################################

resource "aws_iam_policy" "stepfunction_policy" {
  name        = "policy-stepfunctions-${var.state_machine_name}-${var.environment}"
  description = "Permissions for Step Functions to start Glue jobs and invoke Lambda"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = concat(
      [
        # Allow Step Functions to start only the specific Glue Job
        {
          Sid      = "StartSpecificGlueJob"
          Effect   = "Allow"
          Action   = ["glue:StartJobRun"]
          Resource = var.glue_job_arn
        },

        # Allow invoking only the status-checker Lambda
        {
          Sid      = "InvokeStatusCheckerLambda"
          Effect   = "Allow"
          Action   = ["lambda:InvokeFunction"]
          Resource = var.lambda_status_checker_arn
        }
      ],
      var.enable_stepfunction_logging ? [
        # Step Functions uses log delivery APIs to push execution logs to CloudWatch
        {
          Sid    = "AllowStepFunctionsLoggingDelivery"
          Effect = "Allow"
          Action = [
            "logs:CreateLogDelivery",
            "logs:GetLogDelivery",
            "logs:UpdateLogDelivery",
            "logs:DeleteLogDelivery",
            "logs:ListLogDeliveries",
            "logs:PutResourcePolicy",
            "logs:DescribeResourcePolicies",
            "logs:DescribeLogGroups"
          ]
          Resource = "*"
        }
      ] : []
    )
  })
}

resource "aws_iam_role_policy_attachment" "stepfunction_attach" {
  role       = aws_iam_role.stepfunction_role.name
  policy_arn = aws_iam_policy.stepfunction_policy.arn
}





