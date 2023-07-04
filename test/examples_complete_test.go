package e2e_test

import (
	"e2e_test/test/utils"
	"fmt"
	"testing"

	"github.com/gruntwork-io/terratest/modules/aws"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

type moduleInputs struct {
	BucketName         string
	EKSoidcProviderARN string
	IAMroleName        string
	KMSkeyARN          string
	NamePrefix         string
}

type moduleOutputs struct {
	IAMroleARN string
}

const modulePath = "examples/complete"

func TestIRSAmodule(t *testing.T) {
	t.Parallel()

	var (
		awsAccountID  = aws.GetAccountId(t)
		roleArnPrefix = fmt.Sprintf("arn:aws:iam::%s:role/", awsAccountID)
		inputs        = moduleInputs{}
		outputs       = moduleOutputs{}
	)

	// Define inputs
	inputs.BucketName = "uds-dev-state-bucket" // Bucket must already exist
	inputs.EKSoidcProviderARN = "arn:aws:iam::***:oidc-provider/oidc.eks.us-west-2.amazonaws.com/id/4B4623F859FE9B94F78C11A191A860B6"
	inputs.IAMroleName = "should-override-name-prefix"
	inputs.KMSkeyARN = "arn:aws:kms:us-west-2:123456789012:key/abcd1234-5678-efgh-ijkl-1234567890ab"
	inputs.NamePrefix = "test"

	// Define outputs
	outputs.IAMroleARN = "irsa_role_arn"

	testCases := []utils.TestCase{
		{
			Name: "Assert the name prefix value is being applied to the IAM role ARN properly",
			TerraformOptions: &terraform.Options{
				TerraformDir: utils.CreateTempDir(t, modulePath),
				Vars: map[string]interface{}{
					"bucket_name":           inputs.BucketName,
					"eks_oidc_provider_arn": inputs.EKSoidcProviderARN,
					"kms_key_arn":           inputs.KMSkeyARN,
					"name_prefix":           inputs.NamePrefix,
				},
			},
			TerraformOutputName: outputs.IAMroleARN,
			ExpectedOutputValue: roleArnPrefix + "test-default-irsa",
		},
		{
			Name: "Assert that an IAM role name overrides the name prefix when both a role name and prefix are provided",
			TerraformOptions: &terraform.Options{
				TerraformDir: utils.CreateTempDir(t, modulePath),
				Vars: map[string]interface{}{
					"bucket_name":           inputs.BucketName,
					"eks_oidc_provider_arn": inputs.EKSoidcProviderARN,
					"irsa_iam_role_name":    inputs.IAMroleName, // This should override the name prefix
					"kms_key_arn":           inputs.KMSkeyARN,
					"name_prefix":           inputs.NamePrefix,
				},
			},
			TerraformOutputName: outputs.IAMroleARN,
			ExpectedOutputValue: roleArnPrefix + inputs.IAMroleName,
		},
	}

	assertRoleARN := func(t *testing.T, testCase utils.TestCase) {
		t.Helper()
		terraformOutputValue := terraform.Output(t, testCase.TerraformOptions, testCase.TerraformOutputName)
		errorMessage := fmt.Sprintf("Test case '%s' failed", testCase.Name)
		assert.Equal(t, terraformOutputValue, testCase.ExpectedOutputValue, errorMessage)
	}

	utils.ExecuteTestCases(t, testCases, assertRoleARN)
}
