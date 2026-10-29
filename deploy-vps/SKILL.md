---
name: deploy-vps
description: Use when deploying a web application to a VPS with SSH, release directories, PM2, and local/remote verification. Use when the user says deploy-vps, deploy to VPS, make it live, patch release, or asks to deploy a fix to their own server.
metadata:
  short-description: Deploy a web app to a VPS
---

# VPS Deploy

Use this skill for SSH-based VPS deploys where a local Git repo is the source of truth and the remote server runs release directories plus PM2. The user or project must provide the VPS host, remote app directory, and any project-specific smoke checks.

## Always Read First

- `AGENTS.md`
- `RTK.md`
- project deploy docs such as `docs/*deploy*.md`, `README.md`, or `AGENTS.md`

Do not print secrets from local `.env*` files or remote env files.

## Choose Deploy Path

- **Project-specific deploy script**: if the target repo already has a deploy script or runbook, prefer that documented path.
- **Fast patch app deploy**: small app/code/config fixes. Use `scripts/patch_release.sh` from this skill when only a few files changed and a release-directory deploy is appropriate.
- **Full app deploy**: broad changes, package/dependency changes, migrations, or large static asset changes. Ask the user for the project-specific full deploy command if it is not documented.

Never edit the remote `current` directory directly as the source of truth. The local repo change must exist first.

## Preflight

1. Check local status with the repo's normal Git command.
2. Run focused local checks for the change, such as tests, lint, or build.
3. Verify required remote env keys without printing values when the project defines them.

Use `scripts/patch_release.sh` for fast patch deploys. On Windows, run it from Git Bash or WSL so `ssh`, `scp`, `tar`, and Bash heredocs behave consistently.

## Fast Patch Deploy Workflow

Use when only a few files changed and no large static assets need upload.

1. Build a file list from the relevant local diff. Include tests only if they are useful to run on the VPS.
2. Exclude secrets and local-only files:
   - `.env`, `.env.local`, `.env.production`
   - `.DS_Store`
   - `node_modules`, `.next`, `.git`
3. Run:

```bash
~/.codex/skills/deploy-vps/scripts/patch_release.sh \
  --repo "/path/to/repo" \
  --files-from /tmp/deploy-files.txt \
  --vps-host "$APP_VPS_HOST" \
  --app-dir "/var/www/example-app" \
  --app-name "example-app" \
  --app-subdir "frontend" \
  --env-file "/var/www/example-app/shared/frontend.env" \
  --required-env "NEXT_PUBLIC_API_URL" \
  --install-cmd "npm ci" \
  --build-cmd "npm run build" \
  --prune-cmd "npm prune --omit=dev" \
  --start-cmd "npm run start -- -p \$PORT" \
  --local-smoke-path "/" \
  --public-url "https://example.com/" \
  --test "npm test"
```

The script creates a new release from the current VPS release, overlays the small file patch, optionally verifies remote env keys, runs configured install/test/build/prune commands on the VPS, swaps `current`, reloads PM2, and smoke-tests configured local/public URLs.

## Verification

After deploy:

- configured `--public-url` checks
- configured `--local-smoke-path` checks against `127.0.0.1:<port>`
- For gated APIs, verify from an authenticated browser or run a focused server-side check on the VPS. Anonymous `curl` may return whitelist `403` in production.
- Confirm PM2 is online:
  `ssh <vps-user>@<vps-host> 'pm2 status'`

## Report Back

Tell the user:

- which deploy path was used
- release path or stamp
- checks that passed
- any warnings that remain
