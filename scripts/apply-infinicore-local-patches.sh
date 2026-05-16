#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PATCH_FILE="${INFINITENSOR_INFINICORE_PATCH:-}"
INFINICORE_DIR="$ROOT_DIR/InfiniCore"

if [ -z "$PATCH_FILE" ]; then
    echo "OK: current NVIDIA L4 / sm_89 workflow does not require a local InfiniCore patch."
    exit 0
fi

if ! git -C "$INFINICORE_DIR" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    echo "ERROR: InfiniCore repo not found at $INFINICORE_DIR"
    echo "Run ./scripts/init-repos.sh first."
    exit 1
fi

if git -C "$INFINICORE_DIR" apply --reverse --check "$PATCH_FILE" >/dev/null 2>&1; then
    echo "OK: InfiniCore local patch is already applied."
    exit 0
fi

git -C "$INFINICORE_DIR" apply --check "$PATCH_FILE"
git -C "$INFINICORE_DIR" apply "$PATCH_FILE"
echo "OK: applied $PATCH_FILE"
