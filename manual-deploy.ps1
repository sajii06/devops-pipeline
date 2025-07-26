# Manual Deploy Script (PowerShell)
# Run this to deploy your application directly from Windows

$AWS_REGION = "eu-north-1"
$CLUSTER_NAME = "devops-pipeline-cluster"
$SERVICE_NAME = "devops-pipeline-service"
$PIPELINE_NAME = "devops-pipeline"

Write-Host "🚀 Manual Deployment Script" -ForegroundColor Green
Write-Host "=========================="

# Check AWS CLI
if (!(Get-Command aws -ErrorAction SilentlyContinue)) {
    Write-Host "❌ AWS CLI not found. Please install AWS CLI first." -ForegroundColor Red
    exit 1
}

# Check credentials
try {
    aws sts get-caller-identity *>$null
    Write-Host "✅ AWS CLI configured" -ForegroundColor Green
} catch {
    Write-Host "❌ AWS credentials not configured. Please run 'aws configure' first." -ForegroundColor Red
    exit 1
}

# Deploy to ECS
Write-Host "🔄 Checking ECS service..." -ForegroundColor Yellow
$serviceStatus = aws ecs describe-services --cluster $CLUSTER_NAME --services $SERVICE_NAME --region $AWS_REGION --query 'services[0].status' --output text 2>$null

if ($serviceStatus -eq "ACTIVE") {
    Write-Host "✅ ECS service found - updating deployment..." -ForegroundColor Green
    aws ecs update-service --cluster $CLUSTER_NAME --service $SERVICE_NAME --force-new-deployment --region $AWS_REGION
    Write-Host "✅ ECS deployment triggered" -ForegroundColor Green
} else {
    Write-Host "⚠️ ECS service not found or not active" -ForegroundColor Yellow
    Write-Host "Checking if cluster exists..."
    
    $clusterExists = aws ecs describe-clusters --clusters $CLUSTER_NAME --region $AWS_REGION 2>$null
    if ($clusterExists) {
        Write-Host "✅ Cluster exists but service is missing" -ForegroundColor Yellow
        Write-Host "❌ Please run Terraform to create the service first" -ForegroundColor Red
    } else {
        Write-Host "❌ Cluster doesn't exist. Please run Terraform first." -ForegroundColor Red
        exit 1
    }
}

# Trigger CodePipeline
Write-Host "🔄 Checking CodePipeline..." -ForegroundColor Yellow
$pipelineExists = aws codepipeline get-pipeline --name $PIPELINE_NAME --region $AWS_REGION 2>$null

if ($pipelineExists) {
    Write-Host "✅ CodePipeline found - starting execution..." -ForegroundColor Green
    $executionId = aws codepipeline start-pipeline-execution --name $PIPELINE_NAME --region $AWS_REGION --query 'pipelineExecutionId' --output text
    Write-Host "✅ CodePipeline execution started: $executionId" -ForegroundColor Green
} else {
    Write-Host "⚠️ CodePipeline not found" -ForegroundColor Yellow
    Write-Host "Available pipelines:"
    aws codepipeline list-pipelines --region $AWS_REGION --query 'pipelines[].name' --output table
}

# Get application URL
Write-Host "🌐 Getting application URL..." -ForegroundColor Yellow
$lbDns = aws elbv2 describe-load-balancers --query 'LoadBalancers[?contains(LoadBalancerName, `devops-pipeline`)].DNSName' --output text --region $AWS_REGION 2>$null

if ($lbDns -and $lbDns -ne "None") {
    Write-Host "✅ Application URL: http://$lbDns" -ForegroundColor Green
    Write-Host "🔗 You can access your application at: http://$lbDns" -ForegroundColor Cyan
} else {
    Write-Host "⚠️ Load balancer not found" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "🎯 DEPLOYMENT COMPLETED!" -ForegroundColor Green
Write-Host "======================"
Write-Host "✅ ECS deployment triggered" -ForegroundColor Green
Write-Host "✅ CodePipeline execution started" -ForegroundColor Green
Write-Host "✅ Application URL retrieved" -ForegroundColor Green
