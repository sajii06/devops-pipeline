variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "service_role_arn" {
  description = "ARN of the CodePipeline service role"
  type        = string
}

variable "artifact_bucket" {
  description = "Name of the S3 artifact bucket"
  type        = string
}

variable "codebuild_project_name" {
  description = "Name of the CodeBuild project"
  type        = string
}

variable "github_repo" {
  description = "GitHub repository in format owner/repo"
  type        = string
}

variable "github_branch" {
  description = "GitHub branch to trigger pipeline"
  type        = string
}

variable "github_token" {
  description = "GitHub personal access token"
  type        = string
  sensitive   = true
}
