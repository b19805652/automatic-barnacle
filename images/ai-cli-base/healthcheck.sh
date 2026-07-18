#!/usr/bin/env sh

# Fail if any command fails
set -e

# Verify that Node and NPM are available
command -v node >/dev/null 2>&1
command -v npm >/dev/null 2>&1

# Verify that the Claude Code CLI tool is available
command -v claude >/dev/null 2>&1

# Verify that the Antigravity CLI tool is available
command -v agy >/dev/null 2>&1

exit 0
