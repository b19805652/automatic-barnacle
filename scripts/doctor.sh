#!/usr/bin/env bash

# Exit on error
set -euo pipefail

# ANSI color codes for premium output formatting
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0;37m' # No Color

echo -e "${BLUE}=== Running AI Platform Diagnostics Suite ===${NC}\n"

errors=0
warnings=0

# Helper function to report check results
report_result() {
  local check_name="$1"
  local status="$2" # "OK", "WARN", "FAIL"
  local message="$3"

  case "$status" in
    "OK")
      echo -e "[ ${GREEN}PASS${NC} ] ${check_name}: ${message}"
      ;;
    "WARN")
      echo -e "[ ${YELLOW}WARN${NC} ] ${check_name}: ${message}"
      warnings=$((warnings + 1))
      ;;
    "FAIL")
      echo -e "[ ${RED}FAIL${NC} ] ${check_name}: ${message}"
      errors=$((errors + 1))
      ;;
  esac
}

# 1. Check Docker Daemon
if command -v docker &> /dev/null; then
  if docker info &> /dev/null; then
    report_result "Docker Daemon" "OK" "Running successfully."
  else
    report_result "Docker Daemon" "FAIL" "Docker is installed but daemon is not running. Start Docker."
  fi
else
  report_result "Docker Daemon" "FAIL" "Docker CLI is not installed on host. Please install Docker."
fi

# 2. Check WSL Integration
if [ -f /proc/version ] && (grep -qi "microsoft" /proc/version || grep -qi "wsl" /proc/version); then
  report_result "WSL Integration" "OK" "WSL2 environment detected."
else
  report_result "WSL Integration" "OK" "Native Linux environment detected."
fi

# 3. Check .env Configuration File
if [ -f .env ]; then
  report_result "Environment Configuration" "OK" ".env file exists."
  # Source the env file for subsequent checks, ignore error if missing export
  set -a
  # shellcheck disable=SC1091
  source .env || true
  set +a
else
  report_result "Environment Configuration" "FAIL" ".env file is missing. Run 'make bootstrap' first."
fi

# 4. Check Host Port Availability (if .env is available)
if [ -f .env ]; then
  ports_to_check=("OMNIROUTE_PORT" "OPENDESIGN_PORT" "VSCODE_PORT")
  for port_var in "${ports_to_check[@]}"; do
    port_val="${!port_var:-}"
    if [ -n "$port_val" ]; then
      # Test if port is in use on localhost
      if (timeout 1 bash -c "true &>/dev/null > /dev/tcp/127.0.0.1/${port_val}" 2>/dev/null); then
        # Check if the port is bound by our own container stack
        if docker compose ps | grep -q ":${port_val}"; then
          report_result "Port Availability (${port_var})" "OK" "Port ${port_val} is active (bound by this stack)."
        else
          report_result "Port Availability (${port_var})" "FAIL" "Port ${port_val} is already in use by another application."
        fi
      else
        report_result "Port Availability (${port_var})" "OK" "Port ${port_val} is available."
      fi
    else
      report_result "Port Availability (${port_var})" "WARN" "Environment variable ${port_var} is empty."
    fi
  done
fi

# 5. Check Shared Volumes Permissions
shared_dirs=("shared/workspace" "shared/claude" "shared/antigravity" "shared/npm" "shared/cache" "shared/ssh" "shared/config")
for dir in "${shared_dirs[@]}"; do
  if [ -d "$dir" ]; then
    if [ -w "$dir" ] && [ -r "$dir" ]; then
      report_result "Volume Path ($dir)" "OK" "Directory exists and is readable/writeable."
    else
      report_result "Volume Path ($dir)" "FAIL" "Directory exists but lacks read/write permissions."
    fi
  else
    report_result "Volume Path ($dir)" "FAIL" "Directory does not exist. Run 'make bootstrap' to create it."
  fi
done

# 6. Check Containerized Tool Status (Only if container stack is running)
container_running=false
if docker compose ps -q ai-cli-base &>/dev/null; then
  container_status=$(docker inspect -f '{{.State.Status}}' "$(docker compose ps -q ai-cli-base)" 2>/dev/null || echo "stopped")
  if [ "$container_status" = "running" ]; then
    container_running=true
  fi
fi

if [ "$container_running" = true ]; then
  # Check Claude Code inside container
  if docker compose exec -T ai-cli-base which claude &>/dev/null; then
    claude_ver=$(docker compose exec -T ai-cli-base claude --version | tr -d '\r\n')
    report_result "Claude Code inside Container" "OK" "Installed successfully (${claude_ver})."
  else
    report_result "Claude Code inside Container" "FAIL" "claude CLI not found in ai-cli-base container PATH."
  fi

  # Check Antigravity CLI (agy) inside container
  if docker compose exec -T ai-cli-base which agy &>/dev/null; then
    agy_ver=$(docker compose exec -T ai-cli-base agy --version | tr -d '\r\n')
    report_result "Antigravity CLI inside Container" "OK" "Installed successfully (${agy_ver})."
  else
    report_result "Antigravity CLI inside Container" "FAIL" "agy CLI not found in ai-cli-base container PATH."
  fi
else
  report_result "Container Tool Check" "WARN" "ai-cli-base container is not running. Run 'make up' to run CLI checks."
fi

# 7. Check OmniRoute CLI tools status
if docker compose ps -q omniroute &>/dev/null; then
  omniroute_status=$(docker inspect -f '{{.State.Status}}' "$(docker compose ps -q omniroute)" 2>/dev/null || echo "stopped")
  if [ "$omniroute_status" = "running" ]; then
    if docker compose exec -T omniroute which claude &>/dev/null; then
      report_result "Claude Code inside OmniRoute" "OK" "OmniRoute can locate claude."
    else
      report_result "Claude Code inside OmniRoute" "FAIL" "OmniRoute cannot locate claude."
    fi
    if docker compose exec -T omniroute which agy &>/dev/null; then
      report_result "Antigravity CLI inside OmniRoute" "OK" "OmniRoute can locate agy."
    else
      report_result "Antigravity CLI inside OmniRoute" "FAIL" "OmniRoute cannot locate agy."
    fi
  else
    report_result "OmniRoute Tool Check" "WARN" "omniroute container is not running."
  fi
else
  report_result "OmniRoute Tool Check" "WARN" "omniroute container is not defined."
fi

# 8. Check OpenDesign CLI tools status
if docker compose ps -q opendesign &>/dev/null; then
  opendesign_status=$(docker inspect -f '{{.State.Status}}' "$(docker compose ps -q opendesign)" 2>/dev/null || echo "stopped")
  if [ "$opendesign_status" = "running" ]; then
    if docker compose exec -T opendesign which claude &>/dev/null; then
      report_result "Claude Code inside OpenDesign" "OK" "OpenDesign can locate claude."
    else
      report_result "Claude Code inside OpenDesign" "WARN" "OpenDesign stub container cannot locate claude (Milestone 5 wrapper pending)."
    fi
    if docker compose exec -T opendesign which agy &>/dev/null; then
      report_result "Antigravity CLI inside OpenDesign" "OK" "OpenDesign can locate agy."
    else
      report_result "Antigravity CLI inside OpenDesign" "WARN" "OpenDesign stub container cannot locate agy (Milestone 5 wrapper pending)."
    fi
  else
    report_result "OpenDesign Tool Check" "WARN" "opendesign container is not running."
  fi
fi

# 9. Check VS Code Server CLI tools status
if docker compose ps -q vscode &>/dev/null; then
  vscode_status=$(docker inspect -f '{{.State.Status}}' "$(docker compose ps -q vscode)" 2>/dev/null || echo "stopped")
  if [ "$vscode_status" = "running" ]; then
    if docker compose exec -T vscode which claude &>/dev/null; then
      report_result "Claude Code inside VS Code" "OK" "VS Code can locate claude."
    else
      report_result "Claude Code inside VS Code" "FAIL" "VS Code cannot locate claude."
    fi
    if docker compose exec -T vscode which agy &>/dev/null; then
      report_result "Antigravity CLI inside VS Code" "OK" "VS Code can locate agy."
    else
      report_result "Antigravity CLI inside VS Code" "FAIL" "VS Code cannot locate agy."
    fi
  else
    report_result "VS Code Tool Check" "WARN" "vscode container is not running."
  fi
else
  report_result "VS Code Tool Check" "WARN" "vscode container is not defined."
fi

# Summary
echo -e "\n${BLUE}=== Diagnostics Summary ===${NC}"
echo -e "Errors detected:   ${errors}"
echo -e "Warnings detected: ${warnings}"

if [ "${errors}" -gt 0 ]; then
  echo -e "\n${RED}Status: RED. Please resolve errors before running the platform.${NC}"
  exit 1
elif [ "${warnings}" -gt 0 ]; then
  echo -e "\n${YELLOW}Status: YELLOW. Platform is runnable but may experience configuration issues.${NC}"
  exit 0
else
  echo -e "\n${GREEN}Status: GREEN. All checks passed. Platform is fully healthy!${NC}"
  exit 0
fi
