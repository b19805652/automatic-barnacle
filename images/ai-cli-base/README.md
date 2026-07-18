# AI CLI Base Image

This image provides the common runtime containing the CLI tools shared across all containers in the AI Platform.

## Contents

- **Node.js**: v22 LTS (slim base)
- **Utilities**: `git`, `curl`, `python3`, `make`, `g++`
- **Claude Code**: Installed globally (`claude`)
- **Antigravity CLI**: Stub command provided (`agy`, alias `antigravity`)

## Running Independently

If you want to build and run this container manually outside the main docker-compose environment, you can use these commands:

### 1. Build
```bash
docker build --build-arg USER_UID=$(id -u) --build-arg USER_GID=$(id -g) -t ai-cli-base .
```

### 2. Run
```bash
docker run -d --name ai-cli-base \
  -v $(pwd)/../../shared/workspace:/workspace \
  -v $(pwd)/../../shared/claude:/home/node/.config/claude-code \
  -v $(pwd)/../../shared/antigravity:/home/node/.config/antigravity \
  ai-cli-base
```

### 3. Exec CLI Tools
Run Claude Code inside the container:
```bash
docker exec -it ai-cli-base claude
```

Run Antigravity CLI inside the container:
```bash
docker exec -it ai-cli-base agy
```
