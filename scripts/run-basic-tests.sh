#!/bin/bash
# Basic test script for ShellGuard in Docker

set -e

echo "🚀 Starting basic ShellGuard tests..."

# Test 1: Verify ShellGuard is loaded
if ! docker-compose -f docker/docker-compose.yml exec -T dev bash -c 'type shellguard >/dev/null 2>&1'; then
    echo "❌ Test 1 Failed: ShellGuard not loaded in dev container"
    exit 1
else
    echo "✅ Test 1 Passed: ShellGuard is loaded in dev container"
fi

# Test 2: Verify basic commands work
if ! docker-compose -f docker/docker-compose.yml exec -T dev bash -c 'shellguard status'; then
    echo "❌ Test 2 Failed: 'shellguard status' command failed"
    exit 1
else
    echo "✅ Test 2 Passed: 'shellguard status' works"
fi

# Test 3: Verify dangerous command blocking
output=$(docker-compose -f docker/docker-compose.yml exec -T dev bash -c 'rm -rf /tmp/important 2>&1 || echo "BLOCKED"')
if [[ "$output" != *"BLOCKED"* ]]; then
    echo "❌ Test 3 Failed: Dangerous command was not blocked"
    exit 1
else
    echo "✅ Test 3 Passed: Dangerous commands are blocked"
fi

echo "🎉 All basic tests passed successfully!"
exit 0
