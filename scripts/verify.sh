#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$WORKSPACE_ROOT"

echo "=== AI Platform Services Status ==="
docker compose ps

echo ""
echo "=== Container Health Details ==="
container_ids=$(docker compose ps -q)
if [ -n "$container_ids" ]; then
  for id in $container_ids; do
    name=$(docker inspect --format='{{.Name}}' "$id" | sed 's/^\///')
    status=$(docker inspect --format='{{.State.Status}}' "$id")
    health=$(docker inspect --format='{{if .State.Health}}{{.State.Health.Status}}{{else}}no healthcheck{{end}}' "$id")
    echo "  Container: $name"
    echo "    Status: $status"
    echo "    Health: $health"
  done
else
  echo "No active containers running. Run 'make up' to start the platform."
fi
