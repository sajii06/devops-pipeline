variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "service_role_arn" {
  description = "ARN of the CodeBuild service role"
  type        = string
}

variable "artifact_bucket" {
  description = "Name of the S3 artifact bucket"
  type        = string
}

variable "github_repo" {
  description = "GitHub repository (unused but required for compatibility)"
  type        = string
  default     = "placeholder"
}
