# DevOps Pipeline Status Check (PowerShell)
Write-Host "=== DevOps Pipeline Status Check ===" -ForegroundColor Green
Write-Host ""

Write-Host "1. Checking AWS CLI connection..." -ForegroundColor Yellow
try {
    $identity = aws sts get-caller-identity --region eu-north-1 | ConvertFrom-Json
    Write-Host "✓ Connected as: $($identity.Arn)" -ForegroundColor Green
} catch {
    Write-Host "✗ AWS CLI connection failed" -ForegroundColor Red
}

Write-Host ""
Write-Host "2. Checking S3 bucket..." -ForegroundColor Yellow
try {
    aws s3 ls s3://devops-pipeline-artifacts-devops200406 --region eu-north-1
    Write-Host "✓ S3 bucket exists" -ForegroundColor Green
} catch {
    Write-Host "✗ S3 bucket not found" -ForegroundColor Red
}

Write-Host ""
Write-Host "3. Checking CodePipeline..." -ForegroundColor Yellow
try {
    $pipeline = aws codepipeline get-pipeline --name devops-pipeline-pipeline --region eu-north-1 | ConvertFrom-Json
    Write-Host "✓ CodePipeline exists: $($pipeline.pipeline.name)" -ForegroundColor Green
} catch {
    Write-Host "✗ CodePipeline not found" -ForegroundColor Red
}

Write-Host ""
Write-Host "4. Checking CodeBuild project..." -ForegroundColor Yellow
try {
    $project = aws codebuild batch-get-projects --names devops-pipeline-build --region eu-north-1 | ConvertFrom-Json
    Write-Host "✓ CodeBuild project exists: $($project.projects[0].name)" -ForegroundColor Green
} catch {
    Write-Host "✗ CodeBuild project not found" -ForegroundColor Red
}

Write-Host ""
Write-Host "5. Checking ECR repository..." -ForegroundColor Yellow
try {
    $ecr = aws ecr describe-repositories --repository-names devops-pipeline --region eu-north-1 | ConvertFrom-Json
    Write-Host "✓ ECR repository exists: $($ecr.repositories[0].repositoryName)" -ForegroundColor Green
} catch {
    Write-Host "! ECR repository not found - will create it" -ForegroundColor Yellow
    try {
        aws ecr create-repository --repository-name devops-pipeline --region eu-north-1
        Write-Host "✓ ECR repository created" -ForegroundColor Green
    } catch {
        Write-Host "✗ Failed to create ECR repository" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "6. Checking Terraform state..." -ForegroundColor Yellow
if (Test-Path "terraform\terraform.tfstate") {
    Write-Host "✓ Terraform state file exists" -ForegroundColor Green
} else {
    Write-Host "✗ Terraform state file not found" -ForegroundColor Red
}

Write-Host ""
Write-Host "=== Status Check Complete ===" -ForegroundColor Green

Write-Host ""
Write-Host "Next Steps:" -ForegroundColor Cyan
Write-Host "1. Add GitHub secrets at: https://github.com/sajii06/devops-pipeline/settings/secrets/actions" -ForegroundColor White
Write-Host "2. Push code changes to trigger the pipeline" -ForegroundColor White
Write-Host "3. Monitor pipeline at: AWS Console > CodePipeline" -ForegroundColor White
