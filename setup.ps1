# DevOps Pipeline Setup Script for Windows PowerShell
# This script helps you set up the project step by step

Write-Host "DevOps Pipeline Setup Script" -ForegroundColor Green
Write-Host "============================" -ForegroundColor Green
Write-Host ""

# Check prerequisites
Write-Host "Checking prerequisites..." -ForegroundColor Yellow

# Check if AWS CLI is installed
try {
    aws --version | Out-Null
    Write-Host "AWS CLI is installed!" -ForegroundColor Green
} catch {
    Write-Host "AWS CLI is not installed. Please install it first." -ForegroundColor Red
    exit 1
}

# Check if Terraform is installed
try {
    terraform version | Out-Null
    Write-Host "Terraform is installed!" -ForegroundColor Green
} catch {
    Write-Host "Terraform is not installed. Please install it first." -ForegroundColor Red
    exit 1
}

# Check if kubectl is installed
try {
    kubectl version --client | Out-Null
    Write-Host "kubectl is installed!" -ForegroundColor Green
} catch {
    Write-Host "kubectl is not installed. Please install it first." -ForegroundColor Red
    exit 1
}

# Check if Docker is installed
try {
    docker --version | Out-Null
    Write-Host "Docker is installed!" -ForegroundColor Green
} catch {
    Write-Host "Docker is not installed. Please install it first." -ForegroundColor Red
    exit 1
}

Write-Host ""

# Check AWS credentials
Write-Host "Checking AWS credentials..." -ForegroundColor Yellow
try {
    aws sts get-caller-identity | Out-Null
    Write-Host "AWS credentials are configured!" -ForegroundColor Green
} catch {
    Write-Host "AWS credentials are not configured. Please run 'aws configure' first." -ForegroundColor Red
    exit 1
}

Write-Host ""

# Setup Terraform variables
Write-Host "Setting up Terraform variables..." -ForegroundColor Yellow
if (!(Test-Path "terraform\terraform.tfvars")) {
    Copy-Item "terraform\terraform.tfvars.example" "terraform\terraform.tfvars"
    Write-Host "Created terraform\terraform.tfvars from example file." -ForegroundColor Cyan
    Write-Host "Please edit terraform\terraform.tfvars with your specific values:" -ForegroundColor Yellow
    Write-Host "   - Update artifact_bucket_name to be globally unique" -ForegroundColor White
    Write-Host "   - Update github_repo to your repository" -ForegroundColor White
    Write-Host "   - Add your github_token" -ForegroundColor White
    Write-Host ""
    Write-Host "Press Enter when you have updated the file..." -ForegroundColor Yellow
    Read-Host
} else {
    Write-Host "terraform.tfvars already exists!" -ForegroundColor Green
}

# GitHub token check
Write-Host "Checking GitHub token..." -ForegroundColor Yellow
$github_token = Read-Host "Enter your GitHub personal access token" -AsSecureString
$github_token_plain = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($github_token))

if ([string]::IsNullOrEmpty($github_token_plain)) {
    Write-Host "GitHub token is required. Please create one at https://github.com/settings/tokens" -ForegroundColor Red
    exit 1
}

# Initialize Terraform
Write-Host "Initializing Terraform..." -ForegroundColor Yellow
Set-Location terraform
terraform init

Write-Host "Planning Terraform deployment..." -ForegroundColor Yellow
terraform plan -var="github_token=$github_token_plain"

Write-Host ""
Write-Host "Setup completed successfully!" -ForegroundColor Green
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Cyan
Write-Host "1. Review the Terraform plan above" -ForegroundColor White
Write-Host "2. If everything looks good, run: terraform apply -var=`"github_token=$github_token_plain`"" -ForegroundColor White
Write-Host "3. Set up GitHub Actions secrets in your repository" -ForegroundColor White
Write-Host "4. Set up Kubernetes Sealed Secrets controller" -ForegroundColor White
Write-Host ""
Write-Host "For detailed instructions, see the README.md file." -ForegroundColor Cyan
