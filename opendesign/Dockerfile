# Stage 1: Build stage
FROM node:22-bookworm-slim AS build

# Prevent interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Install required system packages for pnpm compile
RUN apt-get update && apt-get install -y --no-install-recommends \
    python3 \
    make \
    g++ \
    git \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copy lockfiles and workspace configs
COPY package.json pnpm-lock.yaml pnpm-workspace.yaml ./
COPY scripts/postinstall.mjs ./scripts/postinstall.mjs
COPY packages ./packages
COPY tools ./tools
COPY apps/daemon/package.json ./apps/daemon/package.json
COPY apps/web/package.json ./apps/web/package.json
COPY e2e/package.json ./e2e/package.json

# Activate corepack and pnpm, then install dependencies
RUN corepack enable && \
    corepack prepare pnpm@10.33.2 --activate && \
    pnpm install --frozen-lockfile

# Copy application source and build daemon and web
COPY apps ./apps
RUN pnpm --filter @open-design/daemon build && \
    pnpm --filter @open-design/web build && \
    pnpm --filter @open-design/daemon deploy --legacy --prod /app/deploy/daemon

# Copy static assets required for daemon
COPY skills ./skills
COPY design-systems ./design-systems
COPY craft ./craft
COPY prompt-templates ./prompt-templates
COPY assets ./assets
COPY plugins/_official ./plugins/_official


# Stage 2: Runtime stage
FROM node:22-bookworm-slim

# Prevent interactive prompts
ENV DEBIAN_FRONTEND=noninteractive

# Install runtime utilities
RUN apt-get update && apt-get install -y --no-install-recommends \
    tini \
    poppler-utils \
    bash \
    git \
    curl \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copy daemon compiled code and dependencies
COPY --from=build /app/deploy/daemon ./apps/daemon
COPY --from=build /app/apps/web/out ./apps/web/out
COPY --from=build /app/skills ./skills
COPY --from=build /app/design-systems ./design-systems
COPY --from=build /app/craft ./craft
COPY --from=build /app/prompt-templates ./prompt-templates
COPY --from=build /app/assets/frames ./assets/frames
COPY --from=build /app/assets/community-pets ./assets/community-pets
COPY --from=build /app/plugins/_official ./plugins/_official

# Copy global npm folder and CLI executables from common base image
COPY --from=ai-platform-ai-cli-base:latest /home/node/.npm-global /home/node/.npm-global
COPY --from=ai-platform-ai-cli-base:latest /usr/local/bin/agy /usr/local/bin/agy
COPY --from=ai-platform-ai-cli-base:latest /usr/local/bin/antigravity /usr/local/bin/antigravity

# Configure NPM global prefix and PATH environment variables
ENV NPM_CONFIG_PREFIX=/home/node/.npm-global
ENV PATH=$PATH:/home/node/.npm-global/bin

# Set up Claude credentials folders and MCP symlinks
RUN mkdir -p /home/node/.claude && \
    ln -sf /home/node/.claude/.claude.json /home/node/.claude.json && \
    chown -R node:node /home/node

# Set up daemon directories
RUN mkdir -p /app/.od && \
    chown -R node:node /app

# Operational variables
ENV NODE_ENV=production
ENV NODE_OPTIONS=--max-old-space-size=192
ENV OD_BIND_HOST=0.0.0.0
ENV OD_PORT=7456

EXPOSE 7456

# Run as non-root node user
USER node

ENTRYPOINT ["/usr/bin/tini", "--"]
CMD ["node", "apps/daemon/dist/cli.js", "--no-open"]
