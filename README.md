# AI Platform

A reusable development platform where OmniRoute, OpenDesign, Hermes, Claude Code, Antigravity, and future AI tools all share a common runtime.

## Project Principles

* **Never modify upstream projects** (OmniRoute/OpenDesign). We wrap them instead to add capabilities.
* **One source of truth** for CLI tools (Claude Code, Antigravity, future Codex/Gemini).
* **One command** to boot the platform (`docker compose up -d` or `make up`).
* **One shared workspace** for all AI apps, ensuring artifacts and context are shared.
* **One authentication store** mapped through shared volumes.
* **Designed for local WSL2 first**, but directly portable to Coolify.

---

## Roadmap

| Milestone | Objective | Status |
| :--- | :--- | :--- |
| **Milestone 1** | **Repository Foundation** | **In Progress** |
| **Milestone 2** | AI CLI base image (Claude Code + Antigravity) | Planned |
| **Milestone 3** | Shared authentication & workspace | Planned |
| **Milestone 4** | OmniRoute wrapper image | Planned |
| **Milestone 5** | OpenDesign wrapper image | Planned |
| **Milestone 6** | CLI Manager (`aicli`) | Planned |
| **Milestone 7** | Local deployment & verification | Planned |
| **Milestone 8** | Coolify deployment package | Planned |

---

## Directory Structure

```
ai-platform/
├── .env.example
├── .gitignore
├── docker-compose.yml
├── Makefile
├── README.md
│
├── images/
│   └── ai-cli-base/
│       ├── Dockerfile
│       ├── docker-compose.yml
│       ├── entrypoint.sh
│       ├── healthcheck.sh
│       └── README.md
│
├── shared/
│   ├── claude/         # Claude Code auth config
│   ├── antigravity/    # Antigravity CLI config
│   ├── workspace/      # Collaborative workspace folder
│   ├── npm/            # Persisted npm cache
│   ├── cache/          # Common CLI cache
│   ├── ssh/            # Shared host SSH keys (read-only)
│   └── config/         # Common platform config
│
├── scripts/
│   ├── bootstrap.sh    # Sync environment, create directories
│   ├── build.sh        # Build container images
│   ├── up.sh           # Launch container stack
│   ├── down.sh         # Stop and clean up containers
│   ├── verify.sh       # Healthcheck verification
│   ├── doctor.sh       # Environment diagnostic suite
│   └── update.sh       # Pull updates and rebuild
│
├── omniroute/          # OmniRoute wrapper resources (Milestone 4)
└── opendesign/         # OpenDesign wrapper resources (Milestone 5)
```

---

## Operations & Usage

### 1. Bootstrapping
Set up local workspace configurations and detect/align file system permissions:
```bash
make bootstrap
```

### 2. Building
Build the base container image:
```bash
make build
```

### 3. Startup & Shutdown
Start the services:
```bash
make up
```
Stop the services:
```bash
make down
```

### 4. Diagnostics & Verification
Run the diagnostics test suite:
```bash
make doctor
```
Verify container health:
```bash
make verify
```
