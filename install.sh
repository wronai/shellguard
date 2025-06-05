
#!/bin/bash
# ShellGuard Universal Installer
# Usage: curl -fsSL https://shellguard.dev/install | bash

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Configuration
SHELLGUARD_URL="https://raw.githubusercontent.com/wronai/shellguard/main/shellguard.sh"
INSTALL_DIR="$HOME"
INSTALL_NAME="shellguard.sh"

echo -e "${BLUE}🛡️ ShellGuard Installer${NC}"
echo "======================="

# Detect install method from arguments
INSTALL_METHOD="temp"
DOCKER_MODE=false
PERMANENT=false
SYSTEM_WIDE=false

for arg in "$@"; do
    case $arg in
        --permanent) PERMANENT=true ;;
        --docker) DOCKER_MODE=true ;;
        --system) SYSTEM_WIDE=true ;;
        --temp) INSTALL_METHOD="temp" ;;
    esac
done

# Determine install location
if [[ "$SYSTEM_WIDE" == true ]]; then
    INSTALL_DIR="/usr/local/bin"
    INSTALL_NAME="shellguard"
elif [[ "$DOCKER_MODE" == true ]]; then
    INSTALL_DIR="/tmp"
elif [[ "$PERMANENT" == true ]]; then
    INSTALL_DIR="$HOME"
    INSTALL_NAME=".shellguard.sh"
fi

INSTALL_PATH="$INSTALL_DIR/$INSTALL_NAME"

echo -e "${YELLOW}📦 Downloading ShellGuard...${NC}"
if command -v curl >/dev/null 2>&1; then
    curl -fsSL "$SHELLGUARD_URL" -o "$INSTALL_PATH"
elif command -v wget >/dev/null 2>&1; then
    wget -q "$SHELLGUARD_URL" -O "$INSTALL_PATH"
else
    echo -e "${RED}❌ Neither curl nor wget found!${NC}"
    exit 1
fi

echo -e "${YELLOW}🔧 Setting permissions...${NC}"
chmod +x "$INSTALL_PATH"

echo -e "${YELLOW}⚡ Activating ShellGuard...${NC}"
source "$INSTALL_PATH"

# Add to shell profile if permanent
if [[ "$PERMANENT" == true || "$SYSTEM_WIDE" == true ]]; then
    SHELL_RC="$HOME/.bashrc"
    [[ "$SHELL" == *"zsh"* ]] && SHELL_RC="$HOME/.zshrc"

    if ! grep -q "shellguard" "$SHELL_RC" 2>/dev/null; then
        echo "source $INSTALL_PATH" >> "$SHELL_RC"
        echo -e "${GREEN}✅ Added to $SHELL_RC${NC}"
    fi
fi

echo -e "${GREEN}🎉 ShellGuard installation complete!${NC}"
echo -e "${BLUE}📊 Run 'status' to check system${NC}"
echo -e "${BLUE}🔍 Run 'health' to verify setup${NC}"
echo -e "${BLUE}❓ Run 'llm_help' for all commands${NC}"

# Auto-run status check
if command -v status >/dev/null 2>&1; then
    echo -e "\n${YELLOW}📊 Initial status check:${NC}"
    status
fi