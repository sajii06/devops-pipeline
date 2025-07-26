package test

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

func TestTerraformCodePipeline(t *testing.T) {
	// Configure Terraform options
	terraformOptions := &terraform.Options{
		// Path to the Terraform configuration
		TerraformDir: "../",

		// Variables to pass to our Terraform code using -var options
		Vars: map[string]interface{}{
			"project_name":         "devops-pipeline",
			"artifact_bucket_name": "devops-pipeline-artifacts-devops200406",
			"github_repo":          "sajii06/devops-pipeline",
			"github_branch":        "main",
			"github_token":         "dummy-token-for-test",
			"aws_region":           "eu-north-1",
		},

		// Disable colors in Terraform commands so it's easier to parse stdout/stderr
		NoColor: true,
	}

	// Run "terraform init" and "terraform plan". 
	terraform.Init(t, terraformOptions)
	planOutput := terraform.Plan(t, terraformOptions)

	// Validate the plan contains expected resources
	assert.Contains(t, planOutput, "aws_codepipeline")
	assert.Contains(t, planOutput, "aws_codebuild_project")
	assert.Contains(t, planOutput, "aws_s3_bucket")
	assert.Contains(t, planOutput, "aws_iam_role")
}

func TestS3BucketModule(t *testing.T) {
	t.Parallel()

	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../modules/s3",
		Vars: map[string]interface{}{
			"bucket_name":  "test-bucket-12345",
			"project_name": "test-project",
		},
		NoColor: true,
	})

	defer terraform.Destroy(t, terraformOptions)

	terraform.InitAndPlan(t, terraformOptions)
	planOutput := terraform.Plan(t, terraformOptions)
	
	assert.Contains(t, planOutput, "aws_s3_bucket.artifacts")
	assert.Contains(t, planOutput, "aws_s3_bucket_versioning.artifacts_versioning")
}
