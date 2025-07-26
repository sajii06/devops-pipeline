# Upload Source to S3 and Trigger Pipeline
Write-Host "📦 Creating source archive..." -ForegroundColor Yellow

# Create source zip excluding unnecessary files
$excludePatterns = @(
    ".git",
    ".terraform",
    "terraform.tfstate*",
    "*.log",
    ".vscode",
    "node_modules"
)

# Create a temporary directory for the source
$tempDir = New-TemporaryFile | %{ rm $_; mkdir $_ }
Copy-Item -Recurse -Path ".\*" -Destination $tempDir -Exclude $excludePatterns

# Create zip file
$zipPath = ".\source.zip"
Compress-Archive -Path "$tempDir\*" -DestinationPath $zipPath -Force

Write-Host "✅ Source archive created: $zipPath" -ForegroundColor Green

# Upload to S3
Write-Host "📤 Uploading to S3..." -ForegroundColor Yellow
aws s3 cp $zipPath s3://devops-pipeline-artifacts-devops200406/source.zip --region eu-north-1

Write-Host "🚀 Triggering pipeline..." -ForegroundColor Yellow
aws codepipeline start-pipeline-execution --name devops-pipeline-pipeline --region eu-north-1

Write-Host "✅ Pipeline triggered successfully!" -ForegroundColor Green
Write-Host "Monitor at: https://eu-north-1.console.aws.amazon.com/codesuite/codepipeline/pipelines/devops-pipeline-pipeline/view" -ForegroundColor Cyan

# Cleanup
Remove-Item $zipPath -Force
Remove-Item $tempDir -Recurse -Force
