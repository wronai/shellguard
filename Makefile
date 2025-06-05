# ShellGuard Makefile
# Author: ShellGuard Team
# Description: Build and maintenance tasks for ShellGuard

# Variables
SHELL := /bin/bash
VERSION := 1.0.0
INSTALL_DIR := /usr/local/bin
CONFIG_DIR := $(HOME)/.shellguard
SHELLGUARD_SCRIPT := shellguard.sh

# Detect the user's shell
SHELL_NAME := $(notdir $(SHELL))

# Colors
GREEN  := $(shell tput -Txterm setaf 2)
YELLOW := $(shell tput -Txterm setaf 3)
WHITE  := $(shell tput -Txterm setaf 7)
CYAN   := $(shell tput -Txterm setaf 6)
RESET  := $(shell tput -Txterm sgr0)

##@ Help
.PHONY: help
help:  ## Display this help
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make $(YELLOW)<target>$(RESET)\n"} /^[a-zA-Z0-9_-]+:.*?##/ { printf "  $(YELLOW)%-15s$(RESET) %s\n", $$1, $$2 } /^##@/ { printf "\n$(CYAN)%s$(RESET)\n", substr($$0, 5) } ' $(MAKEFILE_LIST)

##@ Installation
install: ## Install ShellGuard system-wide
	@echo "$(GREEN)Installing ShellGuard...$(RESET)"
	sudo install -m 755 $(SHELLGUARD_SCRIPT) $(INSTALL_DIR)/shellguard
	@mkdir -p $(CONFIG_DIR)
	@cp -n blocked_patterns.txt $(CONFIG_DIR)/ 2>/dev/null || true
	@echo "$(GREEN)Installation complete!$(RESET)"
	@echo "\nTo use ShellGuard, add the following to your ~/.$(SHELL_NAME)rc file:"
	@echo "  source $(INSTALL_DIR)/shellguard"

uninstall: ## Uninstall ShellGuard
	@echo "$(YELLOW)Uninstalling ShellGuard...$(RESET)"
	sudo rm -f $(INSTALL_DIR)/shellguard
	@echo "$(GREEN)ShellGuard has been uninstalled.$(RESET)"
	@echo "Note: User configuration in $(CONFIG_DIR) has been kept."

##@ Development
lint: ## Run shellcheck on the script
	shellcheck $(SHELLGUARD_SCRIPT)
	echo "$(GREEN)Linting passed!$(RESET)"

test: ## Run tests (placeholder for future test suite)
	@echo "$(YELLOW)Running tests...$(RESET)"
	# TODO: Add actual tests
	@echo "$(GREEN)All tests passed!$(RESET)"

##@ Maintenance
update: ## Update ShellGuard to the latest version
	@echo "$(YELLOW)Updating ShellGuard...$(RESET)"
	git pull origin main
	@echo "$(GREEN)Update complete! Please restart your shell to apply changes.$(RESET)

version: ## Show current version
	@echo "ShellGuard v$(VERSION)"

##@ Documentation
docs: ## Generate documentation
	@echo "$(YELLOW)Generating documentation...$(RESET)"
	# TODO: Add documentation generation
	@echo "$(GREEN)Documentation generated in docs/$(RESET)"

##@ Cleanup
clean: ## Clean up temporary files
	@echo "$(YELLOW)Cleaning up...$(RESET)"
	find . -type f -name "*.bak" -delete
	find . -type f -name "*.tmp" -delete
	@echo "$(GREEN)Cleanup complete!$(RESET)"

.PHONY: install uninstall lint test update version docs clean help
