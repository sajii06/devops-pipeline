variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "eu-north-1"
}

variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "devops-pipeline"
}

variable "artifact_bucket_name" {
  description = "S3 bucket name for storing artifacts"
  type        = string
  default     = "devops-pipeline-artifacts-12345"
}

variable "github_repo" {
  description = "GitHub repository in format owner/repo"
  type        = string
  default     = "sajii06/devops-pipeline"
}

variable "github_branch" {
  description = "GitHub branch to monitor"
  type        = string
  default     = "main"
}

variable "github_token" {
  description = "GitHub personal access token"
  type        = string
  sensitive   = true
  default     = ""
}
