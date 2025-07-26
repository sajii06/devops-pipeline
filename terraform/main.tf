terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# S3 bucket for artifacts
module "s3" {
  source = "./modules/s3"
  
  bucket_name = var.artifact_bucket_name
  project_name = var.project_name
}

# IAM roles and policies
module "iam" {
  source = "./modules/iam"
  
  project_name = var.project_name
  artifact_bucket_arn = module.s3.bucket_arn
}

# CodeBuild project
module "codebuild" {
  source = "./modules/codebuild"
  
  project_name = var.project_name
  service_role_arn = module.iam.codebuild_role_arn
  artifact_bucket = module.s3.bucket_name
  github_repo = var.github_repo
}

# CodePipeline
module "codepipeline" {
  source = "./modules/codepipeline"
  
  project_name = var.project_name
  service_role_arn = module.iam.codepipeline_role_arn
  artifact_bucket = module.s3.bucket_name
  codebuild_project_name = module.codebuild.project_name
  github_repo = var.github_repo
  github_branch = var.github_branch
  github_token = var.github_token
}
