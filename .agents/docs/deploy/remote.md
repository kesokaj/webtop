---
owner: documentation
date: YYYY-MM-DD
target: remote
---
# Deploy — remote machine

A Linux box or VM reached over SSH, used only on the user's explicit request. Access details (host, user, key) come from the user and are never assumed, guessed, or committed; record aliases here, never credentials.

**Not applicable yet:** this project has no remote target. Delete this line and fill the sections when it gets one.

## Target

| Item | Value |
|---|---|
| Host alias | |
| OS / arch | |
| Service user | |
| Install path | |

## Prerequisites on the target

<!-- Runtime, service manager (systemd unit name), firewall ports, log location. -->

## Procedure

<!-- Build locally for the target's architecture, copy the artifact, install, restart, in the exact commands. -->

```bash
GOOS=linux GOARCH=amd64 go build -o dist/server ./cmd/server
scp dist/server <host>:<install path>/server.new
ssh <host> 'mv <install path>/server.new <install path>/server && sudo systemctl restart <unit>'
```

## Verify

<!-- Health check from outside, the log line that proves the new build is serving, the version it reports. -->

## Operator steps

<!-- What the operator does by hand on this target: standing procedures, never pending items (those live in the newest handoff). -->

## Rollback

<!-- Keep the previous artifact; the exact commands that put it back. -->
