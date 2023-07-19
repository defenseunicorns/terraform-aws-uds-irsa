.PHONY: test
test: ## Run automated tests. Requires go and terraform to be installed locally.
	cd test && go test . -v -count=1

.PHONY: pre-flight
pre-flight: ## Run pre-flight checks against the example module.
	cd examples/complete && terraform init && terraform fmt && terraform validate && terraform plan && tflint -f compact --recursive
