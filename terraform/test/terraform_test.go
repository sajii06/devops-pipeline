package test

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

func TestTerraformCodePipeline(t *testing.T) {
	t.Parallel()

	// Configure Terraform options
	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		// Path to the Terraform configuration
		TerraformDir: "../",

		// Variables to pass to our Terraform code using -var options
		Vars: map[string]interface{}{
			"project_name":         "test-pipeline",
			"artifact_bucket_name": "test-artifacts-bucket-12345",
			"github_repo":          "sajii06/devops-pipeline",
			"github_branch":        "main",
			"github_token":         "fake-token-for-test",
		},

		// Disable colors in Terraform commands so it's easier to parse stdout/stderr
		NoColor: true,
	})

	// Clean up resources with "terraform destroy" at the end of the test
	defer terraform.Destroy(t, terraformOptions)

	// Run "terraform init" and "terraform apply". Fail the test if there are any errors.
	terraform.InitAndPlan(t, terraformOptions)

	// Validate the plan
	planOutput := terraform.Plan(t, terraformOptions)
	assert.Contains(t, planOutput, "aws_codepipeline.pipeline")
	assert.Contains(t, planOutput, "aws_codebuild_project.build_project")
	assert.Contains(t, planOutput, "aws_s3_bucket.artifacts")
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
