Write-Host "🔧 Complete DevOps Pipeline Configuration Fix" -ForegroundColor Green

# Step 1: Check current app status
Write-Host "📊 Current status check..." -ForegroundColor Yellow
try {
    $currentMain = Invoke-RestMethod "http://devops-pipeline-alb-362222936.eu-north-1.elb.amazonaws.com/" -TimeoutSec 5
    Write-Host "✅ Main endpoint working: $($currentMain | ConvertTo-Json -Compress)" -ForegroundColor Green
} catch {
    Write-Host "❌ Main endpoint failed: $($_.Exception.Message)" -ForegroundColor Red
}

try {
    $currentHealth = Invoke-RestMethod "http://devops-pipeline-alb-362222936.eu-north-1.elb.amazonaws.com/health" -TimeoutSec 5
    Write-Host "✅ Health endpoint working: $($currentHealth | ConvertTo-Json -Compress)" -ForegroundColor Green
} catch {
    Write-Host "❌ Health endpoint failed: $($_.Exception.Message)" -ForegroundColor Red
}

# Step 2: Force ECS service update with latest task definition
Write-Host "🚀 Forcing ECS service update..." -ForegroundColor Yellow
aws ecs update-service --cluster devops-pipeline-cluster --service devops-pipeline-service --task-definition devops-pipeline-task --force-new-deployment --region eu-north-1

# Step 3: Monitor deployment progress
Write-Host "⏳ Monitoring deployment progress..." -ForegroundColor Yellow
for ($i = 1; $i -le 6; $i++) {
    Start-Sleep 15
    Write-Host "Check $i/6..." -ForegroundColor Cyan
    
    $serviceStatus = aws ecs describe-services --cluster devops-pipeline-cluster --services devops-pipeline-service --region eu-north-1 --query 'services[0].{RunningCount:runningCount,DesiredCount:desiredCount}' | ConvertFrom-Json
    Write-Host "Service: Running=$($serviceStatus.RunningCount), Desired=$($serviceStatus.DesiredCount)" -ForegroundColor Cyan
    
    if ($serviceStatus.RunningCount -eq $serviceStatus.DesiredCount -and $serviceStatus.RunningCount -gt 0) {
        Write-Host "✅ Service is stable, testing endpoints..." -ForegroundColor Green
        break
    }
}

# Step 4: Final endpoint tests
Write-Host "🧪 Final endpoint tests..." -ForegroundColor Yellow
Start-Sleep 10

try {
    $finalMain = Invoke-RestMethod "http://devops-pipeline-alb-362222936.eu-north-1.elb.amazonaws.com/" -TimeoutSec 10
    Write-Host "✅ Main endpoint: $($finalMain | ConvertTo-Json)" -ForegroundColor Green
} catch {
    Write-Host "❌ Main endpoint still failed: $($_.Exception.Message)" -ForegroundColor Red
}

try {
    $finalHealth = Invoke-RestMethod "http://devops-pipeline-alb-362222936.eu-north-1.elb.amazonaws.com/health" -TimeoutSec 10
    Write-Host "✅ Health endpoint: $($finalHealth | ConvertTo-Json)" -ForegroundColor Green
} catch {
    Write-Host "❌ Health endpoint still failed: $($_.Exception.Message)" -ForegroundColor Red
}

# Step 5: Check target group health
Write-Host "🎯 Checking target group health..." -ForegroundColor Yellow
aws elbv2 describe-target-health --target-group-arn arn:aws:elasticloadbalancing:eu-north-1:070593201734:targetgroup/devops-pipeline-tg/eac459985baafc31 --region eu-north-1 --query 'TargetHealthDescriptions[0].TargetHealth.State'

Write-Host "🎉 Configuration fix complete!" -ForegroundColor Green
Write-Host "📱 Application URL: http://devops-pipeline-alb-362222936.eu-north-1.elb.amazonaws.com" -ForegroundColor Magenta
Write-Host "🩺 Health URL: http://devops-pipeline-alb-362222936.eu-north-1.elb.amazonaws.com/health" -ForegroundColor Magenta
