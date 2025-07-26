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

variable "ecs_cluster_name" {
  description = "Name of the ECS cluster"
  type        = string
}

variable "ecs_service_name" {
  description = "Name of the ECS service"
  type        = string
}

variable "codedeploy_application_name" {
  description = "Name of the CodeDeploy application"
  type        = string
}

variable "codedeploy_deployment_group_name" {
  description = "Name of the CodeDeploy deployment group"
  type        = string
}
