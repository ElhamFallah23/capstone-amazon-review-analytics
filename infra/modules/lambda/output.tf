
# Output the Lambda function name
output "lambda_function_name" {
  description = "Name of the Lambda function"
  value       = aws_lambda_function.glue_status_checker.function_name
}

# Output the Lambda function ARN
output "lambda_function_arn" {
  description = "ARN of the Lambda function that monitors Glue job status and sendsnotifications"
  value       = aws_lambda_function.glue_status_checker.arn
}




