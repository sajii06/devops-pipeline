output "codepipeline_name" {
  description = "Name of the CodePipeline"
  value       = module.codepipeline.pipeline_name
}

output "codebuild_project_name" {
  description = "Name of the CodeBuild project"
  value       = module.codebuild.project_name
}

output "artifact_bucket_name" {
  description = "Name of the S3 artifact bucket"
  value       = module.s3.bucket_name
}

output "ecs_cluster_name" {
  description = "Name of the ECS cluster"
  value       = module.ecs.cluster_name
}

output "load_balancer_url" {
  description = "URL of the load balancer"
  value       = "http://${module.ecs.load_balancer_dns}"
}

output "ecr_repository_url" {
  description = "URL of the ECR repository"
  value       = "${data.aws_caller_identity.current.account_id}.dkr.ecr.${var.aws_region}.amazonaws.com/${var.project_name}"
}
