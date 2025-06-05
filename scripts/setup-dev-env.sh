#!/bin/bash
# Setup development environment

set -e

echo "🚀 Setting up ShellGuard development environment..."

# Install system dependencies
if [ -f /etc/os-release ]; then
    . /etc/os-release
    case $ID in
        debian|ubuntu|linuxmint)
            sudo apt-get update
            sudo apt-get install -y shellcheck ansible docker.io docker-compose
            ;;
        fedora)
            sudo dnf install -y ShellCheck ansible docker docker-compose
            ;;
        *)
            echo "⚠️  Unsupported Linux distribution. Please install dependencies manually:"
            echo "   - shellcheck"
            echo "   - ansible"
            echo "   - docker"
            echo "   - docker-compose"
            ;;
    esac
else
    echo "⚠️  Could not detect Linux distribution. Please install dependencies manually."
fi

# Install pre-commit hooks
if ! command -v pre-commit &> /dev/null; then
    pip install pre-commit
    pre-commit install
fi

echo "✅ Development environment setup complete!"
echo "   Run 'make test' to run tests or 'make docker-build' to build Docker images."
