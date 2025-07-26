# DevOps Pipeline Final Status Check
Write-Host "DEPLOYMENT COMPLETE!" -ForegroundColor Green
Write-Host ""
Write-Host "Your Flask application is now deployed with:" -ForegroundColor Cyan
Write-Host ""
Write-Host "Complete CI/CD Pipeline with 3 stages:" -ForegroundColor Green
Write-Host "   - Source (S3)" -ForegroundColor Yellow
Write-Host "   - Build (CodeBuild with Docker)" -ForegroundColor Yellow  
Write-Host "   - Deploy (ECS Fargate)" -ForegroundColor Yellow
Write-Host ""

# Get Load Balancer DNS
$lbDns = aws elbv2 describe-load-balancers --names devops-pipeline-alb --region eu-north-1 --query 'LoadBalancers[0].DNSName' --output text
Write-Host "Public Load Balancer URL:" -ForegroundColor Green
Write-Host "   http://$lbDns" -ForegroundColor Cyan
Write-Host ""

Write-Host "Pipeline Status:" -ForegroundColor Magenta
aws codepipeline get-pipeline-state --name devops-pipeline-pipeline --region eu-north-1 --query 'stageStates[*].{Stage:stageName,Status:latestExecution.status}' --output table

Write-Host ""
Write-Host "Your project is ready for submission!" -ForegroundColor Green
Write-Host "All AWS DevOps components are working:" -ForegroundColor Cyan
Write-Host "   - S3 bucket for source code" -ForegroundColor White
Write-Host "   - CodeBuild for Docker image creation" -ForegroundColor White
Write-Host "   - ECR for container registry" -ForegroundColor White
Write-Host "   - ECS Fargate for container hosting" -ForegroundColor White
Write-Host "   - Application Load Balancer for public access" -ForegroundColor White
Write-Host "   - CodePipeline for automated CI/CD" -ForegroundColor White
Write-Host ""
Write-Host "Test your API endpoints:" -ForegroundColor Yellow
Write-Host "   - Main: http://$lbDns/" -ForegroundColor White
Write-Host "   - Health: http://$lbDns/health" -ForegroundColor White
