# Manual Pipeline Trigger Script
Write-Host "🚀 Triggering CodePipeline manually..." -ForegroundColor Green

# Trigger the pipeline
aws codepipeline start-pipeline-execution --name devops-pipeline-pipeline --region eu-north-1

Write-Host "Pipeline triggered! Check status at:" -ForegroundColor Yellow
Write-Host "https://eu-north-1.console.aws.amazon.com/codesuite/codepipeline/pipelines/devops-pipeline-pipeline/view" -ForegroundColor Cyan

# Wait a bit and check status
Start-Sleep 10
Write-Host "`nPipeline Status:" -ForegroundColor Yellow
aws codepipeline get-pipeline-state --name devops-pipeline-pipeline --region eu-north-1 --query "stageStates[*].{Stage:stageName,Status:latestExecution.status}" --output table
