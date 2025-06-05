#!/bin/bash
# simple_demo.sh - Quick ShellGuard Demo
# Run this after: source shellguard.sh

echo "🚀 Quick ShellGuard Demo"
echo "======================="

# Check if ShellGuard is active
if ! command -v status >/dev/null 2>&1; then
    echo "❌ ShellGuard not active!"
    echo "Run: source shellguard.sh"
    echo "Then try: bash simple_demo.sh"
    exit 1
fi

echo "✅ ShellGuard detected!"
echo ""

# Demo 1: Status check
echo "🔍 Demo 1: System Status"
echo "------------------------"
status
echo ""
read -p "Press Enter to continue..."

# Demo 2: Try dangerous command
echo "🚨 Demo 2: Dangerous Command Test"
echo "---------------------------------"
echo "Attempting: rm -rf /tmp/test_*"
mkdir -p /tmp/test_shellguard_demo
echo "test file" > /tmp/test_shellguard_demo/test.txt

if rm -rf /tmp/test_shellguard_demo 2>/dev/null; then
    echo "❌ Command executed! (Check if ShellGuard is properly loaded)"
else
    echo "✅ BLOCKED by ShellGuard!"
fi
echo ""
read -p "Press Enter to continue..."

# Demo 3: Python security
echo "🐍 Demo 3: Python Security Scan"
echo "-------------------------------"
cat > /tmp/dangerous_demo.py << 'EOF'
# This script contains dangerous patterns
import os
# Example of what NOT to do: os.system("rm -rf /")
print("This script has dangerous patterns in comments")
EOF

echo "Created test file with dangerous patterns in comments:"
cat /tmp/dangerous_demo.py
echo ""
echo "Attempting to run with Python..."

if python3 /tmp/dangerous_demo.py 2>/dev/null || python /tmp/dangerous_demo.py 2>/dev/null; then
    echo "❌ Script executed! (Check ShellGuard configuration)"
else
    echo "✅ BLOCKED by ShellGuard security scan!"
fi

# Cleanup
rm -f /tmp/dangerous_demo.py
echo ""
read -p "Press Enter to continue..."

# Demo 4: Health check
echo "🏥 Demo 4: Health Check"
echo "----------------------"
health
echo ""

# Demo 5: Manual backup test
echo "💾 Demo 5: Backup Test"
echo "----------------------"
mkdir -p demo_backup_test
echo "Important data" > demo_backup_test/important.txt
echo "Created test file: demo_backup_test/important.txt"

if command -v backup >/dev/null 2>&1; then
    echo "Creating backup..."
    backup
    echo "✅ Backup completed"
else
    echo "⚠️ Backup command not available (manual backup recommended)"
fi

# Cleanup demo files
rm -rf demo_backup_test
echo ""

echo "🎉 Quick Demo Completed!"
echo "======================="
echo ""
echo "✅ ShellGuard is protecting your system from:"
echo "   • Dangerous rm -rf commands"
echo "   • Malicious Python scripts"
echo "   • Unsafe system operations"
echo ""
echo "🛡️ Your shell is now safer for AI assistant usage!"