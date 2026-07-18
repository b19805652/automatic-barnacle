FROM node:22-bookworm-slim

# Prevent interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Install required system packages
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    git \
    python3 \
    make \
    g++ \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Dynamic user UID/GID mapping arguments
ARG USER_UID=1000
ARG USER_GID=1000

# Align container 'node' user UID/GID with host developer credentials
RUN if [ "$USER_GID" != "1000" ] || [ "$USER_UID" != "1000" ]; then \
      apt-get update && apt-get install -y --no-install-recommends shadow-utils && \
      if [ "$USER_GID" != "1000" ]; then groupmod -g "$USER_GID" node; fi && \
      if [ "$USER_UID" != "1000" ]; then usermod -u "$USER_UID" -g "$USER_GID" node; fi && \
      apt-get purge -y shadow-utils && apt-get autoremove -y && rm -rf /var/lib/apt/lists/*; \
    fi && \
    chown -R node:node /home/node

# Install Claude Code globally
RUN npm install -g @anthropic-ai/claude-code@2.1.214

# Install Antigravity CLI (agy) stub script
RUN echo '#!/usr/bin/env sh\n\
echo "Antigravity CLI (agy) - Version 1.0.0"\n\
echo "Platform Shared Runtime Agent (Active)"\n\
if [ "$#" -gt 0 ]; then\n\
  echo "Executing command: $@"\n\
fi\n\
' > /usr/local/bin/agy && \
    chmod +x /usr/local/bin/agy && \
    ln -s /usr/local/bin/agy /usr/local/bin/antigravity

# Setup operational workspaces and ownership
RUN mkdir -p /workspace && chown -R node:node /workspace

# Copy Entrypoint and Healthcheck scripts
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
COPY healthcheck.sh /usr/local/bin/healthcheck.sh
RUN chmod +x /usr/local/bin/entrypoint.sh /usr/local/bin/healthcheck.sh

# Change default directory and user
WORKDIR /workspace
USER node

# Start container keeping it alive
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
