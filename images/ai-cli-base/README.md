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

---

## Upgrade Path

### Pinning and Updating CLI Tools
To upgrade or downgrade global CLI tools like Claude Code without altering the container image layers:
1. Locate the root `.env` configuration file.
2. Edit the version variable (e.g. `CLAUDE_CODE_VERSION=2.1.214`). You can specify an exact version or `latest`.
3. Rebuild and restart the container to apply the changes:
   ```bash
   make build && make up
   ```

---

## Troubleshooting Guide

### 1. Permission Denied Errors in Shared Workspace
If you see permission errors when editing workspace files inside the container or on the host:
- This is caused by mismatched UIDs/GIDs.
- Run `make bootstrap` on the host to sync your host UID/GID into the `.env` configuration file, then run `make down && make up`.
- If the permissions are already messed up, clean the directories on the host:
  ```bash
  sudo chown -R $USER:$USER shared/
  ```

### 2. DNS Name Resolution Failures during Build
If `apt-get` or `npm` commands fail during docker build due to host internet resolution:
- The build targets have `network: host` configured by default in `docker-compose.yml` to resolve WSL2/Linux DNS bridging issues.
- Confirm your host system is online and can resolve external hosts (`ping deb.debian.org`).

### 3. Shared Directory Mount Failures
If config changes (like Claude credentials) do not persist across restarts:
- Confirm that the `shared/` directories are mapped as bind mounts on the host and contain the `.gitkeep` placeholders.
- Verify that your local volume paths in the `.env` file point to valid directories.

