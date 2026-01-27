
variable "notification_email" {
 description = "Email to receive Glue job notifications"
 type = string
}

variable "github_repo" {
description = "GitHub repo in the format 'username/repo'"
type = string
}

variable "github_branch" {
description = "Branch name used for deployment"
type = string
}

variable "environ" {
description = "Environment"
type = string
}
