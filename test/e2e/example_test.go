package test_test

import (
	"testing"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

const testDir = "../../examples/complete"

// Var Names
const env_selector = "environment"
const env_region = "region"

// Var values
const val_selector = "dev"
const val_region = "region3"

func TestExampleComplete(t *testing.T) {

	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: testDir,

		Vars: map[string]interface{}{
			env_selector: val_selector,
			env_region: val_region,
		},

		NoColor: true,
	})

	defer terraform.Destroy(t, terraformOptions)

	terraform.InitAndApply(t, terraformOptions)
	output := terraform.Output(t, terraformOptions, "instance")
	assert.Equal(t, "linode/arch", output )
}
