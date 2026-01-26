resource "aws_lambda_function" "glue_status_checker" {
  function_name = "glue-status-checker-${var.environment}"
  role = var.lambda_role_arn
  handler = "lambda_function.lambda_handler"
  runtime = "python3.9"

  filename = "${path.module}/code/glue_status_checker.zip"
  source_code_hash = filebase64sha256("${path.module}/code/glue_status_checker.zip")

  timeout = 30
  memory_size = 128

  environment {
  variables = {
    SNS_TOPIC_ARN = var.sns_topic_arn
    GLUE_JOB_NAME = var.glue_job_name
  }
}

tags = {
  Environment = var.environment
  Project = "AmazonReviewAnalytics"
  }
}

# Lambda permission to allow Step Function to invoke this Lambda
resource "aws_lambda_permission" "allow_stepfunction" {
  statement_id = "AllowExecutionFromStepFunction"
  action = "lambda:InvokeFunction"
  function_name = aws_lambda_function.glue_status_checker.function_name
  principal = "states.amazonaws.com"
}




