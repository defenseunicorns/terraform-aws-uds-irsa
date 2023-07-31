package utils

import (
	"fmt"
	"github.com/gruntwork-io/terratest/modules/terraform"
	testStructure "github.com/gruntwork-io/terratest/modules/test-structure"
	"os"
	"regexp"
	"strings"
	"sync"
	"testing"
)

type TestCase struct {
	Name                string
	TerraformOutputName string
	ExpectedOutputValue interface{}
	TerraformOptions    *terraform.Options
}

// ExecuteTestCases deploys the example module, executes the provided test function, and tears down the example module for the provided test cases.
func ExecuteTestCases(t *testing.T, testCases []TestCase, testFunction func(*testing.T, TestCase)) {
	t.Helper()

	var wg sync.WaitGroup
	for _, testCase := range testCases {
		defer os.RemoveAll(testCase.TerraformOptions.TerraformDir)
		if testFunction != nil {
			wg.Add(1)
			go func(tc TestCase) {
				defer wg.Done()

				defer terraform.Destroy(t, tc.TerraformOptions)
				terraform.InitAndApply(t, tc.TerraformOptions)

				testFunction(t, tc)
			}(testCase)
		} else {
			// Fail the test case when a test function is not defined
			t.Fatalf("Test function not provided for test case: '%s'\n", testCase.Name)
		}
	}
	wg.Wait()
}

// CreateTempDir creates a temporary directory and copies the example terraform module to it.
// This allows multiple tests to in parallel against the same set of Terraform files.
func CreateTempDir(t *testing.T, modulePath string) (testDir string) {
	return testStructure.CopyTerraformFolderToTemp(t, "..", modulePath)
}

// Function for generating the formatted role name
func FormatName(name string, serviceAccount string) string {
	trimmedServiceAccount := strings.TrimLeft(serviceAccount, "-*")
	result := fmt.Sprintf("%s-%s-%s", name, trimmedServiceAccount, "irsa")
	return result
}

// Function for removing randomly generated hexadecimal characters from the role arn (required for testing in parallel)
func StripHexadecimal(input string) string {
	regex_hex := regexp.MustCompile(`-[0-9a-fA-F]+-irsa$`)
	strippedString := regex_hex.ReplaceAllString(input, "-irsa")
	return strippedString
}

// Remove randmomly generated guid at the end of k8s service account name
func StripServiceAccountGuid(input string) string {
	pattern := `(.*)-[^-]+$`
	regex_guid := regexp.MustCompile(pattern)
	match := regex_guid.FindStringSubmatch(input)
	trimmedStr := match[1]
	return trimmedStr
}
