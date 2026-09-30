# AGENTS.md

## Project Overview

Cloud-based KDE desktop environment running on Google Cloud Run, providing a full Linux development workstation accessible through a web browser. The container runs KDE Plasma over TigerVNC + noVNC (websockify on port 8080) and comes pre-installed with Chrome, VS Code, Antigravity CLI/2.0, kubectl, gcloud, terraform, opentofu, docker, git, gh, helm, Go, and networking/troubleshooting tools.

## Setup Commands

```bash
# Build (amd64 — Cloud Run target)
docker buildx build --platform linux/amd64 --load -f Dockerfile.cloudrun -t webtop-test:local .

# Run locally
docker run --rm -d --name webtop-test -p 8080:8080 -e SHELL_USER=user -e SHELL_PASSWORD=user webtop-test:local

# Test (HTTP + KDE + all tools)
curl -s -o /dev/null -w '%{http_code}' http://localhost:8080/
docker exec webtop-test ps aux | grep -E 'kwin|plasmashell'
docker exec webtop-test bash -c 'for cmd in konsole google-chrome-stable code agy kubectl gcloud terraform tofu docker git gh helm go ping dig nmap htop jq vim tmux; do which $cmd >/dev/null 2>&1 && echo "✓ $cmd" || echo "✗ $cmd"; done'

# Stop
docker stop webtop-test
```

## Architecture

- **Base image:** Ubuntu 24.04 with KDE Plasma desktop
- **Display stack:** Xtigervnc (:0, port 5900) → websockify (port 8080) → noVNC (browser)
- **Init:** `init-cloudrun.sh` — Cloud Run compatible init (no privileged mode, PAM limits disabled, dbus started manually)
- **Dockerfile.cloudrun** — full build from Ubuntu, installs KDE + all dev tools
- For ADRs, see `.agents/docs/architecture/DECISIONS.md`

## Testing

No automated test framework — verification is a local `docker run` followed by the tool check script above. Always test locally before pushing to Cloud Run.

## Deploy

- **Local:** `docker run` — see `.agents/docs/deploy/local.md`
- **GCP Cloud Run:** `exact-loon-6dim` / `europe-west1` — see `.agents/docs/deploy/gcp.md`

## Key Files

| Path | Purpose |
|------|---------|
| `Dockerfile.cloudrun` | Full Ubuntu 24.04 image build with KDE + all tools |
| `init-cloudrun.sh` | Cloud Run init script (Xtigervnc + KDE + noVNC) |
| `Dockerfile` | Original Debian base (deprecated, kept for reference) |
| `init.sh` | Original privileged-mode init (deprecated) |
| `docker-compose.yaml` | Original docker-compose (privileged mode) |
| `REQUIREMENTS.md` | Non-negotiable project requirements |
| `.agents/docs/` | All project documentation |
