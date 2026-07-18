FROM ai-platform-ai-cli-base:latest

# Switch to root to execute code-server installation
USER root

# Install dependencies and the official code-server deb package
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    ca-certificates \
    && curl -fsSL https://code-server.dev/install.sh | sh \
    && rm -rf /var/lib/apt/lists/*

# Pre-create config folders and align permissions for node user
RUN mkdir -p /home/node/.config/code-server && \
    chown -R node:node /home/node/.config

# Expose VS Code Web Server port
EXPOSE 8080

# Switch back to node user context
USER node

# Run code-server pointing to the shared workspace
ENTRYPOINT ["code-server", "--bind-addr", "0.0.0.0:8080", "--auth", "password", "/workspace"]
