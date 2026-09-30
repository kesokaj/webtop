# Requirements

<!-- Non-negotiable project requirements. Read before every task. -->
<!-- Never modify without explicit user approval. -->

## Critical Requirements

1. Must deploy to Google Cloud Run (no privileged mode, no systemd, no SSH)
2. Must be publicly accessible — no auth required to reach the desktop
3. Must build as `linux/amd64` — Cloud Run does not support arm64
4. Default user working directory must be `$HOME/Workspace`
5. Screen must never lock or go to screensaver — user cannot re-authenticate via VNC
6. Must fill the browser window fully with dynamic resize

## Constraints

- 1 CPU / 4 Gi RAM on Cloud Run
- No GPU — all Electron apps must use `--disable-gpu --disable-software-rasterizer`
- `/dev/shm` must be mounted as 2 GB tmpfs (Electron apps crash at 64 MB default)

## Required Tools

All must be present and functional in the container:

| Category | Tools |
|----------|-------|
| Desktop | KDE Plasma, Konsole |
| Browsers | Chrome |
| Editors | VS Code, Antigravity 2.0, Antigravity CLI (`agy`) |
| Cloud | kubectl, gcloud, terraform, opentofu, helm |
| Dev | docker (CLI), git, gh, Go |
| Networking | ping, dig, nmap, traceroute, mtr, tcpdump, net-tools |
| Utils | htop, jq, vim, tmux, wget, strace, lsof |

## Taskbar Pins

Chrome, Konsole, Antigravity 2.0, VS Code must be pinned to the KDE panel.

## Out of Scope

- Multi-user support
- Persistent storage across container restarts
- GPU passthrough
