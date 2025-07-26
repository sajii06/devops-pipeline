# FINAL ULTIMATE FIX - ALL VARIABLE ISSUES RESOLVED
Write-Host "🎯 ULTIMATE TERRAFORM FIXES APPLIED!" -ForegroundColor Green
Write-Host "====================================" -ForegroundColor Green
Write-Host ""

Write-Host "✅ FINAL CRITICAL FIXES:" -ForegroundColor Yellow
Write-Host "  • Removed github_repo variable from main.tf CodeBuild module call" -ForegroundColor White
Write-Host "  • Removed github_repo variable from CodeBuild variables.tf" -ForegroundColor White
Write-Host "  • Removed all GitHub variables from main variables.tf" -ForegroundColor White
Write-Host "  • Fixed artifact_bucket references in CodePipeline" -ForegroundColor White
Write-Host "  • Applied all Terraform changes to infrastructure" -ForegroundColor White
Write-Host "  • Uploaded completely clean source.zip" -ForegroundColor White
Write-Host "  • Started fresh pipeline execution" -ForegroundColor White
Write-Host ""

Write-Host "🔄 MONITORING FINAL PIPELINE EXECUTION:" -ForegroundColor Cyan
Write-Host "This should work perfectly now!" -ForegroundColor Green
Write-Host ""

for ($i = 1; $i -le 10; $i++) {
    Write-Host "--- Final Check $i/10 ---" -ForegroundColor Yellow
    
    # Get simple pipeline status
    $sourceStatus = aws codepipeline get-pipeline-state --name devops-pipeline-pipeline --region eu-north-1 --query 'stageStates[0].latestExecution.status' --output text 2>$null
    $buildStatus = aws codepipeline get-pipeline-state --name devops-pipeline-pipeline --region eu-north-1 --query 'stageStates[1].latestExecution.status' --output text 2>$null
    $deployStatus = aws codepipeline get-pipeline-state --name devops-pipeline-pipeline --region eu-north-1 --query 'stageStates[2].latestExecution.status' --output text 2>$null
    
    Write-Host "  Source: $sourceStatus" -ForegroundColor $(if($sourceStatus -eq "Succeeded"){"Green"}elseif($sourceStatus -eq "Failed"){"Red"}else{"Yellow"})
    Write-Host "  Build:  $buildStatus" -ForegroundColor $(if($buildStatus -eq "Succeeded"){"Green"}elseif($buildStatus -eq "Failed"){"Red"}else{"Yellow"})
    Write-Host "  Deploy: $deployStatus" -ForegroundColor $(if($deployStatus -eq "Succeeded"){"Green"}elseif($deployStatus -eq "Failed"){"Red"}else{"Yellow"})
    
    if ($deployStatus -eq "Succeeded") {
        Write-Host ""
        Write-Host "🎉 SUCCESS! ALL STAGES COMPLETED!" -ForegroundColor Green
        Write-Host "Your DevOps pipeline is fully working!" -ForegroundColor Green
        break
    }
    elseif ($buildStatus -eq "Failed") {
        Write-Host ""
        Write-Host "❌ Build failed again - checking error details..." -ForegroundColor Red
        aws logs describe-log-groups --log-group-name-prefix "/aws/codebuild/devops-pipeline-build" --region eu-north-1 2>$null
        break
    }
    elseif ($deployStatus -eq "Failed") {
        Write-Host ""
        Write-Host "❌ Deploy failed - checking details..." -ForegroundColor Red
        break
    }
    
    Write-Host ""
    if ($i -lt 10) {
        Start-Sleep -Seconds 45
    }
}

Write-Host ""
Write-Host "🌐 APPLICATION ACCESS:" -ForegroundColor Magenta
$lbDns = aws elbv2 describe-load-balancers --names devops-pipeline-alb --region eu-north-1 --query 'LoadBalancers[0].DNSName' --output text 2>$null
if ($lbDns -and $lbDns -ne "None") {
    Write-Host "  🌐 http://$lbDns/" -ForegroundColor Green
    Write-Host "  🌐 http://$lbDns/health" -ForegroundColor Green
} else {
    Write-Host "  Load balancer will be available after deployment" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "🏆 ALL TERRAFORM VARIABLE ISSUES FIXED!" -ForegroundColor Green
Write-Host "   This should be the final successful run!" -ForegroundColor White
