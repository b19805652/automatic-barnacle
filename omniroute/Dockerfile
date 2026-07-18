FROM diegosouzapw/omniroute:latest

# Switch to root to perform installs and credentials copies
USER root

# Install basic tool dependencies for global CLI execution
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    curl \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Copy pre-installed NPM global modules from our shared CLI base runtime
COPY --from=ai-platform-ai-cli-base:latest /home/node/.npm-global /home/node/.npm-global

# Copy the Antigravity CLI (agy) executables
COPY --from=ai-platform-ai-cli-base:latest /usr/local/bin/agy /usr/local/bin/agy
COPY --from=ai-platform-ai-cli-base:latest /usr/local/bin/antigravity /usr/local/bin/antigravity

# Configure NPM global executable path variables for the node user
ENV NPM_CONFIG_PREFIX=/home/node/.npm-global
ENV PATH=$PATH:/home/node/.npm-global/bin

# Establish the Claude credentials directory and MCP server settings symlink
RUN mkdir -p /home/node/.claude && \
    ln -sf /home/node/.claude/.claude.json /home/node/.claude.json && \
    chown -R node:node /home/node

# Restore the non-root node user context
USER node
