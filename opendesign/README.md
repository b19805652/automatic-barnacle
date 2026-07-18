# OpenDesign Wrapper Image

This container wraps nexu-io/open-design local daemon, compiling daemon and web scripts from source, and mounts the common AI CLI tools (`claude`, `agy`) and credentials.

## Architectural Design

1. **Compilation context**: `./scratch/open-design-repo`
2. **Base Image**: `node:22-bookworm-slim`
3. **CLI Import**: Pre-compiled node modules are copied directly from the `ai-platform-ai-cli-base:latest` image.
4. **Environment**: Adds `/home/node/.npm-global/bin` to the container `PATH` so daemon workflows can execute `claude` and `agy` naturally.

## Port Configurations

- Internal container port: `7456`
- Mapped host port: `43000` (configurable via `OPENDESIGN_PORT` in `.env`)

## Standalone Usage

### 1. Build
Build the image (must be run from the root of the open-design checkout):
```bash
docker build -f ../../opendesign/Dockerfile -t ai-opendesign .
```

### 2. Run
```bash
docker run -d --name ai-opendesign \
  -p 43000:7456 \
  -v $(pwd)/../../shared/workspace:/workspace \
  -v $(pwd)/../../shared/claude:/home/node/.claude \
  -v $(pwd)/../../shared/antigravity:/home/node/.config/antigravity \
  ai-opendesign
```
