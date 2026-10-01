# Webtop

Cloud-based KDE Plasma desktop on Google Cloud Run — a full Linux development workstation in the browser.

## Architecture

- **Ubuntu 24.04** with KDE Plasma desktop
- **KasmVNC v1.5.0** — WebP-encoded streaming with built-in web server (port 8080)
- **Pre-installed tools:** Chrome, VS Code, Antigravity CLI/2.0, kubectl, gcloud, terraform, opentofu, docker, git, gh, helm, Go, networking utilities

## Build

```bash
docker buildx build --platform linux/amd64 --load -f Dockerfile.cloudrun -t webtop:local .
```

## Run Locally

```bash
docker run --rm -d --name webtop -p 8080:8080 webtop:local

# Open http://localhost:8080
```

## Deploy to Cloud Run

```bash
# Tag and push to Artifact Registry
docker tag webtop:local \
  REGION-docker.pkg.dev/PROJECT_ID/REPO/webtop:TAG
docker push \
  REGION-docker.pkg.dev/PROJECT_ID/REPO/webtop:TAG

# Deploy (defaults baked in: user/user, port 8080)
gcloud run deploy webtop \
  --project PROJECT_ID \
  --region REGION \
  --image REGION-docker.pkg.dev/PROJECT_ID/REPO/webtop:TAG \
  --port 8080 --memory 4Gi --cpu 2 --timeout 300 \
  --no-cpu-throttling --min-instances 1 --max-instances 2 --cpu-boost \
  --execution-environment gen2 \
  --allow-unauthenticated
```

## Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `SHELL_USER` | Desktop user name | `user` |
| `SHELL_PASSWORD` | VNC password (min 6 chars, auto-padded) | `user` |
| `TZ` | Timezone | `UTC` |

## Key Files

| Path | Purpose |
|------|---------|
| `Dockerfile.cloudrun` | Full image build: Ubuntu 24.04 + KDE + KasmVNC + tools |
| `init-cloudrun.sh` | Container init script (KasmVNC + KDE desktop startup) |
