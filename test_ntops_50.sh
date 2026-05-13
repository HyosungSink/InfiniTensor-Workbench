#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$ROOT_DIR/infinitensor_env.sh"

cd "$ROOT_DIR/upstream/ntops"

LOG="/data/ntops-logs/pytest-$(date +%Y%m%d-%H%M%S)-n8.log"
taskset -c 0-63 pytest -q -n 8 --dist=worksteal --max-worker-restart=0 --basetemp=/data/pytest-tmp-n8 2>&1 | tee "$LOG"
