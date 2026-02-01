resource "aws_lambda_function" "glue_status_checker" {
  function_name = "${var.lambda_function_name}-${var.environment}" # Name of Lambda in AWS
  role          = var.lambda_role_arn                              # The IAM Role that Lambda assume it. This Role should have this permissions: logs (CloudWatch), glue:GetJob, sns:Publish
  handler       = "lambda_function.lambda_handler"                 # "lambda_handler" is the name of function in the "lambda_function.py"
  runtime       = "python3.9"

  # AWS Lambda doesn't read .py directly. It only take zip file or container image. So here we take the Pythone file in a zip file. 

  filename         = "${path.module}/lambda_function/lambda_function.zip"
  source_code_hash = filebase64sha256("${path.module}/lambda_function/lambda_function.zip")

  timeout     = 30
  memory_size = 128

  environment {
    variables = { # variables that use in Lambda_function.py
      SNS_TOPIC_ARN = var.sns_topic_arn
      GLUE_JOB_NAME = var.glue_job_name # 
    }
  }

  tags = {
    Environment = var.environment
    Project     = var.project_tag #    "AmazonReviewAnalytics"
  }
}

# Grant Lambda permission to be invoked by Step Function
resource "aws_lambda_permission" "allow_stepfunction" {
  count = var.stepfunction == null ? 0 : 1

  statement_id  = "AllowExecutionFromStepFunction"                      # Name of policy statement
  action        = "lambda:InvokeFunction"                               # Let Lambda to be invoked
  function_name = aws_lambda_function.glue_status_checker.function_name # Which Lambda
  principal     = "states.amazonaws.com"                                # Only AWS step function
  #source_arn    = var.stepfunction_arn                                  # Wihtout this line, every step function can run the Lambda
}







