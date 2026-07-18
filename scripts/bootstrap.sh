#!/usr/bin/env bash

# Exit immediately if a command exits with a non-zero status
set -euo pipefail

# Determine script directory and move to workspace root
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$WORKSPACE_ROOT"

echo "Initializing AI Platform Development Environment..."

# 1. Create shared directory hierarchy
echo "Creating shared directories..."
mkdir -p shared/{claude,antigravity,workspace,npm,cache,ssh,config} omniroute opendesign images/ai-cli-base

# Ensure placeholder .gitkeep files exist
for dir in shared/claude shared/antigravity shared/workspace shared/npm shared/cache shared/ssh shared/config omniroute opendesign; do
  touch "$dir/.gitkeep"
done

# 2. Setup .env file
if [ ! -f .env ]; then
  echo "Provisioning .env configuration from .env.example..."
  cp .env.example .env
else
  echo ".env configuration already exists. Skipping template copy."
fi

# 3. Dynamic User ID/Group ID matching for permissions parity
HOST_UID=$(id -u)
HOST_GID=$(id -g)
echo "Detecting host user credentials: UID=${HOST_UID}, GID=${HOST_GID}"

# Update UID and GID settings in the .env file
if grep -q "^USER_UID=" .env; then
  sed -i "s/^USER_UID=.*/USER_UID=${HOST_UID}/" .env
else
  echo "USER_UID=${HOST_UID}" >> .env
fi

if grep -q "^USER_GID=" .env; then
  sed -i "s/^USER_GID=.*/USER_GID=${HOST_GID}/" .env
else
  echo "USER_GID=${HOST_GID}" >> .env
fi

echo "Permissions synced in .env: USER_UID=${HOST_UID}, USER_GID=${HOST_GID}"
echo "Bootstrap complete! You can now run 'make build' and 'make up'."
