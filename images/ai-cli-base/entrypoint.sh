#!/usr/bin/env sh

# Exit immediately if a command exits with a non-zero status
set -eu

# Clean shut down when receiving signals from Docker
trap 'echo "Stopping container..."; exit 0' TERM INT

echo "AI Platform CLI base container initialized. Sharing workspace and caches."

# Infinite sleep loop that responds immediately to system signals
while true; do
  sleep 3600 &
  wait $!
done
