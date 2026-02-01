
############################################
# Step Functions Module (Infrastructure only)
# - Creates State Machine
# - (Optional) Creates CloudWatch Log Group
#
# NOTE:
# - IAM Role/Policy for Step Functions is created in IAM module.
# - This module receives stepfunction_role_arn as an input.
############################################

locals {
  # Environment-suffixed name for uniqueness across environments
  name_suffix = "${var.state_machine_name}-${var.environment}"

  # Step Functions log group convention (vended logs)
  log_group_name = "/aws/vendedlogs/states/${local.name_suffix}"

  # Only include Glue arguments if user provided overrides
  include_glue_args = length(var.glue_arguments_override) > 0
}

############################################
# Optional: CloudWatch Log Group for State Machine execution logs
############################################
resource "aws_cloudwatch_log_group" "sfn_logs" {
  count             = var.enable_logging ? 1 : 0
  name              = local.log_group_name
  retention_in_days = 14

  tags = {
    Project     = var.project_tag
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

############################################
# State Machine definition (ASL)
# Flow:
# 1) Start Glue Job
# 2) Wait
# 3) Invoke Lambda to check status (and notify)
# 4) Loop until SUCCEEDED or FAIL
############################################
locals {
  definition = jsonencode({
    Comment = "Run Glue ETL and poll job status via Lambda until completion"
    StartAt = "StartGlueJob"
    States = {
      StartGlueJob = merge(
        {
          Type     = "Task"
          Resource = "arn:aws:states:::glue:startJobRun"
          Parameters = merge(
            { JobName = var.glue_job_name },
            local.include_glue_args ? { Arguments = var.glue_arguments_override } : {}
          )
          ResultPath = "$.GlueStart"
          Next       = "WaitBeforeCheck"
        },
        {}
      )

      WaitBeforeCheck = {
        Type    = "Wait"
        Seconds = var.poll_interval_seconds
        Next    = "CheckGlueStatus"
      }

      CheckGlueStatus = {
        Type     = "Task"
        Resource = "arn:aws:states:::lambda:invoke"
        Parameters = {
          FunctionName = var.lambda_status_checker_arn
          Payload = {
            glue_job_name = var.glue_job_name
            job_run_id    = "$.GlueStart.JobRunId"
            environment   = var.environment
          }
        }
        ResultPath = "$.StatusCheck"
        Next       = "IsJobComplete"
      }

      IsJobComplete = {
        Type = "Choice"
        Choices = [
          {
            Variable     = "$.StatusCheck.Payload.status"
            StringEquals = "SUCCEEDED"
            Next         = "Success"
          },
          {
            Variable     = "$.StatusCheck.Payload.status"
            StringEquals = "FAILED"
            Next         = "Fail"
          },
          {
            Variable     = "$.StatusCheck.Payload.status"
            StringEquals = "STOPPED"
            Next         = "Fail"
          },
          {
            Variable     = "$.StatusCheck.Payload.status"
            StringEquals = "TIMEOUT"
            Next         = "Fail"
          },
          {
            Variable     = "$.StatusCheck.Payload.status"
            StringEquals = "RUNNING"
            Next         = "WaitBeforeCheck"
          }
        ]
        Default = "WaitBeforeCheck"
      }

      Success = { Type = "Succeed" }

      Fail = {
        Type  = "Fail"
        Error = "GlueJobFailed"
        Cause = "Glue job execution did not succeed"
      }
    }
  })
}

############################################
# Step Functions State Machine
############################################
resource "aws_sfn_state_machine" "this" {
  name     = local.name_suffix
  role_arn = var.stepfunction_role_arn

  definition = local.definition

  # Enable logging only if requested
  dynamic "logging_configuration" {
    for_each = var.enable_logging ? [1] : []
    content {
      level                  = "ALL"
      include_execution_data = true
      log_destination        = "${aws_cloudwatch_log_group.sfn_logs[0].arn}:*"
    }
  }

  tags = {
    Project     = var.project_tag
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}



