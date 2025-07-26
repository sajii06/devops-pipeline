variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "service_role_arn" {
  description = "ARN of the CodeDeploy service role"
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

variable "target_group_name" {
  description = "Name of the target group"
  type        = string
}
