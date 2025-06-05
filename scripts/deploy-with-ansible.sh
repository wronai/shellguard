#!/bin/bash
# deploy-with-ansible.sh - deploy-with-ansible.sh - Deploy ShellGuard using Ansible
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
# deploy-with-ansible.sh - Deploy ShellGuard using Ansible
#
# Deploy ShellGuard using Ansible

set -e

# Default values
INVENTORY="inventory/hosts.yml"
PLAYBOOK="playbooks/setup-shellguard.yml"
TAGS=""
VERBOSE=""

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -i|--inventory)
            INVENTORY="$2"
            shift 2
            ;;
        -p|--playbook)
            PLAYBOOK="$2"
            shift 2
            ;;
        -t|--tags)
            TAGS="--tags $2"
            shift 2
            ;;
        -v|--verbose)
            VERBOSE="-v"
            shift
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

# Check if Ansible is installed
if ! command -v ansible-playbook &> /dev/null; then
    echo "❌ Ansible is not installed. Please install it first."
    exit 1
fi

# Check if inventory file exists
if [ ! -f "$INVENTORY" ]; then
    echo "❌ Inventory file not found: $INVENTORY"
    exit 1
fi

# Check if playbook exists
if [ ! -f "$PLAYBOOK" ]; then
    echo "❌ Playbook not found: $PLAYBOOK"
    exit 1
fi

echo "🚀 Deploying ShellGuard with Ansible..."
echo "📋 Inventory: $INVENTORY"
echo "📜 Playbook: $PLAYBOOK"
[ -n "$TAGS" ] && echo "🏷️  Tags: $TAGS"

# Run Ansible playbook
ansible-playbook -i "$INVENTORY" "$PLAYBOOK" $TAGS $VERBOSE

echo "✅ Deployment complete!"
