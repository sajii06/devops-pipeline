#!/usr/bin/env pwsh

Write-Host "🚀 DevOps Pipeline App Runner" -ForegroundColor Cyan
Write-Host "=============================" -ForegroundColor Cyan
Write-Host ""

$choice = Read-Host "Choose how to run the app:
1) Local Python (Development)
2) Docker (Recommended) 
3) ECR Image (Production)
4) Exit

Enter choice (1-4)"

switch ($choice) {
    "1" {
        Write-Host "🐍 Running with Local Python..." -ForegroundColor Yellow
        cd app
        pip install -r requirements.txt
        Write-Host "Starting Flask app at http://localhost:5000" -ForegroundColor Green
        python app.py
    }
    "2" {
        Write-Host "🐳 Running with Docker..." -ForegroundColor Yellow
        docker build -t devops-pipeline-app ./app
        Write-Host "Starting Docker container at http://localhost:5000" -ForegroundColor Green
        docker run -p 5000:5000 devops-pipeline-app
    }
    "3" {
        Write-Host "☁️ Running ECR Image..." -ForegroundColor Yellow
        $account = (aws sts get-caller-identity --query Account --output text)
        Write-Host "Starting ECR image at http://localhost:5000" -ForegroundColor Green
        docker run -p 5000:5000 "$account.dkr.ecr.eu-north-1.amazonaws.com/devops-pipeline:latest"
    }
    "4" {
        Write-Host "👋 Goodbye!" -ForegroundColor Green
        exit
    }
    default {
        Write-Host "❌ Invalid choice. Please run the script again." -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "📱 Test your app:" -ForegroundColor Cyan
Write-Host "Main endpoint: http://localhost:5000" -ForegroundColor White
Write-Host "Health check:  http://localhost:5000/health" -ForegroundColor White
