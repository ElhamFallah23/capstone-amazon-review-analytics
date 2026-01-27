
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
resource "aws_iam_role_policy_attachment" "glue_sservice" {
  role       = aws_iam_role.glue_crawler_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSGlueServiceRole"
}
resource "aws_iam_role_policy_attachment" "glue_s3_access" {
  role       = aws_iam_role.glue_crawler_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
}

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
        Condition = {
          StringEquals = {
            "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
            "token.actions.githubusercontent.com:sub" = "repo:${var.github_repo}:ref:refs/heads/${var.github_branch}"
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






