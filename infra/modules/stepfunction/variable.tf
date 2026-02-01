variable "environment" {
description = "Deployment environment (e.g. dev, staging, prod)"
type = string
}

variable "project_tag" {
description = "Project tag used for cost allocation"
type = string
}

variable "state_machine_name" {
description = "Base name of the Step Functions state machine (environment suffix will be appended)"
type = string
}

variable "stepfunction_role_arn" {
description = "IAM Role ARN assumed by Step Functions (created in IAM module)"
type = string
}

variable "glue_job_name" {
description = "Glue job name that Step Functions should run"
type = string
}

variable "lambda_status_checker_arn" {
description = "ARN of Lambda that checks Glue job status"
type = string
}

variable "poll_interval_seconds" {
description = "Seconds to wait between status checks"
type = number
default = 60
}

variable "glue_arguments_override" {
description = "Optional Glue Job arguments passed to StartJobRun"
type = map(string)
default = {}
}

variable "enable_logging" {
description = "Enable Step Functions execution logging"
type = bool
default = true
}

