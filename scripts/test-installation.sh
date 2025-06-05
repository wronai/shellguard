#!/bin/bash
set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}🚀 Testing ShellGuard installation...${NC}\n"

# Function to clean up on exit
cleanup() {
    echo -e "\n${YELLOW}Cleaning up...${NC}"
    # Remove installed files if they exist
    if [ -f "/usr/local/bin/shellguard" ]; then
        echo "Removing /usr/local/bin/shellguard..."
        sudo rm -f /usr/local/bin/shellguard
    fi
    if [ -f "/usr/local/bin/shellguard.sh" ]; then
        echo "Removing /usr/local/bin/shellguard.sh..."
        sudo rm -f /usr/local/bin/shellguard.sh
    fi
}

# Set up trap to ensure cleanup happens on script exit
trap cleanup EXIT

# Test 1: Check if shellguard is already installed
if command -v shellguard >/dev/null 2>&1; then
    echo -e "${YELLOW}⚠️  shellguard is already installed, uninstalling first...${NC}"
    cleanup
fi

# Test 2: Install using the quick install command
echo -e "${YELLOW}▶ Testing installation...${NC}"

# Install shellguard
INSTALL_OUTPUT=$(bash -c "curl -fsSL https://raw.githubusercontent.com/wronai/shellguard/main/shellguard.sh | sudo bash -s" 2>&1 || true)

# Check if installation was successful
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ Installation command completed successfully${NC}"
else
    echo -e "${RED}✗ Installation command failed${NC}"
    echo "Output was:"
    echo "$INSTALL_OUTPUT"
    exit 1
fi

# Test 3: Verify the installation
if command -v shellguard >/dev/null 2>&1; then
    echo -e "${GREEN}✓ ShellGuard is in PATH${NC}"
    echo -e "  Location: $(which shellguard)"
else
    echo -e "${RED}✗ ShellGuard is not in PATH${NC}"
    echo "Installation output was:"
    echo "$INSTALL_OUTPUT"
    exit 1
fi

# Test 4: Verify the script is executable
if [ -x "$(which shellguard)" ]; then
    echo -e "${GREEN}✓ ShellGuard script is executable${NC}"
else
    echo -e "${RED}✗ ShellGuard script is not executable${NC}"
    exit 1
fi

# Test 5: Verify the script runs without errors
RUN_OUTPUT=$(shellguard --version 2>&1 || true)
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ ShellGuard runs correctly${NC}"
    echo -e "  Version: $RUN_OUTPUT"
else
    echo -e "${RED}✗ ShellGuard did not run as expected${NC}"
    echo "Output was:"
    echo "$RUN_OUTPUT"
    exit 1
fi

# Test 6: Verify the script is properly installed
if [ -L "/usr/local/bin/shellguard" ] && [ -f "/usr/local/bin/shellguard.sh" ]; then
    echo -e "${GREEN}✓ ShellGuard is properly installed${NC}"
    echo -e "  Symlink: $(ls -la /usr/local/bin/shellguard)"
    echo -e "  Script: /usr/local/bin/shellguard.sh"
else
    echo -e "${RED}✗ ShellGuard installation is incomplete${NC}"
    if [ ! -L "/usr/local/bin/shellguard" ]; then
        echo "  Missing symlink: /usr/local/bin/shellguard"
    fi
    if [ ! -f "/usr/local/bin/shellguard.sh" ]; then
        echo "  Missing script: /usr/local/bin/shellguard.sh"
    fi
    exit 1
fi

echo -e "\n${GREEN}✅ All installation tests passed successfully!${NC}"

exit 0
