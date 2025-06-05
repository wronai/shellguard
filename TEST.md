# 🐳 ShellGuard Docker + Ansible Integration

## 🔧 Usage Instructions

### 1. Quick Start

```bash
# Clone the example
git clone https://github.com/username/shellguard-docker-example.git
cd shellguard-docker-example

# Run complete test suite
./scripts/run-tests.sh
```

### 2. Manual Testing

```bash
# Start containers
docker-compose -f docker/docker-compose.yml up -d

# Access development environment
docker-compose -f docker/docker-compose.yml exec dev bash

# In the container:
source ~/.bashrc  # ShellGuard is now active
status           # Check system status
health           # Run health check
```

### 3. Run Specific Ansible Tests

```bash
# Setup only
docker-compose -f docker/docker-compose.yml exec ansible \
    ansible-playbook -i inventory/hosts.yml playbooks/setup-shellguard.yml

# Test only
docker-compose -f docker/docker-compose.yml exec ansible \
    ansible-playbook -i inventory/hosts.yml playbooks/test-shellguard.yml
```

### 4. Demo Scenarios

```bash
# Run interactive demo
./scripts/demo-scenarios.sh
```

## 📊 Expected Output

### Successful Test Run

```
🧪 SHELLGUARD TEST RESULTS:
================================
✅ Status Command: PASS
✅ Health Check: PASS
✅ Command Blocking: PASS
✅ Python Security: PASS
✅ Backup System: PASS
✅ Safe Commands: PASS
================================
Overall: ALL TESTS PASSED! 🎉
```

### Development Environment

```bash
developer@shellguard-dev:/workspace$ status
📊 ShellGuard STATUS
==================================
Health Score: 100/100 ✅
Commands Blocked: 0
Last Backup: 
Session Started: 2024-12-05T15:30:22
==================================

developer@shellguard-dev:/workspace$ rm -rf test/
🚨 BLOCKED: Dangerous pattern detected: rm -rf
Use 'safe_rm' if you really need to delete files
```

## 🎯 Key Benefits

1. **Containerized Testing** - Isolated, reproducible test environment
2. **Automated Verification** - Ansible ensures consistent setup and testing
3. **Real-world Scenarios** - Demonstrates actual AI assistant interactions
4. **CI/CD Ready** - Can be integrated into continuous integration pipelines
5. **Multi-environment** - Tests both development and production scenarios

This example shows how ShellGuard can be deployed and tested at scale using Docker and Ansible, providing confidence that it works correctly in real-world environments.