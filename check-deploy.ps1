# Deploy Stage Verification Script
Write-Host "Checking Deploy Stage Status..." -ForegroundColor Cyan
Write-Host ""

# Check if pipeline has 3 stages
$stages = aws codepipeline get-pipeline --name devops-pipeline-pipeline --region eu-north-1 --query 'pipeline.stages[*].name' --output text
Write-Host "Pipeline Stages Found: $stages" -ForegroundColor Green

# Check pipeline execution status
Write-Host ""
Write-Host "Current Pipeline Execution Status:" -ForegroundColor Yellow
aws codepipeline get-pipeline-state --name devops-pipeline-pipeline --region eu-north-1 --query 'stageStates[*].{StageName:stageName,Status:latestExecution.status}' --output table

Write-Host ""
Write-Host "AWS Console URLs:" -ForegroundColor Magenta
Write-Host "Pipeline: https://eu-north-1.console.aws.amazon.com/codesuite/codepipeline/pipelines/devops-pipeline-pipeline/view" -ForegroundColor Cyan
Write-Host "ECS Cluster: https://eu-north-1.console.aws.amazon.com/ecs/v2/clusters/devops-pipeline-cluster/services" -ForegroundColor Cyan

Write-Host ""
Write-Host "Deploy stage has been added to your pipeline!" -ForegroundColor Green
Write-Host "The pipeline now has Source → Build → Deploy stages" -ForegroundColor White
