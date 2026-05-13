#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
mkdir -p "$ROOT_DIR/upstream" /data/pip-cache

clone_if_missing() {
    local url="$1"
    local dir="$2"

    if [ -d "$dir/.git" ]; then
        echo "OK: $dir already exists"
    else
        git clone --filter=blob:none "$url" "$dir"
    fi
}

clone_if_missing https://github.com/InfiniTensor/ntops.git "$ROOT_DIR/upstream/ntops"
clone_if_missing https://github.com/InfiniTensor/InfiniCore.git "$ROOT_DIR/upstream/InfiniCore"

if [ ! -d "$ROOT_DIR/.venv" ]; then
    python3 -m venv --system-site-packages "$ROOT_DIR/.venv"
fi

source "$ROOT_DIR/infinitensor_env.sh"

python -m pip install -U pip
python -m pip install -e "$ROOT_DIR/upstream/ntops[testing]" pytest-xdist
python -m pip install -e "$ROOT_DIR/upstream/InfiniCore" --no-build-isolation

"$ROOT_DIR/apply_infinicore_local_patches.sh"

echo "OK: InfiniTensor local repos and Python environment are initialized."
