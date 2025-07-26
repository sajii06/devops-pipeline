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

# ECS Deployment
module "ecs" {
  source = "./modules/ecs"

  project_name = var.project_name
  aws_region   = var.aws_region
  account_id   = data.aws_caller_identity.current.account_id
}

# CodeDeploy
module "codedeploy" {
  source = "./modules/codedeploy"
  
  project_name = var.project_name
  service_role_arn = module.iam.codedeploy_role_arn
  ecs_cluster_name = module.ecs.cluster_name
  ecs_service_name = module.ecs.service_name
  target_group_name = module.ecs.target_group_name
}

# CodePipeline
module "codepipeline" {
  source = "./modules/codepipeline"
  
  project_name = var.project_name
  service_role_arn = module.iam.codepipeline_role_arn
  artifact_bucket = module.s3.bucket_name
  codebuild_project_name = module.codebuild.project_name
  ecs_cluster_name = module.ecs.cluster_name
  ecs_service_name = module.ecs.service_name
  codedeploy_application_name = module.codedeploy.application_name
  codedeploy_deployment_group_name = module.codedeploy.deployment_group_name
}

data "aws_caller_identity" "current" {}
