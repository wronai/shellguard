# ShellGuard Makefile
# Author: ShellGuard Team
# Description: Build and maintenance tasks for ShellGuard

# Variables
SHELL := /bin/bash
VERSION := 1.0.0
INSTALL_DIR := /usr/local/bin
CONFIG_DIR := $(HOME)/.shellguard
SHELLGUARD_SCRIPT := shellguard.sh
SCRIPTS_DIR := scripts
ANSIBLE_DIR := ansible
DOCKER_DIR := docker
TEST_DIR := tests

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
	@chmod +x $(SCRIPTS_DIR)/*.sh
	@echo "$(GREEN)Installation complete!$(RESET)"
	@echo "\nTo use ShellGuard, add the following to your ~/.$(SHELL_NAME)rc file:"
	@echo "  source $(INSTALL_DIR)/shellguard"

uninstall: ## Uninstall ShellGuard
	@echo "$(YELLOW)Uninstalling ShellGuard...$(RESET)"
	sudo rm -f $(INSTALL_DIR)/shellguard
	@echo "$(GREEN)ShellGuard has been uninstalled.$(RESET)"
	@echo "Note: User configuration in $(CONFIG_DIR) has been kept."

##@ Development
setup: ## Setup development environment
	@echo "$(YELLOW)Setting up development environment...$(RESET)"
	@./$(SCRIPTS_DIR)/setup-dev-env.sh

lint: ## Run linters
	@echo "$(YELLOW)Running linters...$(RESET)"
	shellcheck $(SHELLGUARD_SCRIPT) $(SCRIPTS_DIR)/*.sh
	test -f .pre-commit-config.yaml && pre-commit run --all-files || true
	@echo "$(GREEN)Linting passed!$(RESET)"

test: ## Run tests
	@echo "$(YELLOW)Running tests...$(RESET)"
	@./$(SCRIPTS_DIR)/run-tests.sh

coverage: ## Generate test coverage report
	@echo "$(YELLOW)Generating coverage report...$(RESET)"
	# TODO: Add coverage reporting

bdd: ## Run behavior-driven development tests
	@echo "$(YELLOW)Running BDD tests...$(RESET)"
	@./$(SCRIPTS_DIR)/demo-scenarios.sh

##@ Docker
docker-build: ## Build Docker images
	@echo "$(YELLOW)Building Docker images...$(RESET)"
	@./$(SCRIPTS_DIR)/docker-build-test.sh

docker-test: ## Run tests in Docker
	@docker-compose -f $(DOCKER_DIR)/docker-compose.yml run --rm test

docker-dev: ## Start development container
	@docker-compose -f $(DOCKER_DIR)/docker-compose.yml run --service-ports --rm dev

##@ Ansible
deploy: ## Deploy with Ansible
	@echo "$(YELLOW)Deploying with Ansible...$(RESET)"
	@./$(SCRIPTS_DIR)/deploy-with-ansible.sh

inventory: ## Show Ansible inventory
	@ansible-inventory -i $(ANSIBLE_DIR)/inventory/hosts.yml --list

##@ Maintenance
update: ## Update ShellGuard to the latest version
	@echo "$(YELLOW)Updating ShellGuard...$(RESET)"
	git pull origin main
	@echo "$(GREEN)Update complete! Please restart your shell to apply changes.$(RESET)

version: ## Show current version
	@echo "ShellGuard v$(VERSION)"

##@ Documentation
docs: ## Generate documentation
	@echo "$(YELLOW)Generating documentation...$(RESET)
	@mkdir -p docs
	@pandoc README.md -o docs/README.html
	@echo "Documentation generated in docs/$(RESET)"

scenarios: ## Generate test scenarios
	@echo "$(YELLOW)Generating test scenarios...$(RESET)"
	@./$(SCRIPTS_DIR)/generate-test-scenarios.sh
	@echo "Test scenarios generated in TEST.md"

##@ Cleanup
clean: ## Clean up temporary files
	@echo "$(YELLOW)Cleaning up...$(RESET)"
	find . -type f -name "*.bak" -delete
	find . -type f -name "*.tmp" -delete
	find . -type d -name "__pycache__" -exec rm -rf {} +
	rm -rf .pytest_cache/ .coverage htmlcov/
	@echo "$(GREEN)Cleanup complete!$(RESET)"

distclean: clean ## Deep clean (including Docker)
	@echo "$(YELLOW)Deep cleaning...$(RESET)"
	docker-compose -f $(DOCKER_DIR)/docker-compose.yml down -v --rmi all
	docker system prune -f
	@echo "$(GREEN)Deep clean complete!$(RESET)"

.PHONY: install uninstall lint test update version docs clean help
