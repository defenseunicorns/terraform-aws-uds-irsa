.PHONY: test
test: ## Run automated tests for IRSA module
	cd test && go test . -v -count=1
