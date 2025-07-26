#!/bin/bash

echo "=== DevOps Pipeline Status Check ==="
echo ""

echo "1. Checking AWS CLI connection..."
aws sts get-caller-identity --region eu-north-1

echo ""
echo "2. Checking S3 bucket..."
aws s3 ls s3://devops-pipeline-artifacts-devops200406 --region eu-north-1

echo ""
echo "3. Checking CodePipeline..."
aws codepipeline get-pipeline --name devops-pipeline-pipeline --region eu-north-1

echo ""
echo "4. Checking CodeBuild project..."
aws codebuild batch-get-projects --names devops-pipeline-build --region eu-north-1

echo ""
echo "5. Checking ECR repository..."
aws ecr describe-repositories --repository-names devops-pipeline --region eu-north-1

echo ""
echo "6. Checking if pipeline has run..."
aws codepipeline get-pipeline-execution-summary --pipeline-name devops-pipeline-pipeline --region eu-north-1

echo ""
echo "=== Status Check Complete ==="
