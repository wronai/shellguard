#!/bin/bash
# setup-dev-env.sh - setup-dev-env.sh - Setup development environment
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
# setup-dev-env.sh - Setup development environment
#
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
