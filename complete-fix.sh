#!/bin/bash
echo "🔧 Complete DevOps Pipeline Configuration Fix"

# Step 1: Build and push correct Docker image
echo "📦 Building and pushing Docker image..."
docker build -t devops-pipeline:latest ./app
aws ecr get-login-password --region eu-north-1 | docker login --username AWS --password-stdin 070593201734.dkr.ecr.eu-north-1.amazonaws.com
docker tag devops-pipeline:latest 070593201734.dkr.ecr.eu-north-1.amazonaws.com/devops-pipeline:latest
docker push 070593201734.dkr.ecr.eu-north-1.amazonaws.com/devops-pipeline:latest

# Step 2: Create/update IAM role
echo "🔐 Setting up IAM role..."
aws iam create-role --role-name ecsTaskExecutionRole --assume-role-policy-document '{"Version":"2012-10-17","Statement":[{"Effect":"Allow","Principal":{"Service":"ecs-tasks.amazonaws.com"},"Action":"sts:AssumeRole"}]}' --region eu-north-1 2>/dev/null || echo "Role already exists"
aws iam attach-role-policy --role-name ecsTaskExecutionRole --policy-arn arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy

# Step 3: Register task definition with correct container name
echo "📋 Registering task definition..."
aws ecs register-task-definition --cli-input-json file://task-definition-corrected.json --region eu-north-1

# Step 4: Update ECS service
echo "🚀 Updating ECS service..."
aws ecs update-service --cluster devops-pipeline-cluster --service devops-pipeline-service --task-definition devops-pipeline-task --force-new-deployment --region eu-north-1

# Step 5: Wait and test
echo "⏳ Waiting for deployment..."
sleep 60

echo "🧪 Testing endpoints..."
curl -s "http://devops-pipeline-alb-362222936.eu-north-1.elb.amazonaws.com/" | jq .
curl -s "http://devops-pipeline-alb-362222936.eu-north-1.elb.amazonaws.com/health" | jq .

echo "✅ Configuration fix complete!"
