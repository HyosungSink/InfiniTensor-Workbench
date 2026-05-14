#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$ROOT_DIR/scripts/env.sh"

cd "$ROOT_DIR/InfiniCore"

xmake g --network="${INFINITENSOR_XMAKE_NETWORK:-public}" --theme=plain --cachedir=/data/xmake-cache --pkg_cachedir=/data/xmake-packages --pkg_installdir=/data/xmake-packages-installed
taskset -c "$INFINITENSOR_CPUSET" xmake f -y --cpu=y --omp=n -cv
taskset -c "$INFINITENSOR_CPUSET" xmake build -y -j"${MAX_JOBS}"
taskset -c "$INFINITENSOR_CPUSET" xmake install -y
taskset -c "$INFINITENSOR_CPUSET" xmake build -y -j"${MAX_JOBS}" _infinicore
taskset -c "$INFINITENSOR_CPUSET" xmake install -y _infinicore
python -m pip install -e . --no-build-isolation
