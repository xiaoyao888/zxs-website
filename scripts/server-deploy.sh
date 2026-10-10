#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="${REPO_DIR:-/home/workspace/zxs-website}"
DIST_DIR="${DIST_DIR:-$REPO_DIR/dist}"
TARGET_DIR="${TARGET_DIR:-/home/service/zxs-website}"

cd "$REPO_DIR"

echo "[server] installing dependencies"
npm ci

echo "[server] building static site"
npm run build

if [ ! -d "$DIST_DIR" ]; then
  echo "[server] dist directory not found: $DIST_DIR" >&2
  exit 1
fi

echo "[server] deploying $DIST_DIR -> $TARGET_DIR"
mkdir -p "$TARGET_DIR"
find "$TARGET_DIR" -mindepth 1 -maxdepth 1 -exec rm -rf {} +
cp -a "$DIST_DIR"/. "$TARGET_DIR"/

echo "[server] deployment complete"