# Webtop

Cloud-based KDE Plasma desktop on Google Cloud Run — a full Linux development workstation in the browser.

## Quick Start

```bash
# Build (amd64 for Cloud Run)
docker buildx build --platform linux/amd64 --load -f Dockerfile.cloudrun -t webtop-test:local .

# Run locally
docker run --rm -d --name webtop-test -p 8080:8080 \
  -e SHELL_USER=user -e SHELL_PASSWORD=user webtop-test:local

# Open http://localhost:8080 in your browser
```

## Architecture

- **Ubuntu 24.04** with KDE Plasma desktop
- **KasmVNC v1.5.0** — WebP-encoded streaming with built-in web server (port 8080)
- **Pre-installed tools:** Chrome, VS Code, Antigravity CLI/2.0, kubectl, gcloud, terraform, opentofu, docker, git, gh, helm, Go, networking utilities

## Deploy

Runs on Cloud Run at `https://webtop-990141581517.europe-west1.run.app`. See [`.agents/docs/deploy/gcp.md`](.agents/docs/deploy/gcp.md) for full deploy instructions.
