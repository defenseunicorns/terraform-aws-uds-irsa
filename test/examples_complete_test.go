package e2e_test

import (
	"e2e_test/test/utils"
	"encoding/json"
	"fmt"
	"net/url"
	"testing"
    "strings"
	"regexp"
	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/service/iam"
	terratest_aws "github.com/gruntwork-io/terratest/modules/aws"
	"github.com/gruntwork-io/terratest/modules/terraform"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

type policyDocumentStatementPrincipal struct {
	Federated string `json:"Federated"`
}

type policyDocumentStatementCondition struct {
	StringEquals map[string]interface{} `json:"StringEquals"`
}

type policyDocumentStatement struct {
	Sid       string                           `json:"Sid"`
	Effect    string                           `json:"Effect"`
	Principal policyDocumentStatementPrincipal `json:"Principal"`
	Action    string                           `json:"Action"`
	Condition policyDocumentStatementCondition `json:"Condition"`
}

type policyDocument struct {
	Version   string                    `json:"Version"`
	Statement []policyDocumentStatement `json:"Statement"`
}

const (
	awsRegion             = "us-west-2"
	modulePath            = "examples/complete"
	irsa_role_arn_output  = "role_arn"
	irsa_role_name_output = "role_name"
	name                  = "some-cluster-name"
	namespace             = "some-namespace"
	service_account       = "service-account"
)

// Function for generating the formatted role name
func formatName(name string, serviceAccount string) string {
	trimmedServiceAccount := strings.TrimLeft(serviceAccount, "-*")
	result := fmt.Sprintf("%s-%s-%s", name, trimmedServiceAccount, "irsa")
	return result
}
// Function for removing randomly generated hexadecimal characters from the role arn (required for testing in parallel)
func stripHexadecimal(input string) string {
	regex_hex := regexp.MustCompile(`-[0-9a-fA-F]+-irsa$`)
	strippedString := regex_hex.ReplaceAllString(input, "-irsa")
	return strippedString
}

// Remove randmomly generated guid at the end of k8s service account name
func stripServiceAccountGuid(input string) string {
	pattern := `(.*)-[^-]+$`
	regex_guid := regexp.MustCompile(pattern)
	match := regex_guid.FindStringSubmatch(input)
	trimmedStr := match[1]
	return trimmedStr
}

// TestIAMRoleArnOutput verifies that the IAM role ARN output string is what we expect it to be based on the IAM role name.
func TestIAMRoleArnOutput(t *testing.T) {
	t.Parallel()

	var (
		awsAccountID  = terratest_aws.GetAccountId(t)
		roleArnPrefix = fmt.Sprintf("arn:aws:iam::%s:role/", awsAccountID)
		formattedName =  formatName(name, service_account)
	)

	testCases := []utils.TestCase{
		{
			Name: "Assert the default role name value is being applied to the IAM role ARN properly",
			TerraformOptions: &terraform.Options{
				TerraformDir: utils.CreateTempDir(t, modulePath),
				Vars: map[string]interface{}{
					"kubernetes_service_account": service_account, // Pass in tf var kubernetes_service_account
					"name": name, // Pass in tf var name
				},
			},
			TerraformOutputName: irsa_role_arn_output,
			ExpectedOutputValue: roleArnPrefix + formattedName,
		},
		{
			Name: "Assert that a user provided IAM role name overrides the default name",
			TerraformOptions: &terraform.Options{
				TerraformDir: utils.CreateTempDir(t, modulePath),
				Vars: map[string]interface{}{
					"irsa_iam_role_name": "should-override-default-name", // Pass in an IAM role name to override the default name
				},
			},
			TerraformOutputName: irsa_role_arn_output,
			ExpectedOutputValue: roleArnPrefix + "should-override-default-name",
		},
	}
	
	assertRoleARN := func(t *testing.T, testCase utils.TestCase) {
		t.Helper()
		actualOutputValue := terraform.Output(t, testCase.TerraformOptions, testCase.TerraformOutputName)
		errorMessage := fmt.Sprintf("Test case '%s' failed", testCase.Name)
		assert.Contains(t, stripHexadecimal(actualOutputValue), testCase.ExpectedOutputValue, errorMessage)
	}

	utils.ExecuteTestCases(t, testCases, assertRoleARN)
}

// TestOIDCProviderArn verifies that the ARN value of the federated principal in the trusted entitites policy is what we expect it to be.
func TestOIDCProviderArn(t *testing.T) {
	t.Parallel()

	var (
		awsAccountID          = terratest_aws.GetAccountId(t)
		oidcProviderArnPrefix = fmt.Sprintf("arn:aws:iam::%s:oidc-provider/", awsAccountID)
	)

	testCases := []utils.TestCase{
		{
			Name: "Assert the OIDC provider ARN in the assume role policy document for the IRSA role is what we expect it to be",
			TerraformOptions: &terraform.Options{
				TerraformDir: utils.CreateTempDir(t, modulePath),
			},
			ExpectedOutputValue: oidcProviderArnPrefix,
		},
		{
			Name: "Assert the OIDC provider ARN in the assume role policy document for the IRSA role is what we expect it to be when overriding the OIDC provider url",
			TerraformOptions: &terraform.Options{
				TerraformDir: utils.CreateTempDir(t, modulePath),
				Vars: map[string]interface{}{
					"oidc_provider_arn": "oidc.eks.us-west-2.amazonaws.com/id/pass-in-oidc-provider-url",
				},
			},
			ExpectedOutputValue: oidcProviderArnPrefix + "oidc.eks.us-west-2.amazonaws.com/id/pass-in-oidc-provider-url",
		},
	}

	assertOIDCProviderArn := func(t *testing.T, testCase utils.TestCase) {
		t.Helper()

		assumeRolePolicy := getAssumeRolePolicyDocument(t, testCase, policyDocument{})

		// Assert that the federated principal ARN value for the OIDC provider matches the expected output.
		federatedPrincipal := assumeRolePolicy.Statement[0].Principal.Federated
		errorMessage := fmt.Sprintf("Test case '%s' failed", testCase.Name)
		assert.Equal(t, testCase.ExpectedOutputValue, federatedPrincipal, errorMessage)
	}

	utils.ExecuteTestCases(t, testCases, assertOIDCProviderArn)
}

// TestFullyQualifiedSubjects verifies that the OIDC fully qualified subjects var value passed to the Condition.StringEquals field in the trusted entities policy is what we expect it to be.
func TestFullyQualifiedSubjects(t *testing.T) {
	t.Parallel()

	var (
		keyAud = ":aud"
	    keySub = ":sub"
	)
	expectedFullyQualifiedSubjects := map[string]interface{}{
		keyAud : "sts.amazonaws.com",
		keySub : "system:serviceaccount:" + namespace + ":" + service_account,
		// "oidc.eks.us-west-2.amazonaws.com/id/pass-in-oidc-provider-url:sub": "system:serviceaccount:test-data:test-data",
	}

	testCases := []utils.TestCase{
		{
			Name: "Assert the OIDC fully qualified subjects in the assume role policy document for the IRSA role is what we expect it to be",
			TerraformOptions: &terraform.Options{
				TerraformDir: utils.CreateTempDir(t, modulePath),
				VarFiles:     []string{"example.tfvars"},
			},
			ExpectedOutputValue: expectedFullyQualifiedSubjects,
		},
	}

	assertOIDCFullyQualifiedSubjects := func(t *testing.T, testCase utils.TestCase) {
		t.Helper()
        
		assumeRolePolicy := getAssumeRolePolicyDocument(t, testCase, policyDocument{})
		// Assert that the OIDC fully qualified subject matches the expected output.
		fullyQualifiedSubjects := assumeRolePolicy.Statement[0].Condition.StringEquals
		errorMessage := fmt.Sprintf("Test case '%s' failed", testCase.Name)

		// Loop over the expected results to ensure all cases are validated
		for key, value := range expectedFullyQualifiedSubjects {
		  returnedValue := fullyQualifiedSubjects[key]
		  // Strip the random guids from the service account name (if the returned value is a service account)
		  if strings.Contains(fmt.Sprint(returnedValue), "system:serviceaccount") {
			returnedValue = stripServiceAccountGuid(fmt.Sprint(returnedValue))
		  }
		  assert.EqualValues(t, value, returnedValue, errorMessage)
		}
	}

	utils.ExecuteTestCases(t, testCases, assertOIDCFullyQualifiedSubjects)
}

// getAssumeRolePolicyDocument decodes and unmarshals the trust relationship policy for the created IRSA role.
func getAssumeRolePolicyDocument(t *testing.T, testCase utils.TestCase, assumeRolePolicy policyDocument) policyDocument {
	t.Helper()

	// Fetch the IAM role policy document
	iamClient := terratest_aws.NewIamClient(t, awsRegion)
	roleName := terraform.Output(t, testCase.TerraformOptions, irsa_role_name_output)
	iamRoleOutput, err := iamClient.GetRole(&iam.GetRoleInput{
		RoleName: &roleName,
	})
	require.NoError(t, err)

	// Decode JSON policy document and unmarshal
	assumeRolePolicyDoc := aws.StringValue(iamRoleOutput.Role.AssumeRolePolicyDocument)
	decodedPolicyDoc, err := url.PathUnescape(assumeRolePolicyDoc)
	require.NoError(t, err)
	if err := json.Unmarshal([]byte(decodedPolicyDoc), &assumeRolePolicy); err != nil {
		require.NoError(t, err)
	}

	return assumeRolePolicy
}
