# GitHub Actions Workflows

This project uses multiple GitHub Actions workflows for better organization:

## 🔄 Workflows

### 1. **build-test.yml** - Build and Test
- Triggers on: Push to main/develop, Pull requests
- Purpose: Build application, run tests, create Docker image
- Duration: ~2-3 minutes

### 2. **security.yml** - Security Scanning  
- Triggers on: Push to main/develop, Pull requests
- Purpose: Terraform security (tfsec), container scanning (Trivy), secret detection
- Duration: ~3-5 minutes

### 3. **devsecops.yml** - Infrastructure (Main Pipeline)
- Triggers on: Push to main/develop, Pull requests  
- Purpose: Terraform plan/apply, orchestrate deployment
- Duration: ~5-8 minutes

### 4. **deploy.yml** - Deployment
- Triggers on: Push to main, Manual dispatch
- Purpose: Deploy to ECS, trigger CodePipeline
- Duration: ~2-3 minutes

## 🚀 How it Works

1. **On Push/PR**: All workflows run in parallel for faster feedback
2. **On Main Push**: Infrastructure is applied, then deployment is triggered
3. **Manual Deploy**: You can manually trigger deployment anytime

## 📊 Status

- ✅ **Parallel execution** for faster CI/CD
- ✅ **Modular design** for better maintenance  
- ✅ **Focused workflows** for specific purposes
- ✅ **Better error isolation** and debugging

## 🎯 Benefits

- **Faster**: Parallel execution saves time
- **Cleaner**: Each workflow has a single responsibility
- **Maintainable**: Easier to debug and modify
- **Scalable**: Easy to add new workflows
