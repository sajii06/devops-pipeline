Write-Host "🔧 Emergency Deploy Fix - Starting..."

# Force update the ECS service to use latest image
Write-Host "🚀 Forcing ECS service update..."
aws ecs update-service --cluster devops-pipeline-cluster --service devops-pipeline-service --force-new-deployment --region eu-north-1

# Wait for deployment to start
Write-Host "⏳ Waiting for deployment..."
Start-Sleep 15

# Check service status
Write-Host "📊 Checking service status..."
aws ecs describe-services --cluster devops-pipeline-cluster --services devops-pipeline-service --region eu-north-1 --query 'services[0].{DesiredCount:desiredCount,RunningCount:runningCount,PendingCount:pendingCount}'

# Test the application
Write-Host "🧪 Testing application..."
Start-Sleep 30

try {
    $main = Invoke-RestMethod -Uri "http://devops-pipeline-alb-362222936.eu-north-1.elb.amazonaws.com/" -TimeoutSec 10
    Write-Host "✅ Main endpoint working: $($main | ConvertTo-Json -Compress)"
} catch {
    Write-Host "❌ Main endpoint failed: $($_.Exception.Message)"
}

try {
    $health = Invoke-RestMethod -Uri "http://devops-pipeline-alb-362222936.eu-north-1.elb.amazonaws.com/health" -TimeoutSec 10
    Write-Host "✅ Health endpoint working: $($health | ConvertTo-Json -Compress)"
} catch {
    Write-Host "❌ Health endpoint failed: $($_.Exception.Message)"
}

Write-Host "🎉 Deploy fix attempt complete!"
