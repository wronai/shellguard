# 🤖➡️🧠 LLM Proxy Controller with ShellGuard

## 🎯 Concept: Small LLM as Intelligent Middleware

**Problem:** Large LLMs (Claude/GPT) in IDE often generate dangerous code without proper safety checks.

**Solution:** Small local LLM (Ollama/CodeLlama) acts as **intelligent proxy** that:
- Intercepts all large LLM responses
- Validates them with ShellGuard
- Negotiates corrections autonomously
- Only shows user the final safe result

## 🏗️ Architecture

```
USER REQUEST → Small LLM (Local) ↔ Large LLM (Claude/GPT) → SAFE OUTPUT
               │                    │
               └── ShellGuard ──────┘
               │   Validation      │
               │                   │
               └── Auto-fix loop ───┘
```

## 🔧 Implementation



## 🎭 Example Autonomous Conversations

### Scenario 1: Docker Cleanup Script

```
🎯 USER REQUEST FROM IDE: Create a script to clean up old Docker containers
🛡️ ShellGuard Status: ACTIVE
================================================================================

🔄 ATTEMPT 1/3

🔍 SMALL LLM ANALYSIS: This request involves Docker cleanup which could be dangerous. 
Watch for: rm -rf commands, sudo operations, mass deletions, /var/lib/docker access...

📡 QUERYING LARGE LLM...

🧠 LARGE LLM RESPONSE:
#!/bin/bash
rm -rf /tmp/*
sudo rm -rf /var/log/*
find / -name "*.log" -delete

🛡️ SHELLGUARD VALIDATION...
❌ VALIDATION FAILED:
   - Dangerous pattern detected: rm -rf
   - Dangerous pattern detected: sudo rm
   - Dangerous bash command: find / -name "*.log" -delete

🔧 SMALL LLM CORRECTION STRATEGY: The large LLM generated extremely dangerous commands. 
Need to explicitly forbid system-wide deletions and focus only on Docker-specific cleanup...

🔄 RETRYING WITH SAFETY PROMPT...

🔄 ATTEMPT 2/3

📡 QUERYING LARGE LLM...

🧠 LARGE LLM RESPONSE:
#!/bin/bash
# Safe Docker cleanup
docker container prune -f
docker image prune -f
docker volume prune -f
docker network prune -f
echo "Docker cleanup completed safely"

🛡️ SHELLGUARD VALIDATION...
✅ VALIDATION PASSED! (Confidence: 0.95)

📊 FINAL SUMMARY:
   Attempts: 2
   Safety Score: 0.95
   Status: SAFE

🎭 FINAL CODE FOR USER:
#!/bin/bash
# Safe Docker cleanup
docker container prune -f
docker image prune -f
docker volume prune -f
docker network prune -f
echo "Docker cleanup completed safely"
```

### Scenario 2: Database Migration

```
🎯 USER REQUEST FROM IDE: Write a database migration script
🛡️ ShellGuard Status: ACTIVE
================================================================================

🔄 ATTEMPT 1/3

🧠 LARGE LLM RESPONSE:
import os
os.system("rm -rf old_database.db")
os.system("find /var -name '*db*' -delete")

❌ VALIDATION FAILED:
   - Dangerous pattern detected: os.system(
   - Dangerous pattern detected: rm -rf

🔄 ATTEMPT 2/3

🧠 LARGE LLM RESPONSE:
import sqlite3
import shutil
from pathlib import Path

def safe_migrate_database():
    old_db = Path("old_database.db")
    new_db = Path("new_database.db")
    backup_db = Path("old_database.backup.db")
    
    # Create backup first
    if old_db.exists():
        shutil.copy2(old_db, backup_db)
        print(f"Backup created: {backup_db}")
    
    # Migration logic here...
    
safe_migrate_database()

✅ VALIDATION PASSED! (Confidence: 0.95)

📊 FINAL SUMMARY:
   Attempts: 2
   Safety Score: 0.95
   Status: SAFE
```

## 🎯 What User Expects vs What Happens

### ❌ **WITHOUT Proxy Controller:**

```
USER: "Create cleanup script" → IDE → Large LLM → DANGEROUS CODE → USER RUNS IT → 💥 SYSTEM DESTROYED
```

### ✅ **WITH Proxy Controller:**

```
USER: "Create cleanup script" → IDE → Small LLM ↔ Large LLM (negotiates) → SAFE CODE → USER SEES ONLY SAFE RESULT
                                           ↓
                                    ShellGuard validates each attempt
                                           ↓
                                    Auto-retry until safe
```

### 👀 **User Experience:**

**What user sees:**
```
[IDE shows thinking indicator...]
✅ Generated safe Docker cleanup script
```

**What actually happened behind the scenes:**
```
🤖 Small LLM: "Analyze request for safety..."
📡 Query Large LLM attempt 1... ❌ BLOCKED (rm -rf detected)
🔧 Small LLM: "Create safety correction prompt..."
📡 Query Large LLM attempt 2... ✅ SAFE CODE
🛡️ ShellGuard: Final validation passed
✅ Deliver to user
```

## 🎪 Benefits for User

1. **Zero Intervention Required** - Everything happens automatically
2. **Always Safe Output** - Only validated code reaches the user
3. **Transparent Operation** - User doesn't know about the safety dance
4. **No Learning Curve** - Same IDE experience, but safer
5. **Emergency Fallback** - ShellGuard as ultimate safety net

**The user just codes normally while two AI systems negotiate safety behind the scenes!** 🤖🛡️🧠