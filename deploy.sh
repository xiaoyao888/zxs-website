#!/usr/bin/env bash
set -euo pipefail

# Build website dist, commit it to git, push, then optionally ask server
# to pull and publish the latest code.
#
# Usage:
#   ./deploy.sh
#   COMMIT_MSG="publish website changes" ./deploy.sh
#   PUSH=0 ./deploy.sh
#   REMOTE_PUBLISH=0 ./deploy.sh
#
# Optional env:
#   BUILD_CMD       default: npm run build
#   COMMIT_MSG      default: publish website dist: yyyy-mm-dd hh:mm:ss
#   PUSH            default: 1, set 0 to only commit locally
#   REMOTE          default: origin
#   BRANCH          default: current branch
#   EXTRA_ADD       extra files or directories to git add, space separated
#   SERVER_HOST     default: 47.93.21.240, empty means skip remote publish
#   SERVER_USER     default: root, required when SERVER_HOST is set
#   SERVER_PORT     default: 22
#   SERVER_SCRIPT   default: /pub-zxs-website.sh
#   REMOTE_PUBLISH  default: 1, set 0 to skip server script

BUILD_CMD="${BUILD_CMD:-npm run build}"
PUSH="${PUSH:-1}"
REMOTE="${REMOTE:-origin}"
BRANCH="${BRANCH:-$(git rev-parse --abbrev-ref HEAD)}"
COMMIT_MSG="${COMMIT_MSG:-publish website dist: $(date '+%Y-%m-%d %H:%M:%S')}"
EXTRA_ADD="${EXTRA_ADD:-}"
SERVER_HOST="${SERVER_HOST:-47.93.21.240}"
SERVER_USER="${SERVER_USER:-root}"
SERVER_PORT="${SERVER_PORT:-22}"
SERVER_SCRIPT="${SERVER_SCRIPT:-/pub-zxs-website.sh}"
REMOTE_PUBLISH="${REMOTE_PUBLISH:-1}"

if [[ "$BRANCH" == "HEAD" ]]; then
  echo "ERROR: current git state is detached HEAD; set BRANCH explicitly" >&2
  exit 1
fi

echo "==> Current branch: $BRANCH"

if [[ -n "$(git status --porcelain --untracked-files=no)" ]]; then
  echo "==> Working tree has tracked changes. They will be included only if staged below."
fi

echo "==> Installing dependencies if needed"
if [[ ! -d node_modules ]]; then
  npm ci
fi

echo "==> Building website: $BUILD_CMD"
eval "$BUILD_CMD"

echo "==> Staging dist and website source files"
git add -A -f dist
git add deploy.sh scripts src public static astro.config.mjs package.json package-lock.json postcss.config.cjs tailwind.config.cjs tsconfig.json .gitignore .gitattributes 2>/dev/null || true

if [[ -n "$EXTRA_ADD" ]]; then
  # shellcheck disable=SC2086
  git add $EXTRA_ADD
fi

if git diff --cached --quiet; then
  echo "==> Nothing to commit"
else
  echo "==> Files staged:"
  git --no-pager diff --cached --name-status

  echo "==> Creating commit"
  git commit -m "$COMMIT_MSG"
fi

if [[ "$PUSH" == "1" ]]; then
  echo "==> Pushing to $REMOTE $BRANCH"
  git push "$REMOTE" "$BRANCH"
else
  echo "==> PUSH=0, skipped git push"
fi

if [[ "$REMOTE_PUBLISH" == "1" && -n "$SERVER_HOST" ]]; then
  if [[ -z "$SERVER_USER" ]]; then
    echo "ERROR: SERVER_USER is required when SERVER_HOST is set" >&2
    exit 1
  fi

  echo "==> Running server publish script: $SERVER_USER@$SERVER_HOST:$SERVER_SCRIPT"
  ssh -p "$SERVER_PORT" "$SERVER_USER@$SERVER_HOST" "bash '$SERVER_SCRIPT'"
else
  echo "==> Remote publish skipped. Set SERVER_HOST and SERVER_USER to run server script."
fi

echo "==> Done."