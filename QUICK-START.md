# Quick Start Guide for DevOps Pipeline App

## 🚀 Run the App

### Option 1: Local Development
```powershell
cd app
pip install -r requirements.txt
python app.py
```

### Option 2: Docker (Recommended)
```powershell
docker build -t devops-pipeline-app ./app
docker run -p 5000:5000 devops-pipeline-app
```

### Option 3: Use Interactive Script
```powershell
.\run-app.ps1
```

## 📱 Test the App

### Using Browser
- Main page: http://localhost:5000
- Health check: http://localhost:5000/health

### Using curl/PowerShell
```powershell
# Test main endpoint
Invoke-RestMethod -Uri "http://localhost:5000" -Method GET

# Test health endpoint  
Invoke-RestMethod -Uri "http://localhost:5000/health" -Method GET
```

### Using curl (if available)
```bash
curl http://localhost:5000
curl http://localhost:5000/health
```

## 🔧 Development Tips

### Hot Reload (Development)
The app runs with `debug=True`, so changes to `app.py` will automatically reload.

### Production Deployment
For production, use Gunicorn:
```powershell
pip install gunicorn
gunicorn --bind 0.0.0.0:5000 app:app
```

### Environment Variables
Set environment variables to customize behavior:
```powershell
$env:ENVIRONMENT = "production"
python app.py
```

## 🐳 Docker Commands

### Build Image
```powershell
docker build -t devops-pipeline-app ./app
```

### Run Container
```powershell
docker run -p 5000:5000 devops-pipeline-app
```

### Run in Background
```powershell
docker run -d -p 5000:5000 --name my-app devops-pipeline-app
```

### Stop Container
```powershell
docker stop my-app
docker rm my-app
```

## ☁️ AWS ECR Deployment

Your app is already built and available in ECR:
```powershell
# Get account ID
$account = (aws sts get-caller-identity --query Account --output text)

# Run from ECR
docker run -p 5000:5000 "$account.dkr.ecr.eu-north-1.amazonaws.com/devops-pipeline:latest"
```
