#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$ROOT_DIR/scripts/env.sh"

cd "$ROOT_DIR/ntops"

LOG="/data/ntops-logs/pytest-$(date +%Y%m%d-%H%M%S)-n${INFINITENSOR_PYTEST_WORKERS}.log"
taskset -c "$INFINITENSOR_CPUSET" pytest -q -n "$INFINITENSOR_PYTEST_WORKERS" --dist=worksteal --max-worker-restart=0 --basetemp="/data/pytest-tmp-n${INFINITENSOR_PYTEST_WORKERS}" 2>&1 | tee "$LOG"
