#!/bin/bash
set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}🚀 Testing ShellGuard quick installation...${NC}
"

# Test 1: Install using the quick install command
echo -e "${YELLOW}▶ Testing quick installation...${NC}
"

# Create a temporary directory for testing
TEMP_DIR=$(mktemp -d)
echo -e "Created temporary directory: ${TEMP_DIR}"

# Create a test shellguard.sh file in the current directory for testing
cat > shellguard.sh << 'EOL'
#!/bin/bash
# Test ShellGuard script
echo "ShellGuard test script installed successfully!"
EOL

# Test the installation
INSTALL_OUTPUT=$(bash -c "curl -fsSL https://raw.githubusercontent.com/wronai/shellguard/main/shellguard.sh | bash -s -- --test" 2>&1 || true)

# Check if installation was successful
if echo "$INSTALL_OUTPUT" | grep -q "Installation test successful"; then
    echo -e "${GREEN}✓ Quick installation test passed${NC}"
else
    echo -e "${RED}✗ Quick installation test failed${NC}"
    echo "Output was:"
    echo "$INSTALL_OUTPUT"
    exit 1
fi

# Test 2: Verify the installation
if command -v shellguard >/dev/null 2>&1; then
    echo -e "${GREEN}✓ ShellGuard is in PATH${NC}"
    echo -e "  Location: $(which shellguard)"
else
    echo -e "${RED}✗ ShellGuard is not in PATH${NC}"
    exit 1
fi

# Test 3: Verify the script is executable
if [ -x "$(which shellguard)" ]; then
    echo -e "${GREEN}✓ ShellGuard script is executable${NC}"
else
    echo -e "${RED}✗ ShellGuard script is not executable${NC}"
    exit 1
fi

# Test 4: Run the installed command
RUN_OUTPUT=$($(which shellguard) 2>&1 || true)
if echo "$RUN_OUTPUT" | grep -q "ShellGuard test script installed successfully"; then
    echo -e "${GREEN}✓ ShellGuard runs correctly${NC}"
else
    echo -e "${RED}✗ ShellGuard did not run as expected${NC}"
    echo "Output was:"
    echo "$RUN_OUTPUT"
    exit 1
fi

# Cleanup
rm -rf "$TEMP_DIR"

echo -e "\n${GREEN}✅ All quick installation tests passed successfully!${NC}"
exit 0
