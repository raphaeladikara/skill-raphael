---
name: deploy-detector-judol
description: Use when deploying, releasing, restarting, debugging, or checking production for the Detector Judol / Detector Judi project (repo raphaeladikara/detector-judol, worker API api.187-77-118-208.sslip.io, dashboard detector-judol.vercel.app), or whenever a task mentions VPS 187.77.118.208 or detector-judol-vps. Also use when a deploy target is ambiguous between this project and MainSaham.
---

# Deploy Detector Judol

## Overview

Detector Judol has its **own** VPS. It is not MainSaham's VPS. The two hosts share a provider and an SSH config, so the main risk is aiming a command at the wrong one.

| | Detector Judol (this skill) | MainSaham (never from this project) |
| --- | --- | --- |
| SSH alias | `detector-judol-vps` | `mainsaham-vps` |
| IP | `187.77.118.208` | `72.61.213.235` |
| Hostname | `srv1700979` | — |
| Key | `~/.ssh/id_ed25519_detector_judol_vps` | `~/.ssh/id_ed25519_mainsaham_vps` |
| App | Docker container `detector-judol-worker`, `/opt/detector-judol` | PM2 releases |

The same VPS also runs the unrelated `thunderpull-*` containers. Never stop or prune them, and never run `docker system prune`.

## Guard (run before any remote change)

```bash
ssh detector-judol-vps 'hostname | grep -qx srv1700979 && test -d /opt/detector-judol && echo OK-detector'
```

If this does not print `OK-detector`, stop. Do not substitute `mainsaham-vps` or a raw IP.

## Normal deploy: push to main

1. Locally: `py -3.11 -m unittest discover -s tests`, `npm run test:proxy`, `npm run build`.
2. Commit, then `git push origin main`.
3. GitHub Actions (`.github/workflows/deploy.yml`) runs the tests and SSHes with a forced-command key. The key can only run `/usr/local/sbin/deploy-detector-judol <sha of origin/main>`. That script builds the image, swaps the container, health-checks it, and rolls back on failure. Vercel rebuilds the dashboard from the same push.
4. Verify that the worker runs the new SHA (gh may be logged out, so check the VPS directly):

```bash
git rev-parse HEAD
ssh detector-judol-vps 'docker inspect --format "{{.Config.Image}} {{.State.Status}} {{.State.StartedAt}}" detector-judol-worker'
```

The image tag must be `detector-judol-worker:<HEAD sha>` with status `running`. Polling for 5–10 minutes is normal while the image builds.

## Manual deploy (when Actions is down)

```bash
ssh detector-judol-vps 'SSH_ORIGINAL_COMMAND=<full 40-char sha of origin/main> /usr/local/sbin/deploy-detector-judol'
```

The SHA must already be pushed to `origin/main`; the script refuses anything else.

## Changing the deploy script itself

`scripts/deploy-vps.sh` in the repo is the source of truth, but Actions never installs it. After editing it, run the guard and then:

```bash
bash -n scripts/deploy-vps.sh
scp scripts/deploy-vps.sh detector-judol-vps:/tmp/deploy-detector-judol.new
ssh detector-judol-vps 'bash -n /tmp/deploy-detector-judol.new && cp /usr/local/sbin/deploy-detector-judol{,.bak} && install -m 755 /tmp/deploy-detector-judol.new /usr/local/sbin/deploy-detector-judol'
```

## Health checks

- API with the token, run inside the container: see the `healthy()` function in `scripts/deploy-vps.sh`.
- Running jobs: `docker exec detector-judol-worker python -c` against `/app/data/detector.sqlite3` (table `jobs`).
- Container DNS must be `1.1.1.1`. The host resolver is filtered and sends gambling domains to TrustPositif: `docker inspect --format '{{.HostConfig.Dns}}' detector-judol-worker`.

## Common mistakes

- Using `mainsaham-vps` or the `deploy-vps` (PM2) skill for this project. Neither applies here.
- Editing files inside the running container or `/opt/detector-judol/releases/*`. Change the repo, then push.
- Testing a new image on port 18080, which is production. Use another tag and port (e.g. `:e2e` on `127.0.0.1:18090`) and remove the container afterwards.
- Printing `/opt/detector-judol/worker.env` or tokens into logs.
