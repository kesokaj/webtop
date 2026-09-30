---
owner: agent
date: 2026-09-30
---

# Local Deploy

## Build

```bash
docker buildx build --platform linux/amd64 --load -f Dockerfile.cloudrun -t webtop-test:local .
```

## Run

```bash
docker run --rm -d --name webtop-test -p 8080:8080 -e SHELL_USER=user -e SHELL_PASSWORD=user webtop-test:local
```

## Test

```bash
# Wait ~30s for KDE to boot, then:
curl -s -o /dev/null -w '%{http_code}' http://localhost:8080/
docker exec webtop-test ps aux | grep -E 'kwin|plasmashell'
```

## Stop

```bash
docker stop webtop-test
```
