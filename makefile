.PHONY: help lint test setup clean

SHELL := /bin/bash

help: ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "  %-15s %s\n", $$1, $$2}'

lint: ## Run ShellCheck on all shell scripts
	@ln -sf .config/.shellcheckrc .shellcheckrc
	@echo "==> Running ShellCheck..."
	@find . \( -name '*.sh' -o -name '*.bash' \) -not -path './.git/*' -print0 | xargs -0 shellcheck; \
		status=$$?; \
		rm -f .shellcheckrc; \
		exit $$status

test: ## Run BATS tests inside Docker
	@echo "==> Building test container..."
	@docker build -t dev-setup-test .
	@echo "==> Running tests..."
	@docker run --rm dev-setup-test bats --recursive tests/

setup: ## Run full setup
	@echo "==> Running setup..."
	@echo "TODO: add setup commands"

clean: ## Remove generated files and backups
	@rm -f .shellcheckrc
	@find . -name '*.bak' -o -name '*.orig' -o -name '*.log' | xargs rm -f
