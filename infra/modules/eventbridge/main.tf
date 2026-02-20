# -----------------------------------------------------------
# IAM role assumed by EventBridge to start Step Functions
# -----------------------------------------------------------
resource "aws_iam_role" "eventbridge_invoke_sfn" {
  name = "${var.environment}-eventbridge-sfn-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "events.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  })
}

# Allow EventBridge to start execution of Step Function
resource "aws_iam_role_policy" "start_execution_policy" {
  name = "${var.environment}-start-sfn-policy"
  role = aws_iam_role.eventbridge_invoke_sfn.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect   = "Allow",
      Action   = "states:StartExecution",
      Resource = var.state_machine_arn
    }]
  })
}



# -----------------------------------------------------------
# EventBridge rule to detect S3 Object Created events
# -----------------------------------------------------------
resource "aws_cloudwatch_event_rule" "s3_object_created" {
  name        = "${var.environment}-s3-object-created"
  description = "Trigger Step Function when new object is created in ingestion bucket"

  event_pattern = jsonencode({
    source        = ["aws.s3"],
    "detail-type" = ["Object Created"],
    detail = {
      bucket = {
        name = [var.bucket_name]
      },
      object = {
        key = [{
          prefix = "test/"
        }]
      }
    }
  })
}






# -----------------------------------------------------------
# EventBridge target -> Step Function
# -----------------------------------------------------------
resource "aws_cloudwatch_event_target" "trigger_sfn" {
  rule      = aws_cloudwatch_event_rule.s3_object_created.name
  target_id = "StepFunctionTarget"
  arn       = var.state_machine_arn
  role_arn  = aws_iam_role.eventbridge_invoke_sfn.arn

  # Pass full S3 event to Step Function
  input_path = "$"
}




# kljihohoh


