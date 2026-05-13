#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
mkdir -p /data/pip-cache

cd "$ROOT_DIR"
git submodule sync --recursive
git submodule update --init --recursive

if [ ! -d "$ROOT_DIR/.venv" ]; then
    python3 -m venv --system-site-packages "$ROOT_DIR/.venv"
fi

source "$ROOT_DIR/scripts/env.sh"

python -m pip install -U pip
python -m pip install -e "$ROOT_DIR/ntops[testing]" pytest-xdist
python -m pip install -e "$ROOT_DIR/InfiniCore" --no-build-isolation

"$ROOT_DIR/scripts/apply-infinicore-local-patches.sh"

echo "OK: InfiniTensor local repos and Python environment are initialized."
