#!/bin/bash

# DevOps Pipeline Setup Script
# This script helps you set up the project step by step

set -e

echo "🚀 DevOps Pipeline Setup Script"
echo "==============================="
echo

# Check prerequisites
echo "📋 Checking prerequisites..."

# Check if AWS CLI is installed
if ! command -v aws &> /dev/null; then
    echo "❌ AWS CLI is not installed. Please install it first."
    exit 1
fi

# Check if Terraform is installed
if ! command -v terraform &> /dev/null; then
    echo "❌ Terraform is not installed. Please install it first."
    exit 1
fi

# Check if kubectl is installed
if ! command -v kubectl &> /dev/null; then
    echo "❌ kubectl is not installed. Please install it first."
    exit 1
fi

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo "❌ Docker is not installed. Please install it first."
    exit 1
fi

echo "✅ All prerequisites are installed!"
echo

# Check AWS credentials
echo "🔑 Checking AWS credentials..."
if ! aws sts get-caller-identity &> /dev/null; then
    echo "❌ AWS credentials are not configured. Please run 'aws configure' first."
    exit 1
fi

echo "✅ AWS credentials are configured!"
echo

# Setup Terraform variables
echo "⚙️  Setting up Terraform variables..."
if [ ! -f terraform/terraform.tfvars ]; then
    cp terraform/terraform.tfvars.example terraform/terraform.tfvars
    echo "📝 Created terraform/terraform.tfvars from example file."
    echo "⚠️  Please edit terraform/terraform.tfvars with your specific values:"
    echo "   - Update artifact_bucket_name to be globally unique"
    echo "   - Update github_repo to your repository"
    echo "   - Add your github_token"
    echo
    echo "Press Enter when you've updated the file..."
    read
else
    echo "✅ terraform.tfvars already exists!"
fi

# GitHub token check
echo "🔗 Checking GitHub token..."
read -p "Enter your GitHub personal access token: " -s github_token
echo

if [ -z "$github_token" ]; then
    echo "❌ GitHub token is required. Please create one at https://github.com/settings/tokens"
    exit 1
fi

# Initialize Terraform
echo "🔧 Initializing Terraform..."
cd terraform
terraform init

echo "📋 Planning Terraform deployment..."
terraform plan -var="github_token=$github_token"

echo
echo "🎯 Setup completed successfully!"
echo
echo "Next steps:"
echo "1. Review the Terraform plan above"
echo "2. If everything looks good, run: terraform apply -var=\"github_token=$github_token\""
echo "3. Set up GitHub Actions secrets in your repository"
echo "4. Set up Kubernetes Sealed Secrets controller"
echo
echo "For detailed instructions, see the README.md file."
