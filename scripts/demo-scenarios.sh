#!/bin/bash
# demo-scenarios.sh - Auto-loading ShellGuard version

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo "🎭 ShellGuard Demo Scenarios - Auto-Loading Version"
echo "=================================================="

# Auto-load ShellGuard if not active
check_and_load_shellguard() {
    if ! command -v status >/dev/null 2>&1; then
        echo -e "${YELLOW}🔄 ShellGuard not detected, attempting to load...${NC}"

        # Try to find shellguard.sh in common locations
        SHELLGUARD_LOCATIONS=(
            "./shellguard.sh"
            "../shellguard.sh"
            "$HOME/shellguard.sh"
            "$HOME/.shellguard.sh"
        )

        SHELLGUARD_FOUND=false
        for location in "${SHELLGUARD_LOCATIONS[@]}"; do
            if [[ -f "$location" ]]; then
                echo -e "${BLUE}📄 Found ShellGuard at: $location${NC}"
                source "$location"
                SHELLGUARD_FOUND=true
                break
            fi
        done

        if [[ "$SHELLGUARD_FOUND" = false ]]; then
            echo -e "${RED}❌ ShellGuard not found in common locations!${NC}"
            echo -e "${YELLOW}Please ensure shellguard.sh is in one of these locations:${NC}"
            for location in "${SHELLGUARD_LOCATIONS[@]}"; do
                echo -e "  ${BLUE}•${NC} $location"
            done
            echo ""
            echo -e "${YELLOW}Or run manually:${NC}"
            echo -e "  ${GREEN}source shellguard.sh${NC}"
            echo -e "  ${GREEN}source scripts/demo-scenarios.sh${NC}"
            exit 1
        fi

        # Verify ShellGuard is now active
        if ! command -v status >/dev/null 2>&1; then
            echo -e "${RED}❌ Failed to load ShellGuard!${NC}"
            exit 1
        fi
    fi

    echo -e "${GREEN}✅ ShellGuard is active and ready${NC}"
}

# Pause function for better demo flow
demo_pause() {
    echo -e "${BLUE}[Press Enter to continue...]${NC}"
    read -r
}

# Header for each scenario
scenario_header() {
    echo -e "\n" + "="*60
    echo -e "${BLUE}$1${NC}"
    echo "="*60
}

# Load ShellGuard
check_and_load_shellguard

# Create demo workspace
DEMO_DIR="shellguard_demo_$(date +%Y%m%d_%H%M%S)"
mkdir -p "$DEMO_DIR"
cd "$DEMO_DIR" || exit 1

echo -e "${GREEN}📁 Created demo workspace: $DEMO_DIR${NC}"
demo_pause

# Scenario 1: AI Assistant Safe Workflow
scenario_header "📚 Scenario 1: AI Assistant Safe Workflow"

echo -e "${YELLOW}🤖 AI: Checking project status...${NC}"
status
demo_pause

echo -e "${YELLOW}🤖 AI: Creating a Python calculator...${NC}"
cat > calculator.py << 'EOF'
def add(a, b):
    """Add two numbers safely"""
    return a + b

def multiply(a, b):
    """Multiply two numbers safely"""
    return a * b

if __name__ == "__main__":
    print("Calculator ready!")
    print("2 + 3 =", add(2, 3))
    print("4 * 5 =", multiply(4, 5))
EOF

echo -e "${GREEN}✅ Calculator created${NC}"
demo_pause

echo -e "${YELLOW}🤖 AI: Testing the calculator...${NC}"
if command -v python3 >/dev/null 2>&1; then
    python3 calculator.py
elif command -v python >/dev/null 2>&1; then
    python calculator.py
else
    echo -e "${YELLOW}⚠️ Python not found, showing code instead:${NC}"
    cat calculator.py
fi
demo_pause

echo -e "${YELLOW}🤖 AI: Running health check...${NC}"
health
demo_pause

# Scenario 2: Dangerous Command Prevention
scenario_header "📚 Scenario 2: Dangerous Command Prevention"

echo -e "${YELLOW}🤖 AI: Trying to clean up files...${NC}"
echo -e "${RED}Attempting: rm -rf /tmp/demo_test${NC}"

# Create test directory first
mkdir -p /tmp/demo_test
echo "test file" > /tmp/demo_test/test.txt

# This should be blocked by ShellGuard
echo -e "${BLUE}Command output:${NC}"
if rm -rf /tmp/demo_test 2>&1; then
    echo -e "${RED}❌ Command executed (ShellGuard may not be working)${NC}"
else
    echo -e "${GREEN}🛡️ Command was blocked by ShellGuard${NC}"
fi
demo_pause

echo -e "${YELLOW}🤖 AI: Using safe alternative...${NC}"
mkdir -p /tmp/demo_test_safe
echo "test content" > /tmp/demo_test_safe/test.txt

echo -e "${BLUE}Using safe_rm instead...${NC}"
if command -v safe_rm >/dev/null 2>&1; then
    safe_rm /tmp/demo_test_safe/test.txt
    echo -e "${GREEN}✅ Safe deletion completed${NC}"
else
    echo -e "${YELLOW}⚠️ safe_rm not available, demonstrating concept${NC}"
    echo -e "${BLUE}Would create backup then delete safely${NC}"
    rm -f /tmp/demo_test_safe/test.txt
fi
demo_pause

# Scenario 3: Python Security Scanning
scenario_header "📚 Scenario 3: Python Security Scanning"

echo -e "${YELLOW}🤖 AI: Creating a suspicious script...${NC}"
cat > suspicious.py << 'EOF'
import os
import subprocess

# This looks innocent but is dangerous
os.system("echo This could be malicious")
subprocess.call("ls -la", shell=True)
print("Script completed")
EOF

echo -e "${GREEN}✅ Suspicious script created${NC}"
echo -e "${BLUE}Script contents:${NC}"
cat suspicious.py
demo_pause

echo -e "${YELLOW}🤖 AI: Trying to run suspicious script...${NC}"
echo -e "${RED}Attempting: python suspicious.py${NC}"

echo -e "${BLUE}Command output:${NC}"
if command -v python3 >/dev/null 2>&1; then
    python3 suspicious.py 2>&1 || echo -e "${GREEN}🛡️ Script blocked by security scanner${NC}"
elif command -v python >/dev/null 2>&1; then
    python suspicious.py 2>&1 || echo -e "${GREEN}🛡️ Script blocked by security scanner${NC}"
else
    echo -e "${YELLOW}⚠️ Python not found, but ShellGuard would block this script${NC}"
fi
demo_pause

echo -e "${YELLOW}🤖 AI: Using force override with caution...${NC}"
if command -v force_python >/dev/null 2>&1; then
    echo -e "${YELLOW}⚠️ Using force_python (with backup)${NC}"
    force_python suspicious.py
else
    echo -e "${YELLOW}⚠️ force_python would allow execution with backup${NC}"
fi

# Clean up suspicious script
rm -f suspicious.py
demo_pause

# Scenario 4: Backup and Recovery
scenario_header "📚 Scenario 4: Backup and Recovery"

echo -e "${YELLOW}🤖 AI: Creating some important files...${NC}"
mkdir -p project
echo "Important data v1" > project/data.txt
echo "Config settings" > project/config.json
echo -e "${GREEN}✅ Files created:${NC}"
ls -la project/
demo_pause

echo -e "${YELLOW}🤖 AI: Creating backup before changes...${NC}"
if command -v backup >/dev/null 2>&1; then
    backup
else
    echo -e "${YELLOW}⚠️ Creating manual backup...${NC}"
    cp -r project project_backup
    echo -e "${GREEN}✅ Manual backup created${NC}"
fi
demo_pause

echo -e "${YELLOW}🤖 AI: Making risky changes...${NC}"
echo "Potentially bad changes" > project/data.txt
rm -f project/config.json
echo -e "${RED}❌ Files modified/deleted:${NC}"
ls -la project/
echo -e "${RED}Current data.txt content:${NC}"
cat project/data.txt
demo_pause

echo -e "${YELLOW}🤖 AI: Oh no! Something went wrong...${NC}"
echo -e "${YELLOW}🤖 AI: Rolling back to safety...${NC}"

if command -v rollback >/dev/null 2>&1; then
    rollback
else
    echo -e "${YELLOW}⚠️ Using manual rollback...${NC}"
    if [[ -d project_backup ]]; then
        rm -rf project
        mv project_backup project
        echo -e "${GREEN}✅ Manual rollback completed${NC}"
    else
        echo -e "${RED}❌ No backup found for rollback${NC}"
    fi
fi
demo_pause

echo -e "${YELLOW}🤖 AI: Checking if files were restored...${NC}"
if [[ -d project ]]; then
    ls -la project/
    if [[ -f project/data.txt ]]; then
        echo -e "${BLUE}Restored data.txt content:${NC}"
        cat project/data.txt
    fi
    if [[ -f project/config.json ]]; then
        echo -e "${GREEN}✅ config.json was restored${NC}"
    else
        echo -e "${YELLOW}⚠️ config.json not restored (expected in manual demo)${NC}"
    fi
else
    echo -e "${RED}❌ Project directory not found${NC}"
fi

# Final demo summary
scenario_header "🎉 Demo Summary"

echo -e "${GREEN}✅ Demo scenarios completed!${NC}"
echo ""
echo "📊 What we demonstrated:"
echo -e "  ${GREEN}✅${NC} Safe AI workflow with status checks"
echo -e "  ${GREEN}✅${NC} Dangerous command prevention (rm -rf)"
echo -e "  ${GREEN}✅${NC} Python security scanning for malicious code"
echo -e "  ${GREEN}✅${NC} Backup and recovery capabilities"
echo ""
echo -e "${BLUE}🛡️ ShellGuard protected against:${NC}"
echo -e "  ${RED}•${NC} Recursive file deletion"
echo -e "  ${RED}•${NC} Malicious Python scripts"
echo -e "  ${RED}•${NC} System command injection"
echo -e "  ${RED}•${NC} Unsafe shell operations"
echo ""
echo -e "${YELLOW}📁 Demo workspace: $PWD${NC}"
echo -e "${YELLOW}🗑️ Clean up with: cd .. && rm -rf $DEMO_DIR${NC}"

# Return to original directory
cd ..

echo ""
echo -e "${GREEN}🎯 All scenarios show how ShellGuard protects against common AI mistakes!${NC}"