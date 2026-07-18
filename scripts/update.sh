#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$WORKSPACE_ROOT"

echo "Pulling updates from git repository..."
git pull || echo "Warning: git pull was not successful (detached HEAD or offline). Continuing..."

echo "Rebuilding containers..."
docker compose build --parallel

echo "Restarting services..."
docker compose down
docker compose up -d

echo "AI Platform update completed."
