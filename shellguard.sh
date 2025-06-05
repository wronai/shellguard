#!/bin/bash
# shellguard.sh - shellguard.sh - shellguard.sh - Your shell's bodyguard - because prevention is better than recovery
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
# shellguard.sh - shellguard.sh - Your shell's bodyguard - because prevention is better than recovery
#
# shellguard.sh - Your shell's bodyguard - because prevention is better than recovery
#

# ========================================
# PERFORMANCE CONFIGURATION
# ========================================
MAX_FIND_DEPTH=2
MAX_FILES_TO_CHECK=20
SCAN_TIMEOUT=3
MAX_MONITOR_FILES=1000

# ========================================
# COLORS AND ICONS
# ========================================
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# ========================================
# SYSTEM STATE
# ========================================
LLM_GUARD_DIR="$HOME/.llm_guard"
STATE_FILE="$LLM_GUARD_DIR/state.json"
BACKUP_DIR="$LLM_GUARD_DIR/backups"
BLOCKED_PATTERNS_FILE="$LLM_GUARD_DIR/blocked.txt"

# ========================================
# SAFE INITIALIZATION
# ========================================
init_llm_guard() {
    # Create directories safely
    mkdir -p "$LLM_GUARD_DIR" "$BACKUP_DIR" 2>/dev/null || true

    # Check if we have jq, if not - use simpler version
    if ! command -v jq >/dev/null 2>&1; then
        # Simple state file without jq
        cat > "$STATE_FILE" << 'EOF'
{"health_score": 100, "commands_blocked": 0, "last_backup": "", "session_start": ""}
EOF
    else
        # Normal state file with jq
        if [[ ! -f "$STATE_FILE" ]]; then
            cat > "$STATE_FILE" << 'EOF'
{
  "health_score": 100,
  "last_backup": "",
  "commands_blocked": 0,
  "files_changed": 0,
  "session_start": "",
  "warnings": []
}
EOF
        fi

        # Save session start time
        jq --arg time "$(date -Iseconds)" '.session_start = $time' "$STATE_FILE" > /tmp/sg_tmp.json && mv /tmp/sg_tmp.json "$STATE_FILE" 2>/dev/null || true
    fi

    # Create blocked patterns if doesn't exist
    if [[ ! -f "$BLOCKED_PATTERNS_FILE" ]]; then
        cat > "$BLOCKED_PATTERNS_FILE" << 'EOF'
rm -rf
sudo rm
DROP TABLE
DELETE FROM
os.system(
eval(
exec(
subprocess.call(.*shell=True
--force
--hard
/dev/
mkfs
fdisk
format
EOF
    fi

    echo -e "${GREEN}🛡️  LLM Guard activated!${NC}"
    echo -e "${BLUE}📊 Use 'status' to check system health${NC}"
    echo -e "${BLUE}🔒 Use 'backup' before big changes${NC}"
    echo -e "${BLUE}🔄 Use 'rollback' if something breaks${NC}"
}

# ========================================
# SECURITY CHECKING
# ========================================
check_dangerous_command() {
    local cmd="$1"

    while IFS= read -r pattern; do
        [[ -z "$pattern" ]] && continue
        if [[ "$cmd" == *"$pattern"* ]]; then
            echo -e "${RED}🚨 BLOCKED: Dangerous pattern detected: $pattern${NC}"
            echo -e "${RED}💀 Command: $cmd${NC}"

            # Increase blocked commands counter (simple version)
            if command -v jq >/dev/null 2>&1; then
                local blocked=$(jq -r '.commands_blocked // 0' "$STATE_FILE" 2>/dev/null || echo "0")
                jq --argjson blocked "$((blocked + 1))" '.commands_blocked = $blocked' "$STATE_FILE" > /tmp/sg_tmp.json && mv /tmp/sg_tmp.json "$STATE_FILE" 2>/dev/null || true
            fi

            return 1
        fi
    done < "$BLOCKED_PATTERNS_FILE"

    return 0
}

# ========================================
# IMPROVED PROJECT HEALTH CHECK
# ========================================
check_project_health() {
    echo -e "${BLUE}🔍 Checking project health (smart scan)...${NC}"

    local issues=0
    local health_score=100
    local files_checked=0

    # Check current directory file count to adjust scanning
    local total_files=$(find . -maxdepth $MAX_FIND_DEPTH -type f 2>/dev/null | wc -l)
    local scan_limit=$MAX_FILES_TO_CHECK

    if [[ $total_files -gt $MAX_MONITOR_FILES ]]; then
        echo -e "${YELLOW}⚠️  Large project detected ($total_files files), using limited scan${NC}"
        scan_limit=10
    fi

    # Check Python syntax - LIMITED SCANNING
    local python_files=$(find . -maxdepth $MAX_FIND_DEPTH -name "*.py" -type f 2>/dev/null | head -$scan_limit)
    if [[ -n "$python_files" ]]; then
        echo -e "${BLUE}🐍 Checking Python syntax ($scan_limit files max)...${NC}"

        while IFS= read -r file && [[ $files_checked -lt $scan_limit ]]; do
            [[ -z "$file" ]] && continue
            if ! timeout $SCAN_TIMEOUT python -m py_compile "$file" 2>/dev/null; then
                echo -e "${RED}❌ Syntax error in: $file${NC}"
                ((issues++))
                ((health_score -= 10))
            fi
            ((files_checked++))
        done <<< "$python_files"

        if [[ $files_checked -gt 0 ]]; then
            echo -e "${GREEN}✅ Checked $files_checked Python files${NC}"
        fi
    fi

    # Check JavaScript/Node - QUICK CHECK
    if [[ -f "package.json" ]]; then
        echo -e "${BLUE}📦 Checking Node.js project...${NC}"
        if timeout $SCAN_TIMEOUT node -e "JSON.parse(require('fs').readFileSync('package.json', 'utf8'))" 2>/dev/null; then
            echo -e "${GREEN}✅ Valid package.json${NC}"
        else
            echo -e "${RED}❌ Invalid package.json${NC}"
            ((issues++))
            ((health_score -= 15))
        fi
    fi

    # Check Git status - FAST
    if [[ -d ".git" ]]; then
        local changed_files=$(timeout $SCAN_TIMEOUT git status --porcelain 2>/dev/null | wc -l)
        if [[ $changed_files -gt 10 ]]; then
            echo -e "${YELLOW}⚠️  Many files changed: $changed_files${NC}"
            ((health_score -= 5))
        fi
    fi

    # Check error logs - LIMITED
    local error_logs=$(find . -maxdepth 2 -name "*.log" -type f 2>/dev/null | head -3)
    if [[ -n "$error_logs" ]] && [[ "$error_logs" != "" ]]; then
        if echo "$error_logs" | xargs timeout $SCAN_TIMEOUT grep -l "ERROR\|FATAL\|CRITICAL" 2>/dev/null | head -1 | grep -q .; then
            echo -e "${YELLOW}⚠️  Error logs found${NC}"
            ((health_score -= 5))
        fi
    fi

    # Save health score
    if command -v jq >/dev/null 2>&1; then
        jq --argjson score "$health_score" '.health_score = $score' "$STATE_FILE" > /tmp/sg_tmp.json && mv /tmp/sg_tmp.json "$STATE_FILE" 2>/dev/null || true
    fi

    # Summary
    if [[ $issues -eq 0 ]]; then
        echo -e "${GREEN}🎉 Project health: GOOD (Score: $health_score/100)${NC}"
        return 0
    else
        echo -e "${RED}🚨 Project health: ISSUES FOUND ($issues issues, Score: $health_score/100)${NC}"
        return 1
    fi
}

# ========================================
# IMPROVED STATUS DISPLAY
# ========================================
show_status() {
    echo -e "${BLUE}📊 LLM GUARD STATUS${NC}"
    echo "=================================="

    # Safe state reading with fallbacks
    local health_score=100
    local commands_blocked=0
    local last_backup=""
    local session_start=""

    if command -v jq >/dev/null 2>&1 && [[ -f "$STATE_FILE" ]]; then
        health_score=$(jq -r '.health_score // 100' "$STATE_FILE" 2>/dev/null || echo "100")
        commands_blocked=$(jq -r '.commands_blocked // 0' "$STATE_FILE" 2>/dev/null || echo "0")
        last_backup=$(jq -r '.last_backup // ""' "$STATE_FILE" 2>/dev/null || echo "")
        session_start=$(jq -r '.session_start // ""' "$STATE_FILE" 2>/dev/null || echo "")
    fi

    # Health score with colors
    if [[ $health_score -ge 80 ]]; then
        echo -e "Health Score: ${GREEN}$health_score/100${NC} ✅"
    elif [[ $health_score -ge 60 ]]; then
        echo -e "Health Score: ${YELLOW}$health_score/100${NC} ⚠️"
    else
        echo -e "Health Score: ${RED}$health_score/100${NC} 🚨"
    fi

    echo -e "Commands Blocked: ${RED}$commands_blocked${NC}"
    echo -e "Last Backup: ${BLUE}$last_backup${NC}"
    echo -e "Session Started: ${BLUE}$session_start${NC}"

    # QUICK check for dangerous files - current directory only
    local dangerous_count=$(find . -maxdepth 1 -name "*.py" -type f -exec grep -l "os\.system\|eval(\|exec(" {} \; 2>/dev/null | wc -l)
    if [[ $dangerous_count -gt 0 ]]; then
        echo -e "${RED}🚨 WARNING: $dangerous_count files with dangerous patterns in current directory!${NC}"
    fi

    echo "=================================="
}

# ========================================
# QUICK CHECK FOR LLM
# ========================================
check() {
    echo -e "${BLUE}🔍 Quick health check...${NC}"

    local issues=0

    # Very quick check - only obvious problems
    if [[ -f "package.json" ]] && ! timeout 2 node -e "JSON.parse(require('fs').readFileSync('package.json', 'utf8'))" 2>/dev/null; then
        ((issues++))
    fi

    # Check git status
    if [[ -d ".git" ]]; then
        local changed=$(timeout 2 git status --porcelain 2>/dev/null | wc -l)
        if [[ $changed -gt 20 ]]; then
            ((issues++))
        fi
    fi

    # Check for obvious Python syntax errors in current directory
    if find . -maxdepth 1 -name "*.py" -type f | head -5 | xargs -I {} timeout 2 python -m py_compile {} 2>&1 | grep -q "SyntaxError"; then
        ((issues++))
    fi

    if [[ $issues -eq 0 ]]; then
        echo -e "${GREEN}✅ SYSTEM OK${NC}"
        return 0
    else
        echo -e "${RED}❌ ISSUES DETECTED${NC}"
        echo -e "${YELLOW}Run 'health' for details${NC}"
        return 1
    fi
}

# ========================================
# AUTO-BACKUP
# ========================================
create_backup() {
    local timestamp=$(date +"%Y%m%d_%H%M%S")
    local backup_name="backup_$timestamp"

    echo -e "${YELLOW}📦 Creating backup: $backup_name${NC}"

    # Git backup if it's a repo
    if [[ -d ".git" ]]; then
        git add . 2>/dev/null || true
        if git commit -m "LLM Guard auto-backup $timestamp" 2>/dev/null; then
            echo -e "${GREEN}✅ Git backup created${NC}"
        fi
    fi

    # File backup
    local backup_path="$BACKUP_DIR/$backup_name"
    mkdir -p "$backup_path" 2>/dev/null || true

    if command -v rsync >/dev/null 2>&1; then
        rsync -a --exclude='.git' --exclude='node_modules' --exclude='__pycache__' \
              --exclude='.llm_guard' . "$backup_path/" 2>/dev/null && \
        echo -e "${GREEN}✅ File backup created${NC}"
    else
        cp -r . "$backup_path/" 2>/dev/null && \
        echo -e "${GREEN}✅ File backup created${NC}"
    fi

    # Save backup info
    if command -v jq >/dev/null 2>&1; then
        jq --arg backup "$backup_name" '.last_backup = $backup' "$STATE_FILE" > /tmp/sg_tmp.json && mv /tmp/sg_tmp.json "$STATE_FILE" 2>/dev/null || true
    fi

    return 0
}

# ========================================
# ROLLBACK
# ========================================
rollback_changes() {
    echo -e "${YELLOW}🔄 Rolling back changes...${NC}"

    # Git rollback if possible
    if [[ -d ".git" ]] && git log --oneline -1 2>/dev/null | grep -q "LLM Guard auto-backup"; then
        if git reset --hard HEAD~1 2>/dev/null; then
            echo -e "${GREEN}✅ Git rollback completed${NC}"
            return 0
        fi
    fi

    # File rollback from latest backup
    local last_backup=""
    if command -v jq >/dev/null 2>&1; then
        last_backup=$(jq -r '.last_backup // ""' "$STATE_FILE" 2>/dev/null || echo "")
    fi

    if [[ -n "$last_backup" && -d "$BACKUP_DIR/$last_backup" ]]; then
        echo -e "${YELLOW}🔄 Restoring from backup: $last_backup${NC}"

        # Remove everything except hidden system files
        find . -maxdepth 1 -not -name '.*' -not -name '.git' -exec rm -rf {} + 2>/dev/null || true

        # Restore from backup
        if cp -r "$BACKUP_DIR/$last_backup/"* . 2>/dev/null; then
            echo -e "${GREEN}✅ Files restored from backup${NC}"
            return 0
        fi
    fi

    echo -e "${RED}❌ No backup found for rollback${NC}"
    return 1
}

# ========================================
# MONITORING
# ========================================
monitor_changes() {
    # Check only if it's git repo and only quick check
    if [[ -d ".git" ]]; then
        local changed=$(timeout 2 git status --porcelain 2>/dev/null | wc -l)
        if [[ $changed -gt 15 ]]; then
            echo -e "${YELLOW}⚠️  WARNING: $changed files changed! Consider backup.${NC}"
        fi
    fi
}

start_monitor() {
    # Start monitor with longer intervals for large projects
    local interval=60

    # If many files, increase interval
    local file_count=$(find . -maxdepth 2 -type f 2>/dev/null | wc -l)
    if [[ $file_count -gt $MAX_MONITOR_FILES ]]; then
        interval=300  # 5 minutes for large projects
    fi

    (
        while true; do
            sleep $interval
            monitor_changes 2>/dev/null || true
        done
    ) &
    MONITOR_PID=$!
    echo -e "${GREEN}🔍 Background monitor started (PID: $MONITOR_PID)${NC}"
}

stop_monitor() {
    if [[ -n "$MONITOR_PID" ]]; then
        kill $MONITOR_PID 2>/dev/null || true
        echo -e "${BLUE}🔍 Background monitor stopped${NC}"
    fi
}

# ========================================
# COMMAND OVERRIDES
# ========================================

# Override rm
rm() {
    local cmd="rm $*"
    if ! check_dangerous_command "$cmd"; then
        echo -e "${RED}Use 'safe_rm' if you really need to delete files${NC}"
        return 1
    fi
    command rm "$@"
}

# Override git with dangerous flags
git() {
    local cmd="git $*"
    if ! check_dangerous_command "$cmd"; then
        echo -e "${RED}Use 'force_git' if you really need this git command${NC}"
        return 1
    fi
    command git "$@"
}

# Override python for dangerous scripts
python() {
    local file="$1"
    if [[ -f "$file" ]]; then
        # Check if file contains dangerous patterns
        if timeout 2 grep -q "os\.system\|eval(\|exec(\|subprocess.*shell=True" "$file" 2>/dev/null; then
            echo -e "${RED}🚨 Dangerous Python code detected in: $file${NC}"
            echo -e "${YELLOW}Content preview:${NC}"
            grep -n "os\.system\|eval(\|exec(\|subprocess.*shell=True" "$file" 2>/dev/null | head -3
            echo -e "${RED}Use 'force_python $file' to run anyway${NC}"
            return 1
        fi
    fi
    command python "$@"
}

# Override npm/yarn
npm() {
    local cmd="npm $*"

    # Check if it's installing new packages
    if [[ "$1" == "install" && "$#" -gt 1 ]]; then
        echo -e "${YELLOW}🔍 Installing new packages: ${*:2}${NC}"
        echo -e "${BLUE}Creating backup before package installation...${NC}"
        create_backup
    fi

    command npm "$@"
}

# ========================================
# SAFE COMMANDS (bypass blocks)
# ========================================
safe_rm() {
    echo -e "${YELLOW}⚠️  Using SAFE RM - creating backup first${NC}"
    create_backup
    command rm "$@"
}

force_git() {
    echo -e "${YELLOW}⚠️  Using FORCE GIT - creating backup first${NC}"
    create_backup
    command git "$@"
}

force_python() {
    echo -e "${YELLOW}⚠️  Using FORCE PYTHON - proceed with caution${NC}"
    command python "$@"
}

# ========================================
# HELPER COMMANDS
# ========================================
backup() {
    create_backup
}

rollback() {
    rollback_changes
}

status() {
    show_status
}

health() {
    check_project_health
}

# Emergency reset
emergency() {
    echo -e "${RED}🚨 EMERGENCY MODE${NC}"
    echo -e "${YELLOW}This will rollback to last known good state${NC}"
    read -p "Continue? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        rollback_changes
    fi
}

# Add pattern to blocklist
block() {
    local pattern="$1"
    if [[ -n "$pattern" ]]; then
        echo "$pattern" >> "$BLOCKED_PATTERNS_FILE"
        echo -e "${GREEN}✅ Added pattern to blocklist: $pattern${NC}"
    else
        echo -e "${RED}Usage: block 'dangerous_pattern'${NC}"
    fi
}

# ========================================
# HELP
# ========================================
llm_help() {
    echo -e "${BLUE}🛡️  LLM GUARD COMMANDS${NC}"
    echo "=================================="
    echo -e "${GREEN}status${NC}     - Show system status"
    echo -e "${GREEN}health${NC}     - Check project health"
    echo -e "${GREEN}check${NC}      - Quick health check"
    echo -e "${GREEN}backup${NC}     - Create backup"
    echo -e "${GREEN}rollback${NC}   - Restore from backup"
    echo -e "${GREEN}emergency${NC}  - Emergency rollback"
    echo -e "${GREEN}block 'pattern'${NC} - Add dangerous pattern"
    echo ""
    echo -e "${YELLOW}SAFE COMMANDS (bypass blocks):${NC}"
    echo -e "${GREEN}safe_rm${NC}    - Safe delete with backup"
    echo -e "${GREEN}force_git${NC}  - Force git with backup"
    echo -e "${GREEN}force_python${NC} - Force Python execution"
    echo ""
    echo -e "${BLUE}EXAMPLES FOR LLM:${NC}"
    echo "  python myfile.py  # Checked automatically"
    echo "  npm install react # Auto-backup before install"
    echo "  git commit -m 'msg' # Safe git operations"
    echo "  rm -rf folder # BLOCKED! Use safe_rm instead"
}

# ========================================
# INITIALIZATION WHEN SOURCED
# ========================================
if [[ "${BASH_SOURCE[0]}" != "${0}" ]]; then
    # Script is being sourced
    init_llm_guard

    # Start monitor in background
    start_monitor

    # Trap on exit to stop monitor
    trap 'stop_monitor' EXIT

    echo -e "${GREEN}🎯 Type 'llm_help' for commands${NC}"
    echo -e "${BLUE}🚀 LLM can now use: python, npm, git (all monitored)${NC}"
    echo -e "${YELLOW}🔒 Dangerous commands are blocked automatically${NC}"
fi

# ========================================
# IF RUN AS SCRIPT
# ========================================
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    # Run as script - execute command
    case "$1" in
        "install")
            echo "Installing LLM Guard..."
            echo "Add this to your ~/.bashrc or ~/.zshrc:"
            echo "source $(realpath "$0")"
            ;;
        "status"|"health"|"check"|"backup"|"rollback"|"emergency")
            init_llm_guard >/dev/null 2>&1
            $1
            ;;
        *)
            echo "Usage: $0 {install|status|health|check|backup|rollback|emergency}"
            echo "Or: source $0  (to activate LLM Guard)"
            ;;
    esac
fi
