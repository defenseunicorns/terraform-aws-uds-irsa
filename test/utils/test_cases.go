package utils

import (
	"os"
	"sync"
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	testStructure "github.com/gruntwork-io/terratest/modules/test-structure"
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
