#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$ROOT_DIR/infinitensor_env.sh"

cd "$ROOT_DIR/upstream/InfiniCore"

xmake g --network=private --theme=plain --cachedir=/data/xmake-cache --pkg_cachedir=/data/xmake-packages --pkg_installdir=/data/xmake-packages-installed
taskset -c 0-63 xmake f -y --cpu=y --omp=n -cv
taskset -c 0-63 xmake build -y -j"${MAX_JOBS}"
taskset -c 0-63 xmake install -y
taskset -c 0-63 xmake build -y -j"${MAX_JOBS}" _infinicore
taskset -c 0-63 xmake install -y _infinicore
python -m pip install -e . --no-build-isolation
