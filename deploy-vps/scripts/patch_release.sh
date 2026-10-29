#!/usr/bin/env bash
set -euo pipefail

REPO=""
FILES_FROM=""
VPS_HOST="${APP_VPS_HOST:-}"
VPS_USER="${APP_VPS_USER:-root}"
APP_DIR="${APP_DIR:-}"
APP_NAME="${APP_NAME:-webapp}"
APP_SUBDIR="${APP_SUBDIR:-frontend}"
PORT="3000"
ENV_FILE="${APP_ENV_FILE:-}"
REQUIRED_ENV_KEYS="${APP_REQUIRED_ENV_KEYS:-}"
TEST_COMMANDS=()
PUBLIC_URLS=()
LOCAL_SMOKE_PATHS=("/")
CUSTOM_LOCAL_SMOKE_PATHS=0
INSTALL_CMD="${APP_INSTALL_CMD:-npm ci}"
BUILD_CMD="${APP_BUILD_CMD:-npm run build}"
PRUNE_CMD="${APP_PRUNE_CMD:-npm prune --omit=dev}"
START_CMD="${APP_START_CMD:-npm run start -- -p \$PORT}"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --repo)
      REPO="$2"
      shift 2
      ;;
    --files-from)
      FILES_FROM="$2"
      shift 2
      ;;
    --vps-host)
      VPS_HOST="$2"
      shift 2
      ;;
    --vps-user)
      VPS_USER="$2"
      shift 2
      ;;
    --app-dir)
      APP_DIR="$2"
      shift 2
      ;;
    --app-name)
      APP_NAME="$2"
      shift 2
      ;;
    --app-subdir)
      APP_SUBDIR="$2"
      shift 2
      ;;
    --env-file)
      ENV_FILE="$2"
      shift 2
      ;;
    --required-env)
      REQUIRED_ENV_KEYS="$2"
      shift 2
      ;;
    --public-url)
      PUBLIC_URLS+=("$2")
      shift 2
      ;;
    --local-smoke-path)
      if [[ "$CUSTOM_LOCAL_SMOKE_PATHS" = 0 ]]; then
        LOCAL_SMOKE_PATHS=()
        CUSTOM_LOCAL_SMOKE_PATHS=1
      fi
      LOCAL_SMOKE_PATHS+=("$2")
      shift 2
      ;;
    --install-cmd)
      INSTALL_CMD="$2"
      shift 2
      ;;
    --build-cmd)
      BUILD_CMD="$2"
      shift 2
      ;;
    --prune-cmd)
      PRUNE_CMD="$2"
      shift 2
      ;;
    --start-cmd)
      START_CMD="$2"
      shift 2
      ;;
    --test)
      TEST_COMMANDS+=("$2")
      shift 2
      ;;
    --port)
      PORT="$2"
      shift 2
      ;;
    *)
      echo "Unknown argument: $1" >&2
      exit 2
      ;;
  esac
done

if [[ -z "$REPO" || -z "$FILES_FROM" || -z "$VPS_HOST" || -z "$APP_DIR" ]]; then
  echo "Usage: patch_release.sh --repo <repo> --files-from <file> --vps-host <host> --app-dir <remote-app-dir> [options]" >&2
  echo "Options: --vps-user <user> --app-name <name> --app-subdir <subdir> --env-file <remote-env-file> --required-env 'KEY1 KEY2' --public-url <url> --local-smoke-path <path> --install-cmd <cmd> --build-cmd <cmd> --prune-cmd <cmd> --start-cmd <cmd> --test <cmd> --port <port>" >&2
  echo "Alternatively set APP_VPS_HOST, APP_VPS_USER, APP_DIR, APP_NAME, APP_SUBDIR, APP_ENV_FILE, APP_REQUIRED_ENV_KEYS, APP_INSTALL_CMD, APP_BUILD_CMD, APP_PRUNE_CMD, and APP_START_CMD." >&2
  exit 2
fi

if [[ ! -d "$REPO/.git" ]]; then
  echo "Repo does not look like a git checkout: $REPO" >&2
  exit 3
fi

if [[ ! -f "$FILES_FROM" ]]; then
  echo "Missing files list: $FILES_FROM" >&2
  exit 4
fi

mapfile -t FILES < <(grep -vE '^[[:space:]]*(#|$)' "$FILES_FROM")
if [[ "${#FILES[@]}" -eq 0 ]]; then
  echo "No files listed in $FILES_FROM" >&2
  exit 5
fi

for file in "${FILES[@]}"; do
  case "$file" in
    /*|*..*|*.env|*.env.*|.git/*|*/.git/*|node_modules/*|*/node_modules/*|*/.next/*|*/.DS_Store|.DS_Store)
      echo "Refusing unsafe or local-only path: $file" >&2
      exit 6
      ;;
  esac
  if [[ ! -f "$REPO/$file" ]]; then
    echo "Listed file does not exist: $file" >&2
    exit 7
  fi
done

SSH_TARGET="$VPS_USER@$VPS_HOST"
STAMP="$(date +%Y%m%d%H%M%S)-patch"
SAFE_APP_NAME="$(printf '%s' "$APP_NAME" | tr -c 'A-Za-z0-9._-' '-')"
ARCHIVE="/tmp/${SAFE_APP_NAME}-${STAMP}.patch.tar.gz"
REMOTE_ARCHIVE="/tmp/${SAFE_APP_NAME}-${STAMP}.patch.tar.gz"

if [[ -n "$ENV_FILE" || -n "$REQUIRED_ENV_KEYS" ]]; then
  echo "==> Verify remote env"
  ssh "$SSH_TARGET" "ENV_FILE='$ENV_FILE' REQUIRED_ENV_KEYS='$REQUIRED_ENV_KEYS' bash -s" <<'REMOTE'
set -euo pipefail
required="$REQUIRED_ENV_KEYS"
if [[ -z "${ENV_FILE:-}" ]]; then
  echo "Missing --env-file while --required-env was provided"
  exit 30
fi
if [[ ! -f "$ENV_FILE" ]]; then
  echo "Missing $ENV_FILE"
  exit 31
fi
missing=""
for key in $required; do
  if ! grep -Eq "^[[:space:]]*${key}=" "$ENV_FILE"; then
    missing="$missing $key"
  fi
done
if [[ -n "$missing" ]]; then
  echo "Missing required env keys:$missing"
  exit 32
fi
for key in $required; do
  echo "$key=present"
done
REMOTE
fi

echo "==> Create patch archive"
(
  cd "$REPO"
  COPYFILE_DISABLE=1 tar --no-xattrs -czf "$ARCHIVE" "${FILES[@]}"
)
ls -lh "$ARCHIVE"

echo "==> Upload patch archive"
scp "$ARCHIVE" "$SSH_TARGET:$REMOTE_ARCHIVE"

TEST_B64=""
if [[ "${#TEST_COMMANDS[@]}" -gt 0 ]]; then
  TEST_B64="$(printf '%s\n' "${TEST_COMMANDS[@]}" | base64 | tr -d '\n')"
fi

echo "==> Deploy patch release on VPS"
ssh "$SSH_TARGET" \
  "PATCH_STAMP='$STAMP' APP_DIR='$APP_DIR' APP_NAME='$APP_NAME' APP_SUBDIR='$APP_SUBDIR' PORT='$PORT' TEST_B64='$TEST_B64' ENV_FILE='$ENV_FILE' LOCAL_SMOKE_PATHS='${LOCAL_SMOKE_PATHS[*]}' REMOTE_ARCHIVE='$REMOTE_ARCHIVE' INSTALL_CMD='$INSTALL_CMD' BUILD_CMD='$BUILD_CMD' PRUNE_CMD='$PRUNE_CMD' START_CMD='$START_CMD' bash -s" <<'REMOTE'
set -euo pipefail
CURRENT_DIR="$APP_DIR/current"
RELEASE_DIR="$APP_DIR/releases/$PATCH_STAMP"
PATCH_ARCHIVE="$REMOTE_ARCHIVE"
SHARED_DIR="$APP_DIR/shared"
APP_WORKDIR="$RELEASE_DIR/$APP_SUBDIR"
CURRENT_WORKDIR="$CURRENT_DIR/$APP_SUBDIR"

if [[ ! -d "$CURRENT_WORKDIR" ]]; then
  echo "Missing current app subdir at $CURRENT_WORKDIR"
  exit 40
fi
if [[ ! -f "$PATCH_ARCHIVE" ]]; then
  echo "Missing patch archive $PATCH_ARCHIVE"
  exit 41
fi

mkdir -p "$APP_DIR/releases"
rm -rf "$RELEASE_DIR"
mkdir -p "$RELEASE_DIR"
cp -a "$CURRENT_DIR/." "$RELEASE_DIR/"
tar -xzf "$PATCH_ARCHIVE" -C "$RELEASE_DIR"
rm -f "$PATCH_ARCHIVE"

if [[ -n "${ENV_FILE:-}" && -f "$ENV_FILE" ]]; then
  ln -sfn "$ENV_FILE" "$APP_WORKDIR/.env.production"
fi

cd "$APP_WORKDIR"
rm -rf .next
if [[ -n "${INSTALL_CMD:-}" ]]; then
  echo "==> Install: $INSTALL_CMD"
  bash -lc "$INSTALL_CMD"
fi

if [[ -n "${TEST_B64:-}" ]]; then
  while IFS= read -r test_cmd; do
    [[ -z "$test_cmd" ]] && continue
    echo "==> Test: $test_cmd"
    bash -lc "$test_cmd"
  done < <(printf '%s' "$TEST_B64" | base64 -d)
fi

if [[ -n "${BUILD_CMD:-}" ]]; then
  echo "==> Build: $BUILD_CMD"
  bash -lc "$BUILD_CMD"
fi
if [[ -n "${PRUNE_CMD:-}" ]]; then
  echo "==> Prune: $PRUNE_CMD"
  bash -lc "$PRUNE_CMD"
fi

cat > "$RELEASE_DIR/ecosystem.config.cjs" <<EOF
module.exports = {
  apps: [{
    name: "$APP_NAME",
    cwd: "$CURRENT_WORKDIR",
    script: "bash",
    args: "-lc \"$START_CMD\"",
    env: {
      NODE_ENV: "production",
      PORT: "$PORT"
    }
  }]
};
EOF

ln -sfn "$RELEASE_DIR" "$CURRENT_DIR"
pm2 startOrReload "$CURRENT_DIR/ecosystem.config.cjs" --update-env
pm2 save

for i in $(seq 1 30); do
  ok=1
  for path in $LOCAL_SMOKE_PATHS; do
    if ! curl -fsS "http://127.0.0.1:$PORT$path" >/dev/null; then
      ok=0
      break
    fi
  done
  if [[ "$ok" = 1 ]]; then
    echo "local smoke OK attempt=$i"
    break
  fi
  sleep 2
  if [[ "$i" = 30 ]]; then
    pm2 status
    pm2 logs "$APP_NAME" --lines 80 --nostream
    exit 42
  fi
done

find "$APP_DIR/releases" -mindepth 1 -maxdepth 1 -type d | sort | head -n -5 | xargs -r rm -rf
echo "release=$RELEASE_DIR"
REMOTE

if [[ "${#PUBLIC_URLS[@]}" -gt 0 ]]; then
  echo "==> Verify public URLs"
  for url in "${PUBLIC_URLS[@]}"; do
    curl -fsSI --max-time 20 "$url" >/dev/null
    echo "public smoke OK: $url"
  done
fi
