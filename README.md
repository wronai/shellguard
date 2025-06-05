# shellguard
"Shell Guardian for Safe Development" - "Your shell's bodyguard"
# 🛡️ ShellGuard

**Your shell's bodyguard - Intelligent command interceptor and safety net for developers**

[![License: MIT](https://img.shields.io/badge/License-Apache%202.0-yellow.svg)](https://opensource.org/licenses/Apache-2.0)
[![Shell](https://img.shields.io/badge/Shell-Bash-green.svg)](https://www.gnu.org/software/bash/)
[![Platform](https://img.shields.io/badge/Platform-Linux%20%7C%20macOS-blue.svg)](https://github.com)

ShellGuard is a lightweight, intelligent shell wrapper that protects your development environment from dangerous commands, provides automatic backups, and gives you instant rollback capabilities. Perfect for controlling AI assistants, preventing accidents, and maintaining project health.

## 🚀 Quick Start

```bash
# Install ShellGuard
curl -o shellguard.sh https://raw.githubusercontent.com/wronai/shellguard/main/shellguard.sh
chmod +x shellguard.sh

# Activate for current session
source shellguard.sh

# Make permanent (optional)
echo "source $(pwd)/shellguard.sh" >> ~/.bashrc
```

**That's it! Your shell is now protected.** 🎉

## ✨ Features

### 🛡️ **Command Interception**
- Automatically blocks dangerous commands (`rm -rf`, `sudo rm`, etc.)
- Scans Python files for malicious code patterns
- Protects against destructive Git operations
- Smart pattern matching with custom rules

### 📦 **Automatic Backups**
- Creates backups before risky operations
- Git-based versioning when available
- File-based fallback for non-Git projects
- Configurable backup retention

### 🔄 **Instant Recovery**
- One-command rollback to last known good state
- Emergency reset functionality
- Automatic state monitoring
- Health score tracking

### 🎯 **AI Assistant Control**
- Perfect for LLMs (ChatGPT, Claude, Copilot, etc.)
- Transparent operation - AI doesn't know it's monitored
- Real-time feedback with clear success/error signals
- Prevents AI from making destructive changes

## 📋 Commands Reference

### 🔍 **Status & Monitoring**

```bash
status          # Show complete system status
health          # Run full project health check
check           # Quick health check (perfect for AI)
```

**Example output:**
```
📊 ShellGuard STATUS
==================================
Health Score: 95/100 ✅
Commands Blocked: 3
Last Backup: backup_20241205_143022
Session Started: 2024-12-05T14:25:33
==================================
```

### 💾 **Backup & Recovery**

```bash
backup          # Create manual backup
rollback        # Restore from last backup
emergency       # Emergency reset with confirmation
```

### 🔒 **Safety Overrides**

When ShellGuard blocks a command, use these safe alternatives:

```bash
safe_rm file.txt           # Delete with automatic backup
force_git reset --hard     # Git command with backup
force_python script.py     # Run Python despite warnings
```

### ⚙️ **Configuration**

```bash
block "pattern"             # Add custom dangerous pattern
llm_help                   # Show all available commands
```

## 🎪 Usage Examples

### 🤖 **Working with AI Assistants**

**Perfect session flow:**
```bash
USER: "Check the project status"
AI: status
# 📊 Health Score: 98/100 ✅

USER: "Create a calculator script"
AI: [creates calculator.py]

USER: "Test the script"
AI: python calculator.py
# ✅ Syntax OK, Security OK, Execution successful

USER: "Commit the changes"
AI: git add . && git commit -m "Add calculator"
# ✅ Changes committed successfully
```

**When AI tries something dangerous:**
```bash
AI: rm -rf temp/
# 🚨 BLOCKED: Dangerous pattern detected: rm -rf
# Use 'safe_rm' if you really need to delete files

AI: safe_rm temp/
# ⚠️ Using SAFE RM - creating backup first
# 📦 Creating backup: backup_20241205_144523
# ✅ Files deleted safely
```

### 🐍 **Python Security**

ShellGuard automatically scans Python files:

```python
# malicious.py
import os
os.system('rm -rf /')
```

```bash
python malicious.py
# 🚨 Dangerous Python code detected in: malicious.py
# Content preview:
# 2:os.system('rm -rf /')
# Use 'force_python malicious.py' to run anyway
```

### 📦 **NPM Safety**

Automatic backups before package installations:

```bash
npm install some-package
# 🔍 Installing new packages: some-package
# 📦 Creating backup before package installation...
# ✅ Git backup created
# [normal npm install proceeds]
```

### 🔄 **Git Protection**

```bash
git reset --hard HEAD~5
# 🚨 BLOCKED: Dangerous pattern detected: --hard
# Use 'force_git' if you really need this git command

force_git reset --hard HEAD~5
# ⚠️ Using FORCE GIT - creating backup first
# 📦 Creating backup: backup_20241205_144856
# [git command executes]
```

## ⚡ Advanced Features

### 📊 **Health Monitoring**

ShellGuard continuously monitors your project:

- **Syntax validation** for Python files
- **Package.json validation** for Node.js projects
- **Git status monitoring** (uncommitted changes)
- **Error log detection**
- **Overall health scoring**

```bash
health
# 🔍 Checking project health...
# 🐍 Checking Python syntax...
# ✅ Syntax OK: calculator.py
# ✅ Syntax OK: utils.py
# 📦 Checking Node.js project...
# ✅ Valid package.json
# 🎉 Project health: GOOD (Score: 98/100)
```

### 🔍 **Background Monitoring**

ShellGuard runs a background monitor that:
- Checks for excessive file changes every minute
- Monitors system health
- Alerts on potential issues
- Updates health scores automatically

### 🚨 **Dangerous Pattern Detection**

Default blocked patterns:
- `rm -rf` - Recursive deletion
- `sudo rm` - Root deletion
- `DROP TABLE` - Database destruction
- `os.system(` - Python system calls
- `eval(` / `exec(` - Code injection
- `--force` / `--hard` - Destructive Git flags

Add your own patterns:
```bash
block "dangerous_function("
# ✅ Added pattern to blocklist: dangerous_function(
```

### 📁 **File Structure**

```
~/.shellguard/
├── state.json          # Current system state
├── blocked.txt         # Custom blocked patterns
└── backups/           # Automatic backups
    ├── backup_20241205_143022/
    ├── backup_20241205_144523/
    └── backup_20241205_144856/
```

## 🔧 Configuration

### 🎛️ **Customization**

Edit `~/.shellguard/blocked.txt` to add custom patterns:
```
your_dangerous_command
risky_operation
delete_everything
```

### ⚙️ **State Management**

ShellGuard maintains state in `~/.shellguard/state.json`:
```json
{
  "health_score": 95,
  "last_backup": "backup_20241205_143022",
  "commands_blocked": 3,
  "files_changed": 2,
  "session_start": "2024-12-05T14:25:33",
  "warnings": []
}
```

## 🤝 Use Cases

### 🤖 **AI Development Assistant Control**
- **LLMs (ChatGPT, Claude, Copilot)** - Prevents AI from running destructive commands
- **Code generation safety** - Scans generated code before execution
- **Automated testing** - AI can safely run tests without breaking the project

### 👥 **Team Development**
- **Junior developer protection** - Prevents accidental damage
- **Code review safety** - Test dangerous changes safely
- **Shared development environments** - Multiple users, consistent safety

### 🔬 **Experimentation & Learning**
- **Safe code testing** - Try dangerous operations with automatic rollback
- **Learning environment** - Mistakes don't destroy projects
- **Rapid prototyping** - Quick iterations with safety net

### 🏢 **Production Safety**
- **Deployment protection** - Prevent accidental production changes
- **Maintenance safety** - Safe system administration
- **Disaster recovery** - Quick rollback capabilities

## 🚨 Emergency Procedures

### 🔥 **Something Went Wrong**

```bash
# Quick assessment
status

# If health score is low
health

# Emergency rollback
emergency
# 🚨 EMERGENCY MODE
# This will rollback to last known good state
# Continue? (y/N): y
```

### 💾 **Manual Recovery**

```bash
# List available backups
ls ~/.shellguard/backups/

# Manual restore (if emergency fails)
cp -r ~/.shellguard/backups/backup_TIMESTAMP/* .
```

### 🔍 **Debugging Issues**

```bash
# Check what's blocked
cat ~/.shellguard/blocked.txt

# Review recent commands
cat ~/.shellguard/state.json

# Disable temporarily (not recommended)
unset -f python npm git rm  # Remove overrides
```

## 🛠️ Installation Options

### 📥 **Method 1: Direct Download**
```bash
curl -o shellguard.sh https://raw.githubusercontent.com/wronai/shellguard/main/shellguard.sh
chmod +x shellguard.sh
source shellguard.sh
```

### 📦 **Method 2: Git Clone**
```bash
git clone https://github.com/wronai/shellguard.git
cd shellguard
source shellguard.sh
```

### 🔧 **Method 3: Permanent Installation**
```bash
# Download to standard location
curl -o ~/.shellguard.sh https://raw.githubusercontent.com/wronai/shellguard/main/shellguard.sh
chmod +x ~/.shellguard.sh

# Add to shell profile
echo "source ~/.shellguard.sh" >> ~/.bashrc  # or ~/.zshrc
source ~/.bashrc
```

## 🎯 Best Practices

### ✅ **Do's**
- Run `status` at the beginning of each session
- Create `backup` before major changes
- Use `health` to check project state regularly
- Let ShellGuard block dangerous commands - use safe alternatives
- Review blocked patterns periodically

### ❌ **Don'ts**
- Don't disable ShellGuard for "quick fixes"
- Don't ignore health warnings
- Don't use `force_*` commands without understanding risks
- Don't modify core ShellGuard files directly
- Don't bypass backups for "small" changes

### 🎪 **Working with AI**
- Always start sessions with `status` or `check`
- Let AI use normal commands - ShellGuard handles safety
- When AI gets blocked, guide it to safe alternatives
- Use `health` to show AI the project state
- Trust the feedback - red means stop, green means go

## 🐛 Troubleshooting

### ❓ **Common Issues**

**ShellGuard not working after restart**
```bash
# Re-source the script
source shellguard.sh
# Or add to ~/.bashrc permanently
```

**Commands still blocked after adding to blocklist**
```bash
# Restart ShellGuard
source shellguard.sh
```

**Health score keeps dropping**
```bash
# Check what's causing issues
health
# Fix reported problems
```

**Backup/rollback not working**
```bash
# Check if Git is available
git --version
# Or use manual backup restoration
```

### 🔧 **Advanced Troubleshooting**

**See what ShellGuard is doing**
```bash
# Enable debug mode (add to shellguard.sh)
set -x  # Add at top of script
```

**Reset ShellGuard completely**
```bash
rm -rf ~/.shellguard
source shellguard.sh  # Reinitialize
```

## 📈 Roadmap

### 🎯 **Planned Features**
- [ ] Windows/PowerShell support
- [ ] Docker command protection
- [ ] Kubernetes safety features
- [ ] Integration with popular IDEs
- [ ] Web dashboard for monitoring
- [ ] Team collaboration features
- [ ] Advanced AI model integration
- [ ] Custom plugin system

### 🔮 **Future Ideas**
- Machine learning for pattern detection
- Integration with CI/CD pipelines
- Cloud backup storage
- Advanced analytics dashboard
- Mobile notifications for critical events

## 🤝 Contributing

We welcome contributions! Here's how to help:

1. **Fork the repository**
2. **Create a feature branch** (`git checkout -b feature/amazing-feature`)
3. **Make your changes**
4. **Test thoroughly** with ShellGuard enabled
5. **Commit your changes** (`git commit -m 'Add amazing feature'`)
6. **Push to the branch** (`git push origin feature/amazing-feature`)
7. **Open a Pull Request**

### 📝 **Contribution Guidelines**
- All changes must pass ShellGuard's own safety checks
- Add tests for new patterns or features
- Update documentation for new commands
- Follow existing code style
- Test with multiple shell environments

## 📄 License

This project is licensed under the Apache 2 License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Inspired by the need to control AI assistants safely
- Built for developers who value both innovation and safety
- Thanks to the community for testing and feedback

## 📞 Support

- **Issues**: [GitHub Issues](https://github.com/wronai/shellguard/issues)
- **Discussions**: [GitHub Discussions](https://github.com/wronai/shellguard/discussions)
- **Email**: support@shellguard.dev

---

**⭐ If ShellGuard saved your project, please star the repository!**

Made with ❤️ by developers, for developers.

*Your shell's bodyguard - because prevention is better than recovery.*