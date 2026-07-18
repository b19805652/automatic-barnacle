# VS Code Server Integration

This container integrates `code-server` directly on top of the shared runtime base image `ai-cli-base`, allowing access to a fully-featured browser-based editor.

## Port Configurations

- Internal container port: `8080`
- Mapped host port: `44000` (configurable via `VSCODE_PORT` in `.env`)

## Authentication

Authentication is handled via password protection.
- Default password: `password` (configurable via `VSCODE_PASSWORD` in `.env`)

## Extension & Proxy Configuration (OmniRoute)

Since OmniRoute is running in the same Docker network `ai-platform-net`, extensions installed in this VS Code instance can communicate with OmniRoute using the internal hostname `http://omniroute:20128/v1` or via the host IP mapping `http://localhost:42000/v1`!

For example:
- Set your coding assistant extensions (e.g. Cline, Claude Dev, Cursor equivalents) API endpoint to: `http://omniroute:20128/v1`
- Select "OpenAI Compatible" or "Anthropic Compatible" model configurations inside the extension.
