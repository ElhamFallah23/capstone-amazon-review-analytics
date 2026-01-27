
variable "environment" {
  description = "Deployment environment (e.g., dev, staging, prod)"
  type        = string
}

variable "github_repo" {
  description = "GitHub repo in the format 'username/repo'"
  type        = string
}

variable "github_branch" {
  description = "Branch name used for deployment"
  type        = string
}