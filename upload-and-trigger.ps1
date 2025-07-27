# Fix Deploy Stage Issues
Write-Host "🔧 Fixing CodePipeline Deploy Stage Issues..."

# Step 1: Check current pipeline status
Write-Host "📊 Checking pipeline status..."
aws codepipeline list-pipelines --region eu-north-1 --query 'pipelines[*].name'

# Step 2: Update task definition with correct container name
Write-Host "📝 Fixing task definition..."
$taskDefJson = @{
    family = "devops-pipeline-task"
    networkMode = "awsvpc"
    requiresCompatibilities = @("FARGATE")
    cpu = "256"
    memory = "512"
    executionRoleArn = "arn:aws:iam::070593201734:role/ecsTaskExecutionRole"
    containerDefinitions = @(
        @{
            name = "devops-pipeline-app"
            image = "070593201734.dkr.ecr.eu-north-1.amazonaws.com/devops-pipeline:latest"
            portMappings = @(
                @{
                    containerPort = 5000
                    protocol = "tcp"
                }
            )
            environment = @(
                @{
                    name = "ENVIRONMENT"
                    value = "production"
                }
            )
            logConfiguration = @{
                logDriver = "awslogs"
                options = @{
                    "awslogs-group" = "/ecs/devops-pipeline"
                    "awslogs-region" = "eu-north-1"
                    "awslogs-stream-prefix" = "ecs"
                }
            }
            essential = $true
        }
    )
} | ConvertTo-Json -Depth 10

$taskDefJson | Out-File -FilePath "task-definition-fixed.json" -Encoding UTF8

# Step 3: Register new task definition
Write-Host "🚀 Registering fixed task definition..."
aws ecs register-task-definition --cli-input-json file://task-definition-fixed.json --region eu-north-1

# Step 4: Update ECS service with new task definition
Write-Host "🔄 Updating ECS service..."
aws ecs update-service --cluster devops-pipeline-cluster --service devops-pipeline-service --task-definition devops-pipeline-task --force-new-deployment --region eu-north-1

# Step 5: Monitor deployment
Write-Host "📈 Monitoring deployment..."
Start-Sleep 10
aws ecs describe-services --cluster devops-pipeline-cluster --services devops-pipeline-service --region eu-north-1 --query 'services[0].deployments[0].{Status:status,RunningCount:runningCount,DesiredCount:desiredCount}'

# Step 6: Test health endpoint
Write-Host "🩺 Testing health endpoint..."
Start-Sleep 30
try {
    $health = Invoke-RestMethod -Uri "http://devops-pipeline-alb-362222936.eu-north-1.elb.amazonaws.com/health" -TimeoutSec 10
    Write-Host "✅ Health Check: SUCCESS - $($health | ConvertTo-Json)"
} catch {
    Write-Host "❌ Health Check: FAILED - $($_.Exception.Message)"
}

Write-Host "🎉 Deploy fix complete!"
