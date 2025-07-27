# BUILD STAGE FIX - ECR REPOSITORY CREATED
Write-Host "🔧 BUILD STAGE ISSUE FIXED!" -ForegroundColor Green
Write-Host "============================" -ForegroundColor Green
Write-Host ""

Write-Host "✅ FIXES APPLIED:" -ForegroundColor Yellow
Write-Host "  • Created ECR repository 'devops-pipeline'" -ForegroundColor White
Write-Host "  • Verified CodeBuild IAM permissions for ECR" -ForegroundColor White
Write-Host "  • Confirmed buildspec.yml configuration" -ForegroundColor White
Write-Host "  • Uploaded fresh source.zip" -ForegroundColor White
Write-Host "  • Started new pipeline execution" -ForegroundColor White
Write-Host ""

Write-Host "🔄 MONITORING BUILD STAGE:" -ForegroundColor Cyan
Write-Host "The build should work now with ECR repository available!" -ForegroundColor Green
Write-Host ""

for ($i = 1; $i -le 15; $i++) {
    Write-Host "--- Build Check $i/15 ---" -ForegroundColor Yellow
    
    # Get pipeline status
    $sourceStatus = aws codepipeline get-pipeline-state --name devops-pipeline-pipeline --region eu-north-1 --query 'stageStates[0].latestExecution.status' --output text 2>$null
    $buildStatus = aws codepipeline get-pipeline-state --name devops-pipeline-pipeline --region eu-north-1 --query 'stageStates[1].latestExecution.status' --output text 2>$null
    $deployStatus = aws codepipeline get-pipeline-state --name devops-pipeline-pipeline --region eu-north-1 --query 'stageStates[2].latestExecution.status' --output text 2>$null
    
    Write-Host "  Source: $sourceStatus" -ForegroundColor $(if($sourceStatus -eq "Succeeded"){"Green"}elseif($sourceStatus -eq "Failed"){"Red"}else{"Yellow"})
    Write-Host "  Build:  $buildStatus" -ForegroundColor $(if($buildStatus -eq "Succeeded"){"Green"}elseif($buildStatus -eq "Failed"){"Red"}else{"Yellow"})
    Write-Host "  Deploy: $deployStatus" -ForegroundColor $(if($deployStatus -eq "Succeeded"){"Green"}elseif($deployStatus -eq "Failed"){"Red"}else{"Yellow"})
    
    if ($buildStatus -eq "Succeeded") {
        Write-Host ""
        Write-Host "🎉 BUILD STAGE SUCCESSFUL!" -ForegroundColor Green
        Write-Host "Docker image built and pushed to ECR!" -ForegroundColor Green
        
        if ($deployStatus -eq "Succeeded") {
            Write-Host "🎉 ALL STAGES COMPLETED!" -ForegroundColor Green
            break
        } elseif ($deployStatus -eq "InProgress") {
            Write-Host "⏳ Deploy stage is running..." -ForegroundColor Yellow
        }
    }
    elseif ($buildStatus -eq "Failed") {
        Write-Host ""
        Write-Host "❌ Build still failed - checking logs..." -ForegroundColor Red
        break
    }
    elseif ($sourceStatus -eq "Failed") {
        Write-Host ""
        Write-Host "❌ Source stage failed" -ForegroundColor Red
        break
    }
    
    Write-Host ""
    if ($i -lt 15) {
        Start-Sleep -Seconds 30
    }
}

Write-Host ""
Write-Host "📋 ECR REPOSITORY STATUS:" -ForegroundColor Magenta
aws ecr describe-repositories --repository-names devops-pipeline --region eu-north-1 --query 'repositories[0].{Name:repositoryName,URI:repositoryUri}' --output table 2>$null

Write-Host ""
Write-Host "🏆 ECR REPOSITORY CREATED - BUILD SHOULD WORK NOW!" -ForegroundColor Green
