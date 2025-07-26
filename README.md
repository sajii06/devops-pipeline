# DevOps Pipeline with AWS CodePipeline, Terraform & DevSecOps

This project demonstrates a complete DevSecOps pipeline using AWS services, Terraform, GitHub Actions, and Kubernetes Sealed Secrets.

## Architecture Overview

The project consists of:
- **Application**: A simple Flask web application containerized with Docker
- **Infrastructure**: AWS CodePipeline, CodeBuild, and supporting services provisioned with Terraform
- **Security**: Automated security scanning with tfsec and Trivy
- **Secrets Management**: Kubernetes Sealed Secrets for secure secret handling
- **CI/CD**: GitHub Actions workflow for automated deployment

## Prerequisites

Before you begin, ensure you have the following:

1. **AWS Account** with appropriate permissions
2. **AWS CLI** configured with your credentials
3. **Terraform** installed (>= 1.0)
4. **Docker** installed
5. **kubectl** installed and configured
6. **GitHub account** with repository access
7. **Kubernetes cluster** (EKS, minikube, or any other)

## Setup Instructions

### Step 1: Clone and Configure Repository

1. Clone this repository to your local machine
2. Update the `terraform/variables.tf` file with your specific values:
   - Change `artifact_bucket_name` to a unique S3 bucket name
   - Update `github_repo` to your GitHub repository (format: owner/repo)

### Step 2: AWS Setup

1. **Configure AWS CLI**:
   ```bash
   aws configure
   ```

2. **Create GitHub Personal Access Token**:
   - Go to GitHub Settings > Developer settings > Personal access tokens
   - Create a token with `repo` and `admin:repo_hook` permissions
   - Store this token securely

### Step 3: Deploy Infrastructure with Terraform

1. **Navigate to terraform directory**:
   ```bash
   cd terraform
   ```

2. **Initialize Terraform**:
   ```bash
   terraform init
   ```

3. **Plan the deployment**:
   ```bash
   terraform plan -var="github_token=YOUR_GITHUB_TOKEN"
   ```

4. **Apply the configuration**:
   ```bash
   terraform apply -var="github_token=YOUR_GITHUB_TOKEN"
   ```

### Step 4: Setup GitHub Actions

1. **Add the following secrets to your GitHub repository**:
   - `AWS_ACCESS_KEY_ID`: Your AWS access key
   - `AWS_SECRET_ACCESS_KEY`: Your AWS secret key
   - `GITHUB_TOKEN`: Your GitHub personal access token

2. **To add secrets**:
   - Go to your repository on GitHub
   - Navigate to Settings > Secrets and variables > Actions
   - Click "New repository secret" and add each secret

### Step 5: Setup Sealed Secrets

1. **Install Sealed Secrets controller in your Kubernetes cluster**:
   ```bash
   kubectl apply -f https://github.com/bitnami-labs/sealed-secrets/releases/download/v0.24.0/controller.yaml
   ```

2. **Install kubeseal CLI tool**:
   ```bash
   # On Linux
   wget https://github.com/bitnami-labs/sealed-secrets/releases/download/v0.24.0/kubeseal-0.24.0-linux-amd64.tar.gz
   tar -xvzf kubeseal-0.24.0-linux-amd64.tar.gz
   sudo install -m 755 kubeseal /usr/local/bin/kubeseal
   ```

3. **Create encrypted secrets**:
   ```bash
   # Create a regular secret first
   kubectl create secret generic app-secrets \
     --from-literal=database-url="postgresql://user:password@localhost:5432/db" \
     --from-literal=api-key="my_secret_api_key" \
     --dry-run=client -o yaml > k8s/secret.yaml

   # Encrypt it with kubeseal
   kubeseal -f k8s/secret.yaml -w k8s/sealed-secrets.yaml
   ```

## Project Structure

```
devops-pipeline/
├── app/                          # Application source code
│   ├── app.py                   # Flask application
│   ├── Dockerfile               # Container definition
│   └── requirements.txt         # Python dependencies
├── terraform/                   # Infrastructure as Code
│   ├── main.tf                 # Main Terraform configuration
│   ├── variables.tf            # Input variables
│   ├── outputs.tf              # Output values
│   ├── modules/                # Terraform modules
│   │   ├── s3/                 # S3 bucket module
│   │   ├── iam/                # IAM roles and policies
│   │   ├── codebuild/          # CodeBuild project
│   │   └── codepipeline/       # CodePipeline configuration
│   └── test/                   # Terratest files
├── k8s/                        # Kubernetes manifests
│   ├── deployment.yaml         # Application deployment
│   ├── service.yaml            # Service definition
│   ├── secret.yaml             # Regular secrets (for reference)
│   └── sealed-secrets.yaml     # Encrypted secrets
├── .github/workflows/          # GitHub Actions
│   └── devsecops.yml          # CI/CD pipeline
├── buildspec.yml              # CodeBuild build specification
└── README.md                  # This file
```

## How It Works

### 1. Code Pipeline (AWS CodePipeline)

- **Source Stage**: Monitors your GitHub repository for changes
- **Build Stage**: Uses AWS CodeBuild to:
  - Build Docker image
  - Run security scans
  - Push image to ECR
- **Deploy Stage**: Updates Kubernetes deployment

### 2. Security Scanning

- **tfsec**: Scans Terraform code for security issues
- **Trivy**: Scans Docker images for vulnerabilities
- **Results**: Uploaded to GitHub Security tab

### 3. Sealed Secrets

- Secrets are encrypted using the cluster's public key
- Only the sealed-secrets controller can decrypt them
- Safe to store encrypted secrets in Git

### 4. GitHub Actions Workflow

Triggers on:
- Push to `main` or `develop` branches
- Pull requests to `main` branch

Workflow steps:
1. Security scanning (tfsec + Trivy)
2. Terraform plan (on PRs)
3. Terraform apply (on main branch)
4. Deploy to Kubernetes with sealed secrets

## Testing with Terratest

Run infrastructure tests:

```bash
cd terraform/test
go mod tidy
go test -v
```

## Monitoring and Troubleshooting

### Check CodePipeline Status
```bash
aws codepipeline get-pipeline-state --name devops-pipeline-pipeline
```

### Check CodeBuild Logs
```bash
aws logs describe-log-groups --log-group-name-prefix "/aws/codebuild/devops-pipeline"
```

### Check Kubernetes Deployment
```bash
kubectl get pods
kubectl get services
kubectl logs -l app=devops-pipeline-app
```

### Verify Sealed Secrets
```bash
kubectl get sealedsecrets
kubectl get secrets
```

## Security Best Practices Implemented

1. **Infrastructure as Code**: All infrastructure defined in Terraform
2. **Security Scanning**: Automated vulnerability scanning
3. **Secrets Management**: Encrypted secrets with Sealed Secrets
4. **Least Privilege**: IAM roles with minimal required permissions
5. **Container Security**: Docker image scanning with Trivy
6. **Secure Storage**: S3 buckets with encryption and access controls

## Cleanup

To destroy all resources:

```bash
# Destroy Terraform infrastructure
cd terraform
terraform destroy -var="github_token=YOUR_GITHUB_TOKEN"

# Clean up Kubernetes resources
kubectl delete -f k8s/
```

## Troubleshooting Common Issues

### 1. GitHub Token Issues
- Ensure token has correct permissions (`repo` and `admin:repo_hook`)
- Check token hasn't expired

### 2. S3 Bucket Already Exists
- Change `artifact_bucket_name` in `terraform/variables.tf` to a unique name

### 3. CodeBuild Failures
- Check build logs in AWS Console
- Verify Docker commands in `buildspec.yml`

### 4. Sealed Secrets Not Working
- Ensure sealed-secrets controller is running
- Check kubeseal CLI version compatibility

## Next Steps

To extend this project, consider:
- Adding more comprehensive tests
- Implementing blue-green deployments
- Adding monitoring and alerting
- Setting up multi-environment deployments
- Implementing infrastructure drift detection

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details."Pipeline activated!" 
#   D e v S e c O p s   P i p e l i n e   -   L a s t   u p d a t e d :   0 7 / 2 7 / 2 0 2 5   0 5 : 0 8 : 5 8  
 