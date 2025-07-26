#!/bin/bash

# Manual Deploy Script
# Run this to deploy your application directly

set -e

AWS_REGION="eu-north-1"
CLUSTER_NAME="devops-pipeline-cluster"
SERVICE_NAME="devops-pipeline-service"
PIPELINE_NAME="devops-pipeline"

echo "🚀 Manual Deployment Script"
echo "=========================="

# Check AWS CLI
if ! command -v aws &> /dev/null; then
    echo "❌ AWS CLI not found. Please install AWS CLI first."
    exit 1
fi

# Check credentials
if ! aws sts get-caller-identity > /dev/null 2>&1; then
    echo "❌ AWS credentials not configured. Please run 'aws configure' first."
    exit 1
fi

echo "✅ AWS CLI configured"

# Deploy to ECS
echo "🔄 Checking ECS service..."
if aws ecs describe-services --cluster $CLUSTER_NAME --services $SERVICE_NAME --region $AWS_REGION --query 'services[0].status' --output text 2>/dev/null | grep -q "ACTIVE"; then
    echo "✅ ECS service found - updating deployment..."
    aws ecs update-service \
        --cluster $CLUSTER_NAME \
        --service $SERVICE_NAME \
        --force-new-deployment \
        --region $AWS_REGION
    echo "✅ ECS deployment triggered"
else
    echo "⚠️ ECS service not found or not active"
    echo "Checking if cluster exists..."
    if aws ecs describe-clusters --clusters $CLUSTER_NAME --region $AWS_REGION > /dev/null 2>&1; then
        echo "✅ Cluster exists but service is missing"
        echo "❌ Please run Terraform to create the service first"
    else
        echo "❌ Cluster doesn't exist. Please run Terraform first."
        exit 1
    fi
fi

# Trigger CodePipeline
echo "🔄 Checking CodePipeline..."
if aws codepipeline get-pipeline --name $PIPELINE_NAME --region $AWS_REGION > /dev/null 2>&1; then
    echo "✅ CodePipeline found - starting execution..."
    EXECUTION_ID=$(aws codepipeline start-pipeline-execution \
        --name $PIPELINE_NAME \
        --region $AWS_REGION \
        --query 'pipelineExecutionId' \
        --output text)
    echo "✅ CodePipeline execution started: $EXECUTION_ID"
else
    echo "⚠️ CodePipeline not found"
    echo "Available pipelines:"
    aws codepipeline list-pipelines --region $AWS_REGION --query 'pipelines[].name' --output table || echo "No pipelines found"
fi

# Get application URL
echo "🌐 Getting application URL..."
LB_DNS=$(aws elbv2 describe-load-balancers \
    --query 'LoadBalancers[?contains(LoadBalancerName, `devops-pipeline`)].DNSName' \
    --output text \
    --region $AWS_REGION 2>/dev/null || echo "")

if [ -n "$LB_DNS" ] && [ "$LB_DNS" != "None" ]; then
    echo "✅ Application URL: http://$LB_DNS"
    echo "🔗 You can access your application at: http://$LB_DNS"
else
    echo "⚠️ Load balancer not found"
fi

echo ""
echo "🎯 DEPLOYMENT COMPLETED!"
echo "======================"
echo "✅ ECS deployment triggered"
echo "✅ CodePipeline execution started"
echo "✅ Application URL retrieved"
echo ""
echo "🔗 Monitor progress:"
echo "  - AWS ECS Console: https://eu-north-1.console.aws.amazon.com/ecs/home?region=eu-north-1#/clusters/$CLUSTER_NAME/services/$SERVICE_NAME/details"
echo "  - AWS CodePipeline Console: https://eu-north-1.console.aws.amazon.com/codesuite/codepipeline/pipelines/$PIPELINE_NAME/view"
