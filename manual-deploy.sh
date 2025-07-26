#!/bin/bash
# Quick Deploy Script
echo "🚀 Deploying..."

# Deploy ECS
aws ecs update-service --cluster devops-pipeline-cluster --service devops-pipeline-service --force-new-deployment --region eu-north-1

# Trigger Pipeline  
aws codepipeline start-pipeline-execution --name devops-pipeline --region eu-north-1

# Get URL
URL=$(aws elbv2 describe-load-balancers --query 'LoadBalancers[?contains(LoadBalancerName, `devops-pipeline`)].DNSName' --output text --region eu-north-1)
echo "✅ App URL: http://$URL"
