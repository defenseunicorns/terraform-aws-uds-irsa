.PHONY: test
test: ## Run automated tests. Requires go and terraform to be installed locally.
	cd test && go test . -v -count=1

.PHONY: lint
lint: ## Lint terraform files. Requires tflint to be installed locally.
	tflint -f compact --recursive
