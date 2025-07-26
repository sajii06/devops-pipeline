# GitHub Actions Workflows

Ultra-compact workflows for fast CI/CD:

## 🔄 Workflows (Under 25 lines each!)

### 1. **devsecops.yml** - Main Pipeline (25 lines)
- Terraform plan/apply + deployment
- Triggers: Push to main/develop, Pull requests

### 2. **build-test.yml** - Build & Test (12 lines)  
- Python setup, Docker build
- Triggers: Push to main/develop, Pull requests

### 3. **security.yml** - Security Scanning (15 lines)
- tfsec + Trivy scanning
- Triggers: Push to main/develop, Pull requests

## 🚀 Manual Deploy Options

- **PowerShell**: `.\manual-deploy.ps1` (8 lines)
- **Bash**: `./manual-deploy.sh` (8 lines)

## 📊 Benefits

- ⚡ **Ultra-fast**: All workflows under 25 lines
- 🔄 **Parallel**: All run simultaneously  
- 📝 **Minimal**: Essential functionality only
- 🛠️ **Simple**: Easy to modify and debug
