#!/bin/bash
# run-basic-tests.sh - run-basic-tests.sh - Basic test script for ShellGuard in Docker
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
# run-basic-tests.sh - Basic test script for ShellGuard in Docker
#
# Basic test script for ShellGuard in Docker

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to run a test
run_test() {
    local test_name="$1"
    local command="$2"
    local expected_status=${3:-0}  # Default to expecting success (exit code 0)
    
    echo -e "${YELLOW}▶ Running test: ${test_name}${NC}"
    
    # Run the command and capture output and status
    local output
    local status
    
    # Use eval to properly handle the command string
    output=$(eval "$command" 2>&1)
    status=$?
    
    # Check if the command succeeded or failed as expected
    if [ $status -eq $expected_status ]; then
        echo -e "  ${GREEN}✓ PASSED: ${test_name}${NC}"
        return 0
    else
        echo -e "  ${RED}✗ FAILED: ${test_name}${NC}"
        echo -e "  Command: ${command}"
        echo -e "  Exit status: ${status} (expected ${expected_status})"
        if [ -n "$output" ]; then
            echo -e "  Output:\n${output}"
        fi
        return 1
    fi
}

# Main test execution
echo -e "${YELLOW}🚀 Starting ShellGuard Test Suite${NC}"
echo -e "${YELLOW}================================${NC}\n"

# Ensure Docker containers are running
if ! docker-compose -f docker/docker-compose.yml ps | grep -q "Up"; then
    echo -e "${YELLOW}Starting Docker containers...${NC}"
    docker-compose -f docker/docker-compose.yml up -d
    # Give containers time to start
    sleep 10
fi

# Test 1: Verify ShellGuard is loaded
run_test "ShellGuard is loaded in dev container" \
    "docker-compose -f docker/docker-compose.yml exec -T dev bash -c 'type shellguard >/dev/null 2>&1'"

# Test 2: Verify basic commands work
run_test "'shellguard status' command works" \
    "docker-compose -f docker/docker-compose.yml exec -T dev bash -c 'source /usr/local/bin/shellguard.sh && shellguard status'"

# Test 3: Verify dangerous command blocking
output=$(docker-compose -f docker/docker-compose.yml exec -T dev bash -c 'source /usr/local/bin/shellguard.sh && rm -rf /tmp/important 2>&1 || echo "BLOCKED"')
if [[ "$output" == *"BLOCKED"* ]]; then
    echo -e "  ${GREEN}✓ PASSED: Dangerous commands are blocked${NC}"
else
    echo -e "  ${RED}✗ FAILED: Dangerous command was not blocked${NC}"
    echo -e "  Command: rm -rf /tmp/important"
    echo -e "  Output: ${output}"
    exit 1
fi

# Test 4: Verify safe commands work
run_test "Safe commands are allowed" \
    "docker-compose -f docker/docker-compose.yml exec -T dev bash -c 'source /usr/local/bin/shellguard.sh && ls -la /tmp'"

# Test 5: Verify ShellGuard environment variables are set
run_test "ShellGuard environment variables are set" \
    "docker-compose -f docker/docker-compose.yml exec -T dev bash -c 'source /usr/local/bin/shellguard.sh && [ -n "\$SHELLGUARD_STRICT_MODE" ] && [ -n "\$SHELLGUARD_AUTO_BACKUP" ]'"

echo -e "\n${YELLOW}================================${NC}"
echo -e "${GREEN}✅ All basic tests completed successfully!${NC}"
echo -e "${YELLOW}================================${NC}\n"

exit 0
