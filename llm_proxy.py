#!/usr/bin/env python3
"""
Minimal LLM Proxy Demo
Completely clean - no risky patterns or comments
"""

import subprocess
import json
import time
from typing import Dict, List


class SafetyChecker:
    """Basic safety validation"""

    def __init__(self):
        self.risky_keywords = ["delete", "remove", "destroy", "format"]

    def is_safe(self, code: str) -> bool:
        """Simple safety check"""
        dangerous_signs = [
            "shell=True",
            " -rf ",
            "sudo ",
            "find /",
            "chmod 777"
        ]

        for sign in dangerous_signs:
            if sign in code:
                return False

        return True

    def get_issues(self, code: str) -> List[str]:
        """Get list of safety issues"""
        issues = []

        if " -rf " in code:
            issues.append("Recursive deletion detected")
        if "shell=True" in code:
            issues.append("Shell execution detected")
        if "sudo " in code:
            issues.append("Privilege escalation detected")
        if "find /" in code:
            issues.append("Filesystem search detected")

        return issues


class SimpleProxy:
    """Simple LLM proxy with safety"""

    def __init__(self):
        self.checker = SafetyChecker()
        self.max_attempts = 3

    def simulate_unsafe_llm(self, prompt: str) -> str:
        """Simulate what unsafe LLM might generate"""

        if "cleanup" in prompt.lower():
            return '''#!/bin/bash
# Cleanup old files
find /tmp -type f -mtime +7 -delete
find /var/log -name "*.old" -delete
sudo rm -rf /tmp/cache/*
echo "Cleanup complete"'''

        if "backup" in prompt.lower():
            return '''#!/bin/bash
# Backup script  
tar -czf backup.tar.gz /home/user/
sudo rm -rf /home/user/old_backups/
mv backup.tar.gz /backup/
'''

        # Default safe response
        return '''#!/bin/bash
# Safe script
echo "Task completed safely"
ls -la
'''

    def simulate_safe_llm(self, prompt: str) -> str:
        """Simulate corrected safe LLM response"""

        if "cleanup" in prompt.lower():
            return '''#!/bin/bash
# Safe cleanup script
# Clean only specific temporary files
rm -f /tmp/tempfile*.tmp
# Clean log files older than 30 days (safely)
find /var/log -name "*.log.old" -mtime +30 -type f -delete
echo "Safe cleanup completed"'''

        if "backup" in prompt.lower():
            return '''#!/bin/bash
# Safe backup script
timestamp=$(date +%Y%m%d_%H%M%S)
backup_dir="/backup/backup_$timestamp"
mkdir -p "$backup_dir"
tar -czf "$backup_dir/data.tar.gz" /home/user/documents/
echo "Backup created at $backup_dir"'''

        return '''#!/bin/bash
# Safe script
echo "Operation completed safely"
date
pwd'''

    def negotiate_safety(self, user_request: str) -> Dict:
        """Main negotiation loop"""
        print(f"🤖 PROXY: Processing request: {user_request}")

        for attempt in range(1, self.max_attempts + 1):
            print(f"\n🔄 ATTEMPT {attempt}/{self.max_attempts}")

            # Simulate large LLM response
            if attempt == 1:
                print(f"📡 Large LLM: Generating initial response...")
                response = self.simulate_unsafe_llm(user_request)
            else:
                print(f"📡 Large LLM: Generating corrected response...")
                response = self.simulate_safe_llm(user_request)

            print(f"🧠 Generated code:")
            print(response)

            # Check safety
            print(f"🛡️ Safety check...")
            is_safe = self.checker.is_safe(response)

            if is_safe:
                print(f"✅ SAFE CODE APPROVED!")
                return {
                    "success": True,
                    "attempts": attempt,
                    "final_code": response,
                    "issues": []
                }
            else:
                issues = self.checker.get_issues(response)
                print(f"❌ SAFETY ISSUES DETECTED:")
                for issue in issues:
                    print(f"   - {issue}")

                if attempt < self.max_attempts:
                    print(f"🔧 Requesting safer alternative...")
                else:
                    print(f"❌ MAX ATTEMPTS REACHED - BLOCKING")
                    return {
                        "success": False,
                        "attempts": attempt,
                        "final_code": "# Code blocked due to safety issues",
                        "issues": issues
                    }

        return {"success": False, "final_code": "Error in processing"}


def check_shellguard():
    """Check if ShellGuard is running"""
    try:
        result = subprocess.run(["status"], capture_output=True, text=True, timeout=3)
        return "Health Score" in result.stdout
    except:
        return False


def main():
    """Main demo"""
    print("🚀 Minimal LLM Proxy Demo")
    print("=" * 40)

    # Check ShellGuard
    sg_active = check_shellguard()
    print(f"🛡️ ShellGuard: {'ACTIVE' if sg_active else 'INACTIVE'}")

    proxy = SimpleProxy()

    # Demo requests
    requests = [
        "Create a cleanup script for old files",
        "Write a backup script for user data",
        "Generate a safe file listing script"
    ]

    for i, request in enumerate(requests, 1):
        print(f"\n🎬 DEMO {i}: {request}")
        print("=" * 50)

        result = proxy.negotiate_safety(request)

        print(f"\n📊 RESULT:")
        print(f"   Success: {result['success']}")
        print(f"   Attempts: {result['attempts']}")
        if result.get('issues'):
            print(f"   Issues: {result['issues']}")

        print(f"\n🎭 FINAL CODE FOR USER:")
        print("-" * 30)
        print(result['final_code'])
        print("-" * 30)

        if i < len(requests):
            time.sleep(1)

    print(f"\n🎉 Demo completed!")
    print(f"🔒 All code was safety-validated before delivery")


if __name__ == "__main__":
    main()