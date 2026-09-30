---
owner: agent
date: 2026-09-30
---

# GCP Deploy — Cloud Run

## Defaults

| Setting | Value |
|---------|-------|
| Project | `exact-loon-6dim` |
| Region | `europe-west1` |
| Artifact Registry | `europe-north1-docker.pkg.dev/exact-loon-6dim/einherjar/webtop` |
| Service name | `webtop` |
| Service URL | `https://webtop-990141581517.europe-west1.run.app` |
| Service account | `990141581517-compute@developer.gserviceaccount.com` |
| Auth | `admin@spgo.altostrat.com` |
| Access | Public (`allUsers` has `roles/run.invoker`) |
| CPU | 4 |
| Memory | 8Gi |
| Min instances | 1 |
| Max instances | 3 |
| CPU throttling | disabled |
| Startup CPU boost | enabled |
| Port | 8080 |

## Build & Push

```bash
# Build for amd64
docker buildx build --platform linux/amd64 --load -f Dockerfile.cloudrun \
  -t europe-north1-docker.pkg.dev/exact-loon-6dim/einherjar/webtop:<TAG> .

# Push
docker push europe-north1-docker.pkg.dev/exact-loon-6dim/einherjar/webtop:<TAG>
```

## Deploy

```bash
gcloud run deploy webtop \
  --project exact-loon-6dim \
  --region europe-west1 \
  --image europe-north1-docker.pkg.dev/exact-loon-6dim/einherjar/webtop:<TAG> \
  --port 8080 --memory 8Gi --cpu 4 --timeout 300 \
  --no-cpu-throttling --min-instances 1 --max-instances 3 --cpu-boost \
  --set-env-vars SHELL_USER=user,SHELL_PASSWORD=user,TZ=Europe/Stockholm \
  --quiet
```

## Verify

```bash
curl -s -o /dev/null -w '%{http_code}' https://webtop-990141581517.europe-west1.run.app/
gcloud logging read 'resource.type="cloud_run_revision" AND resource.labels.service_name="webtop" AND textPayload:"kwin"' \
  --project exact-loon-6dim --limit 5 --freshness=5m
```

## Notes

- Org policy `iam.allowedPolicyMemberDomains` was overridden to `allValues: ALLOW` at project level.
- IAP disabled via annotation `run.googleapis.com/iap-enabled=false`.
- Image is ~1 GB compressed — first push takes ~10 min, subsequent pushes are faster (layer dedup).
