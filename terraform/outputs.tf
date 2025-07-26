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
