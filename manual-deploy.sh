#!/bin/bash
# Deploy
aws ecs update-service --cluster devops-pipeline-cluster --service devops-pipeline-service --force-new-deployment --region eu-north-1
aws codepipeline start-pipeline-execution --name devops-pipeline --region eu-north-1
echo "✅ Done"
