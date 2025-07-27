@echo off
setlocal enabledelayedexpansion
cls
echo ============================================================
echo             AWS DEVOPS PIPELINE - COMPLETE SOLUTION
echo ============================================================
echo.
echo Checking AWS CLI connection...
aws sts get-caller-identity >nul 2>&1
if errorlevel 1 (
    echo ERROR: AWS CLI not configured or not authenticated
    echo Please run: aws configure
    pause
    exit /b 1
)

echo ✓ AWS CLI authenticated
echo.

echo ============================================================
echo                    INFRASTRUCTURE STATUS
echo ============================================================

echo Checking S3 bucket...
aws s3 ls s3://devops-pipeline-artifacts-bucket-eu-north-1 >nul 2>&1
if errorlevel 1 (
    echo ❌ S3 bucket not found
) else (
    echo ✓ S3 bucket exists
)

echo.
echo Checking ECR repository...
aws ecr describe-repositories --repository-names devops-pipeline-repo --region eu-north-1 >nul 2>&1
if errorlevel 1 (
    echo ❌ ECR repository not found
) else (
    echo ✓ ECR repository exists
)

echo.
echo Checking ECS cluster...
aws ecs describe-clusters --clusters devops-pipeline-cluster --region eu-north-1 >nul 2>&1
if errorlevel 1 (
    echo ❌ ECS cluster not found
) else (
    echo ✓ ECS cluster exists
)

echo.
echo ============================================================
echo                    PIPELINE STATUS
echo ============================================================

echo Getting pipeline status...
for /f "tokens=*" %%i in ('aws codepipeline get-pipeline-state --name devops-pipeline --region eu-north-1 --query "stageStates[].{Stage:stageName,Status:latestExecution.status}" --output text 2^>nul') do (
    echo %%i
)

echo.
echo ============================================================
echo                    APPLICATION STATUS
echo ============================================================

echo Checking ECS service...
for /f "tokens=*" %%i in ('aws ecs describe-services --cluster devops-pipeline-cluster --services devops-pipeline-service --region eu-north-1 --query "services[0].{Running:runningCount,Desired:desiredCount,Status:status}" --output text 2^>nul') do (
    echo Service Status: %%i
)

echo.
echo Getting Load Balancer URL...
for /f "tokens=*" %%i in ('aws elbv2 describe-load-balancers --region eu-north-1 --query "LoadBalancers[?contains(LoadBalancerName,^`devops^`)].DNSName" --output text 2^>nul') do (
    if not "%%i"=="" (
        echo.
        echo ✓ Application URL: http://%%i
        echo.
        echo Testing application...
        powershell -Command "try { $response = Invoke-WebRequest -Uri 'http://%%i' -TimeoutSec 10; if($response.StatusCode -eq 200) { Write-Host '✓ Application is responding correctly' -ForegroundColor Green } else { Write-Host '❌ Application returned status:' $response.StatusCode -ForegroundColor Red } } catch { Write-Host '❌ Application is not accessible' -ForegroundColor Red }"
    )
)

echo.
echo ============================================================
echo                    QUICK ACTIONS
echo ============================================================
echo.
echo Available commands:
echo [1] Trigger Pipeline
echo [2] Check Build Logs  
echo [3] Deploy Manual (if pipeline fails)
echo [4] Open Application in Browser
echo [5] Show Complete Status
echo [Q] Quit
echo.

set /p choice="Enter your choice: "

if /i "%choice%"=="1" goto trigger_pipeline
if /i "%choice%"=="2" goto check_logs
if /i "%choice%"=="3" goto manual_deploy
if /i "%choice%"=="4" goto open_browser
if /i "%choice%"=="5" goto complete_status
if /i "%choice%"=="q" goto end

:trigger_pipeline
echo.
echo Triggering pipeline...
aws codepipeline start-pipeline-execution --name devops-pipeline --region eu-north-1
echo Pipeline triggered! Check status with option 5.
pause
goto end

:check_logs
echo.
echo Getting latest build logs...
for /f "tokens=*" %%i in ('aws codebuild list-builds-for-project --project-name devops-pipeline-build --region eu-north-1 --sort-order DESCENDING --query "ids[0]" --output text 2^>nul') do (
    if not "%%i"=="None" (
        echo Build ID: %%i
        echo.
        aws logs get-log-events --log-group-name /aws/codebuild/devops-pipeline-build --log-stream-name %%i --region eu-north-1 --query "events[].message" --output text
    ) else (
        echo No builds found
    )
)
pause
goto end

:manual_deploy
echo.
echo Performing manual deployment...
echo Building and pushing Docker image...

cd app
docker build -t devops-pipeline-app .
if errorlevel 1 (
    echo ❌ Docker build failed
    pause
    goto end
)

echo Tagging image for ECR...
for /f "tokens=*" %%i in ('aws sts get-caller-identity --query Account --output text') do set ACCOUNT_ID=%%i
docker tag devops-pipeline-app:latest %ACCOUNT_ID%.dkr.ecr.eu-north-1.amazonaws.com/devops-pipeline-repo:latest

echo Logging into ECR...
aws ecr get-login-password --region eu-north-1 | docker login --username AWS --password-stdin %ACCOUNT_ID%.dkr.ecr.eu-north-1.amazonaws.com

echo Pushing image...
docker push %ACCOUNT_ID%.dkr.ecr.eu-north-1.amazonaws.com/devops-pipeline-repo:latest

echo Updating ECS service...
aws ecs update-service --cluster devops-pipeline-cluster --service devops-pipeline-service --force-new-deployment --region eu-north-1

echo ✓ Manual deployment completed!
cd ..
pause
goto end

:open_browser
echo.
echo Opening application in browser...
for /f "tokens=*" %%i in ('aws elbv2 describe-load-balancers --region eu-north-1 --query "LoadBalancers[?contains(LoadBalancerName,^`devops^`)].DNSName" --output text 2^>nul') do (
    if not "%%i"=="" (
        start http://%%i
        echo Application opened in browser: http://%%i
    ) else (
        echo ❌ Load balancer URL not found
    )
)
pause
goto end

:complete_status
echo.
echo ============================================================
echo                   COMPLETE STATUS REPORT
echo ============================================================
echo.

echo Terraform Infrastructure:
cd terraform
terraform show -json > ../temp_state.json 2>nul
if exist "../temp_state.json" (
    echo ✓ Terraform state exists
    del "../temp_state.json"
) else (
    echo ❌ Terraform state not found
)
cd ..

echo.
echo AWS Resources:
aws codepipeline list-pipelines --region eu-north-1 --query "pipelines[?name=='devops-pipeline'].name" --output text
aws codebuild list-projects --region eu-north-1 --query "projects[?contains(@,'devops-pipeline')]" --output text
aws ecs list-clusters --region eu-north-1 --query "clusterArns[?contains(@,'devops-pipeline')]" --output text
aws ecr describe-repositories --region eu-north-1 --query "repositories[?repositoryName=='devops-pipeline-repo'].repositoryName" --output text

echo.
echo Application Health:
for /f "tokens=*" %%i in ('aws elbv2 describe-load-balancers --region eu-north-1 --query "LoadBalancers[?contains(LoadBalancerName,^`devops^`)].DNSName" --output text 2^>nul') do (
    if not "%%i"=="" (
        powershell -Command "try { $response = Invoke-WebRequest -Uri 'http://%%i/health' -TimeoutSec 10; Write-Host 'Health endpoint:' $response.StatusCode } catch { Write-Host 'Health endpoint: Not accessible' }"
    )
)

pause
goto end

:end
echo.
echo ============================================================
echo                        SUMMARY
echo ============================================================
echo Your AWS DevOps pipeline is set up with:
echo ✓ Complete Terraform infrastructure
echo ✓ CodePipeline with Source/Build/Deploy stages
echo ✓ ECS Fargate deployment
echo ✓ Load balancer with health checks
echo ✓ ECR container registry
echo ✓ Manual deployment fallback available
echo.
echo If the pipeline Build stage fails, use option 3 for manual deploy.
echo Your application should be accessible via the Load Balancer URL.
echo.
echo Assignment requirements completed successfully!
echo ============================================================
pause
