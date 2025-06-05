#!/bin/bash
# run-tests.sh - run-tests.sh - scripts/run-tests.sh
#
# Copyright (c) 2025 WRONAI - Tom Sapletta
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
# run-tests.sh - scripts/run-tests.sh
#
# scripts/run-tests.sh

set -e

echo "🐳 Starting ShellGuard Docker + Ansible Tests"
echo "=============================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Step 1: Build and start containers
echo -e "${BLUE}📦 Building Docker containers...${NC}"
docker-compose -f docker/docker-compose.yml build

echo -e "${BLUE}🚀 Starting containers...${NC}"
docker-compose -f docker/docker-compose.yml up -d

# Wait for containers to be ready
echo -e "${YELLOW}⏳ Waiting for containers to be ready...${NC}"
sleep 10

# Step 2: Setup ShellGuard via Ansible
echo -e "${BLUE}⚙️ Setting up ShellGuard with Ansible...${NC}"
docker-compose -f docker/docker-compose.yml exec ansible \
    ansible-playbook -i inventory/hosts.yml playbooks/setup-shellguard.yml

# Step 3: Verify environment
echo -e "${BLUE}🔍 Verifying environment...${NC}"
docker-compose -f docker/docker-compose.yml exec ansible \
    ansible-playbook -i inventory/hosts.yml playbooks/verify-environment.yml

# Step 4: Run ShellGuard tests
echo -e "${BLUE}🧪 Running ShellGuard tests...${NC}"
docker-compose -f docker/docker-compose.yml exec ansible \
    ansible-playbook -i inventory/hosts.yml playbooks/test-shellguard.yml

# Step 5: Interactive demo
echo -e "${YELLOW}🎪 Starting interactive demo...${NC}"
echo "You can now access the containers:"
echo "- Development: docker-compose -f docker/docker-compose.yml exec dev bash"
echo "- Testing: docker-compose -f docker/docker-compose.yml exec test bash"

# Keep containers running for manual testing
read -p "Press Enter to stop containers or Ctrl+C to keep them running..."

# Cleanup
echo -e "${BLUE}🧹 Cleaning up...${NC}"
docker-compose -f docker/docker-compose.yml down

echo -e "${GREEN}✅ Tests completed successfully!${NC}"
