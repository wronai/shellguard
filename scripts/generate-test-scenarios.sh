#!/bin/bash
# Generate test scenarios for ShellGuard

set -e

cat > /home/tom/github/wronai/shellguard/TEST.md << 'EOL'
# ShellGuard Test Scenarios

## Unit Tests

### Command Interception
- [ ] Intercept `rm -rf /`
- [ ] Intercept `sudo rm -rf /`
- [ ] Intercept `:(){ :|:& };:` (fork bomb)
- [ ] Intercept `chmod -R 777 /`
- [ ] Intercept `dd if=/dev/zero of=/dev/sda`

### Backup System
- [ ] Test automatic backup on file modification
- [ ] Test backup rotation
- [ ] Test backup integrity
- [ ] Test backup exclusion patterns
- [ ] Test backup performance with large files

### Rollback System
- [ ] Test rollback to previous version
- [ ] Test rollback with conflicts
- [ ] Test rollback dry-run
- [ ] Test rollback logging
- [ ] Test rollback of specific files

## Integration Tests

### Shell Integration
- [ ] Test bash integration
- [ ] Test zsh integration
- [ ] Test fish integration
- [ ] Test shell startup time impact
- [ ] Test shell completion

### Environment Detection
- [ ] Test in Docker container
- [ ] Test on Ubuntu
- [ ] Test on CentOS
- [ ] Test on macOS
- [ ] Test on WSL

## Performance Tests

- [ ] Measure startup time
- [ ] Measure command execution time
- [ ] Measure memory usage
- [ ] Test with large history
- [ ] Test with many environment variables

## Security Tests

- [ ] Test privilege escalation attempts
- [ ] Test command injection attempts
- [ ] Test environment variable sanitization
- [ ] Test configuration file permissions
- [ ] Test secure temporary file handling

## Recovery Tests

- [ ] Test recovery from backup
- [ ] Test recovery from corrupted state
- [ ] Test recovery from full disk
- [ ] Test recovery logging
- [ ] Test recovery notification

## Usability Tests

- [ ] Test help output
- [ ] Test version output
- [ ] Test status output
- [ ] Test error messages
- [ ] Test progress indicators

## Documentation Tests

- [ ] Test README examples
- [ ] Test man page
- [ ] Test --help output
- [ ] Test configuration examples
- [ ] Test troubleshooting guide
EOL

echo "✅ Test scenarios generated in TEST.md"
