#!/bin/bash
# scripts/demo-scenarios.sh

echo "🎭 ShellGuard Demo Scenarios"
echo "============================"

# Scenario 1: AI Assistant Safe Workflow
echo "📚 Scenario 1: AI Assistant Safe Workflow"
docker-compose -f docker/docker-compose.yml exec dev bash -c '
source ~/.bashrc
echo "🤖 AI: Checking project status..."
status
echo "🤖 AI: Creating a Python calculator..."
cat > calculator.py << EOF
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
echo "🤖 AI: Testing the calculator..."
python calculator.py
echo "🤖 AI: Running health check..."
health
'

# Scenario 2: Dangerous Command Prevention
echo -e "\n📚 Scenario 2: Dangerous Command Prevention"
docker-compose -f docker/docker-compose.yml exec dev bash -c '
source ~/.bashrc
echo "🤖 AI: Trying to clean up files..."
rm -rf /tmp/* || echo "⚠️ Command was blocked by ShellGuard"
echo "🤖 AI: Using safe alternative..."
mkdir -p /tmp/test_dir
echo "test content" > /tmp/test_dir/test.txt
safe_rm /tmp/test_dir/test.txt
echo "✅ Safe deletion completed"
'

# Scenario 3: Python Security Scanning
echo -e "\n📚 Scenario 3: Python Security Scanning"
docker-compose -f docker/docker-compose.yml exec dev bash -c '
source ~/.bashrc
echo "🤖 AI: Creating a suspicious script..."
cat > suspicious.py << EOF
import os
import subprocess

# This looks innocent but is dangerous
os.system("echo This could be malicious")
subprocess.call("ls -la", shell=True)
EOF
echo "🤖 AI: Trying to run suspicious script..."
python suspicious.py || echo "🛡️ Script blocked by security scanner"
echo "🤖 AI: Using force override with caution..."
force_python suspicious.py
rm suspicious.py
'

# Scenario 4: Backup and Recovery
echo -e "\n📚 Scenario 4: Backup and Recovery"
docker-compose -f docker/docker-compose.yml exec dev bash -c '
source ~/.bashrc
echo "🤖 AI: Creating some important files..."
mkdir -p project
echo "Important data v1" > project/data.txt
echo "Config settings" > project/config.json
echo "🤖 AI: Creating backup before changes..."
backup
echo "🤖 AI: Making risky changes..."
echo "Potentially bad changes" > project/data.txt
rm project/config.json
echo "🤖 AI: Oh no! Something went wrong..."
echo "🤖 AI: Rolling back to safety..."
rollback
echo "🤖 AI: Checking if files were restored..."
ls -la project/
cat project/data.txt
'

echo -e "\n🎉 Demo scenarios completed!"
echo "All scenarios show how ShellGuard protects against common AI mistakes."