#!/bin/bash
# shellguard.sh - Prosty shell kontrolujący LLM
# Użycie: source shellguard.sh (jeden raz na sesję)

# ========================================
# KOLORY I IKONKI
# ========================================
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# ========================================
# STAN SYSTEMU
# ========================================
LLM_GUARD_DIR="$HOME/.shellguard"
STATE_FILE="$LLM_GUARD_DIR/state.json"
BACKUP_DIR="$LLM_GUARD_DIR/backups"
BLOCKED_PATTERNS_FILE="$LLM_GUARD_DIR/blocked.txt"

# Utwórz katalogi jeśli nie istnieją
mkdir -p "$LLM_GUARD_DIR" "$BACKUP_DIR"

# ========================================
# INICJALIZACJA
# ========================================
init_shellguard() {
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

    # Zapisz czas rozpoczęcia sesji
    jq --arg time "$(date -Iseconds)" '.session_start = $time' "$STATE_FILE" > tmp.json && mv tmp.json "$STATE_FILE"

    echo -e "${GREEN}🛡️  LLM Guard activated!${NC}"
    echo -e "${BLUE}📊 Use 'status' to check system health${NC}"
    echo -e "${BLUE}🔒 Use 'backup' before big changes${NC}"
    echo -e "${BLUE}🔄 Use 'rollback' if something breaks${NC}"
}

# ========================================
# SPRAWDZANIE BEZPIECZEŃSTWA
# ========================================
check_dangerous_command() {
    local cmd="$1"

    while IFS= read -r pattern; do
        if [[ "$cmd" == *"$pattern"* ]]; then
            echo -e "${RED}🚨 BLOCKED: Dangerous pattern detected: $pattern${NC}"
            echo -e "${RED}💀 Command: $cmd${NC}"

            # Zwiększ licznik zablokowanych komend
            local blocked=$(jq -r '.commands_blocked' "$STATE_FILE")
            jq --argjson blocked "$((blocked + 1))" '.commands_blocked = $blocked' "$STATE_FILE" > tmp.json && mv tmp.json "$STATE_FILE"

            return 1
        fi
    done < "$BLOCKED_PATTERNS_FILE"

    return 0
}

# ========================================
# AUTO-BACKUP
# ========================================
create_backup() {
    local timestamp=$(date +"%Y%m%d_%H%M%S")
    local backup_name="backup_$timestamp"

    echo -e "${YELLOW}📦 Creating backup: $backup_name${NC}"

    # Git backup jeśli to repo
    if [[ -d ".git" ]]; then
        git add . 2>/dev/null
        git commit -m "LLM Guard auto-backup $timestamp" 2>/dev/null
        echo -e "${GREEN}✅ Git backup created${NC}"
    fi

    # File backup
    if command -v rsync >/dev/null 2>&1; then
        rsync -a --exclude='.git' --exclude='node_modules' --exclude='__pycache__' \
              . "$BACKUP_DIR/$backup_name/" 2>/dev/null
        echo -e "${GREEN}✅ File backup created in $BACKUP_DIR/$backup_name${NC}"
    else
        cp -r . "$BACKUP_DIR/$backup_name/" 2>/dev/null
        echo -e "${GREEN}✅ File backup created${NC}"
    fi

    # Zapisz info o backup
    jq --arg backup "$backup_name" '.last_backup = $backup' "$STATE_FILE" > tmp.json && mv tmp.json "$STATE_FILE"

    return 0
}

# ========================================
# ROLLBACK
# ========================================
rollback_changes() {
    echo -e "${YELLOW}🔄 Rolling back changes...${NC}"

    # Git rollback jeśli możliwe
    if [[ -d ".git" ]] && git log --oneline -1 | grep -q "LLM Guard auto-backup"; then
        git reset --hard HEAD~1 2>/dev/null
        echo -e "${GREEN}✅ Git rollback completed${NC}"
        return 0
    fi

    # File rollback z najnowszego backup
    local last_backup=$(jq -r '.last_backup' "$STATE_FILE")
    if [[ -n "$last_backup" && -d "$BACKUP_DIR/$last_backup" ]]; then
        echo -e "${YELLOW}🔄 Restoring from backup: $last_backup${NC}"

        # Usuń wszystko oprócz ukrytych plików systemu
        find . -maxdepth 1 -not -name '.*' -not -name '.git' -exec rm -rf {} + 2>/dev/null

        # Przywróć z backup
        cp -r "$BACKUP_DIR/$last_backup/"* . 2>/dev/null
        echo -e "${GREEN}✅ Files restored from backup${NC}"
        return 0
    fi

    echo -e "${RED}❌ No backup found for rollback${NC}"
    return 1
}

# ========================================
# SPRAWDZENIE STANU
# ========================================
check_project_health() {
    echo -e "${BLUE}🔍 Checking project health...${NC}"

    local issues=0
    local health_score=100

    # Sprawdź składnię Python
    if find . -name "*.py" -type f | head -1 | grep -q .; then
        echo -e "${BLUE}🐍 Checking Python syntax...${NC}"
        while IFS= read -r -d '' file; do
            if ! python -m py_compile "$file" 2>/dev/null; then
                echo -e "${RED}❌ Syntax error in: $file${NC}"
                ((issues++))
                ((health_score -= 10))
            fi
        done < <(find . -name "*.py" -type f -print0)
    fi

    # Sprawdź JavaScript/Node
    if [[ -f "package.json" ]]; then
        echo -e "${BLUE}📦 Checking Node.js project...${NC}"
        if ! node -c package.json 2>/dev/null; then
            echo -e "${RED}❌ Invalid package.json${NC}"
            ((issues++))
            ((health_score -= 15))
        fi
    fi

    # Sprawdź Git status
    if [[ -d ".git" ]]; then
        local changed_files=$(git status --porcelain 2>/dev/null | wc -l)
        if [[ $changed_files -gt 10 ]]; then
            echo -e "${YELLOW}⚠️  Many files changed: $changed_files${NC}"
            ((health_score -= 5))
        fi
    fi

    # Sprawdź logi błędów
    if find . -name "*.log" -exec grep -l "ERROR\|FATAL\|CRITICAL" {} \; | head -1 | grep -q .; then
        echo -e "${YELLOW}⚠️  Error logs found${NC}"
        ((health_score -= 5))
    fi

    # Zapisz health score
    jq --argjson score "$health_score" '.health_score = $score' "$STATE_FILE" > tmp.json && mv tmp.json "$STATE_FILE"

    # Podsumowanie
    if [[ $issues -eq 0 ]]; then
        echo -e "${GREEN}🎉 Project health: GOOD (Score: $health_score/100)${NC}"
        return 0
    else
        echo -e "${RED}🚨 Project health: ISSUES FOUND ($issues issues, Score: $health_score/100)${NC}"
        return 1
    fi
}

# ========================================
# STATUS SYSTEMU
# ========================================
show_status() {
    echo -e "${BLUE}📊 LLM GUARD STATUS${NC}"
    echo "=================================="

    local health_score=$(jq -r '.health_score' "$STATE_FILE")
    local commands_blocked=$(jq -r '.commands_blocked' "$STATE_FILE")
    local last_backup=$(jq -r '.last_backup' "$STATE_FILE")
    local session_start=$(jq -r '.session_start' "$STATE_FILE")

    # Health score z kolorami
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

    # Sprawdź czy są niebezpieczne pliki
    if find . -name "*.py" -exec grep -l "os.system\|eval(\|exec(" {} \; | head -1 | grep -q .; then
        echo -e "${RED}🚨 WARNING: Dangerous code patterns detected!${NC}"
    fi

    echo "=================================="
}

# ========================================
# OVERRIDE KOMEND SYSTEMOWYCH
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

# Override git z niebezpiecznymi flagami
git() {
    local cmd="git $*"
    if ! check_dangerous_command "$cmd"; then
        echo -e "${RED}Use 'force_git' if you really need this git command${NC}"
        return 1
    fi
    command git "$@"
}

# Override python dla niebezpiecznych skryptów
python() {
    local file="$1"
    if [[ -f "$file" ]]; then
        # Sprawdź czy plik zawiera niebezpieczne wzorce
        if grep -q "os.system\|eval(\|exec(\|subprocess.*shell=True" "$file" 2>/dev/null; then
            echo -e "${RED}🚨 Dangerous Python code detected in: $file${NC}"
            echo -e "${YELLOW}Content preview:${NC}"
            grep -n "os.system\|eval(\|exec(\|subprocess.*shell=True" "$file" | head -5
            echo -e "${RED}Use 'force_python $file' to run anyway${NC}"
            return 1
        fi
    fi
    command python "$@"
}

# Override npm/yarn
npm() {
    local cmd="npm $*"

    # Sprawdź czy to install nowych pakietów
    if [[ "$1" == "install" && "$#" -gt 1 ]]; then
        echo -e "${YELLOW}🔍 Installing new packages: ${*:2}${NC}"
        echo -e "${BLUE}Creating backup before package installation...${NC}"
        create_backup
    fi

    command npm "$@"
}

# ========================================
# SAFE COMMANDS (omijają blokady)
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

# Quick check dla LLM
check() {
    echo -e "${BLUE}🔍 Quick health check...${NC}"
    if check_project_health >/dev/null 2>&1; then
        echo -e "${GREEN}✅ SYSTEM OK${NC}"
        return 0
    else
        echo -e "${RED}❌ ISSUES DETECTED${NC}"
        echo -e "${YELLOW}Run 'health' for details${NC}"
        return 1
    fi
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

# Dodaj pattern do blokady
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
# MONITORING W TLE
# ========================================
monitor_changes() {
    # Sprawdź czy się zmieniło dużo plików
    if [[ -d ".git" ]]; then
        local changed=$(git status --porcelain 2>/dev/null | wc -l)
        if [[ $changed -gt 15 ]]; then
            echo -e "${YELLOW}⚠️  WARNING: $changed files changed! Consider backup.${NC}"
        fi
    fi
}

# Auto-monitor co 60 sekund w tle
start_monitor() {
    (
        while true; do
            sleep 60
            monitor_changes
        done
    ) &
    MONITOR_PID=$!
    echo -e "${GREEN}🔍 Background monitor started (PID: $MONITOR_PID)${NC}"
}

stop_monitor() {
    if [[ -n "$MONITOR_PID" ]]; then
        kill $MONITOR_PID 2>/dev/null
        echo -e "${BLUE}🔍 Background monitor stopped${NC}"
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
# INICJALIZACJA PRZY ŹRÓDŁOWANIU
# ========================================
if [[ "${BASH_SOURCE[0]}" != "${0}" ]]; then
    # Skrypt jest source'owany
    init_shellguard

    # Uruchom monitor w tle
    start_monitor

    # Trap na exit żeby zatrzymać monitor
    trap 'stop_monitor' EXIT

    echo -e "${GREEN}🎯 Type 'llm_help' for commands${NC}"
    echo -e "${BLUE}🚀 LLM can now use: python, npm, git (all monitored)${NC}"
    echo -e "${YELLOW}🔒 Dangerous commands are blocked automatically${NC}"
fi

# ========================================
# JEŚLI URUCHOMIONY JAKO SKRYPT
# ========================================
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    # Uruchomiony jako skrypt - wykonaj komendę
    case "$1" in
        "install")
            echo "Installing LLM Guard..."
            echo "Add this to your ~/.bashrc or ~/.zshrc:"
            echo "source $(realpath "$0")"
            ;;
        "status"|"health"|"check"|"backup"|"rollback"|"emergency")
            init_shellguard >/dev/null 2>&1
            $1
            ;;
        *)
            echo "Usage: $0 {install|status|health|check|backup|rollback|emergency}"
            echo "Or: source $0  (to activate LLM Guard)"
            ;;
    esac
fi