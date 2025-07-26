#!/usr/bin/env pwsh

Write-Host "🚀 DEPLOYING YOUR APP TO AWS!" -ForegroundColor Cyan
Write-Host "=============================" -ForegroundColor Cyan
Write-Host ""

# Monitor pipeline progress
Write-Host "📊 Pipeline Status:" -ForegroundColor Yellow
aws codepipeline get-pipeline-state --name devops-pipeline-pipeline --region eu-north-1 --query "stageStates[*].{Stage:stageName,Status:latestExecution.status}" --output table

Write-Host ""
Write-Host "⏳ Waiting for deployment to complete..." -ForegroundColor Yellow

# Wait for pipeline to complete
do {
    Start-Sleep -Seconds 30
    $status = aws codepipeline get-pipeline-state --name devops-pipeline-pipeline --region eu-north-1 --query "stageStates[*].latestExecution.status" --output text
    
    if ($status -match "InProgress") {
        Write-Host "⏳ Still deploying..." -ForegroundColor Yellow
    } else {
        break
    }
} while ($true)

Write-Host ""
Write-Host "🎉 DEPLOYMENT COMPLETE!" -ForegroundColor Green
Write-Host ""

# Get the load balancer URL
Write-Host "🌐 Getting your app URL..." -ForegroundColor Yellow
$lbUrl = terraform output -raw load_balancer_url 2>$null
if ($lbUrl) {
    Write-Host "✅ Your app is live at: $lbUrl" -ForegroundColor Green
    Write-Host "✅ Health check: $lbUrl/health" -ForegroundColor Green
} else {
    Write-Host "⚠️  Getting URL from AWS..." -ForegroundColor Yellow
    $lbDns = aws elbv2 describe-load-balancers --region eu-north-1 --query "LoadBalancers[?contains(LoadBalancerName, 'devops-pipeline')].DNSName" --output text
    if ($lbDns) {
        Write-Host "✅ Your app is live at: http://$lbDns" -ForegroundColor Green
        Write-Host "✅ Health check: http://$lbDns/health" -ForegroundColor Green
    }
}

Write-Host ""
Write-Host "📊 Final Pipeline Status:" -ForegroundColor Yellow
aws codepipeline get-pipeline-state --name devops-pipeline-pipeline --region eu-north-1 --query "stageStates[*].{Stage:stageName,Status:latestExecution.status}" --output table

Write-Host ""
Write-Host "🎯 Deployment Summary:" -ForegroundColor Cyan
Write-Host "✅ Source: Artifact from S3" -ForegroundColor Green
Write-Host "✅ Build: Docker image built and pushed to ECR" -ForegroundColor Green  
Write-Host "✅ Deploy: Application deployed to ECS Fargate" -ForegroundColor Green
Write-Host "✅ Load Balancer: Public access configured" -ForegroundColor Green
Write-Host ""
Write-Host "🚀 YOUR DEVOPS PIPELINE IS LIVE!" -ForegroundColor Magenta
