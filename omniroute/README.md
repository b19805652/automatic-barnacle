# OmniRoute Wrapper Image

This container builds on top of the official `diegosouzapw/omniroute:latest` image to bundle global CLI tools (`claude`, `agy`) and map shared credential stores.

## Architectural Design

1. **Base Image**: `diegosouzapw/omniroute:latest`
2. **CLI Import**: Pre-compiled node modules are copied directly from the `ai-platform-ai-cli-base:latest` image.
3. **Environment**: Adds `/home/node/.npm-global/bin` to the container `PATH` so OmniRoute processes can invoke `claude` and `agy` naturally.
4. **Volume Syncing**: Maps shared config directories at runtime to inherit dynamic logins.

## Port Configurations

- Internal container port: `20128`
- Mapped host port: `42000` (configurable via `OMNIROUTE_PORT` in `.env`)

## Standalone Usage

### 1. Build
```bash
docker build -t ai-omniroute .
```

### 2. Run
```bash
docker run -d --name ai-omniroute \
  -p 42000:20128 \
  -v $(pwd)/../shared/workspace:/workspace \
  -v $(pwd)/../shared/claude:/home/node/.claude \
  -v $(pwd)/../shared/antigravity:/home/node/.config/antigravity \
  ai-omniroute
```
