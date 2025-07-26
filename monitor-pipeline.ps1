#!/usr/bin/env pwsh

Write-Host "Monitoring pipeline execution..." -ForegroundColor Green

do {
    $status = aws codepipeline get-pipeline-state --name devops-pipeline-pipeline --region eu-north-1 --query "stageStates[*].{Stage:stageName,Status:latestExecution.status}" --output table
    Clear-Host
    Write-Host "Pipeline Status - $(Get-Date)" -ForegroundColor Yellow
    Write-Host $status
    
    # Check if pipeline is still running
    $running = $status -match "InProgress"
    
    if (-not $running) {
        Write-Host "`nPipeline execution completed!" -ForegroundColor Green
        break
    }
    
    Start-Sleep -Seconds 15
} while ($true)

Write-Host "`nFinal Status:" -ForegroundColor Yellow
aws codepipeline get-pipeline-state --name devops-pipeline-pipeline --region eu-north-1 --query "stageStates[*].{Stage:stageName,Status:latestExecution.status}" --output table
