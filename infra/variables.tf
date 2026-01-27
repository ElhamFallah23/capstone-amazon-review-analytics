
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

#variable "environment" {
#description = "The environment to deploy to (e.g. dev, staging,prod)"
#type = string
#}
