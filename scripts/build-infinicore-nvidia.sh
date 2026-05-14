#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$ROOT_DIR/scripts/env.sh"

if [ -z "${CUDA_HOME:-}" ]; then
    echo "ERROR: CUDA_HOME is not set and /usr/local/cuda was not found."
    exit 1
fi

if [ -z "${CUDA_ARCH:-}" ] && command -v nvidia-smi >/dev/null 2>&1; then
    CUDA_ARCH="sm_$(nvidia-smi --query-gpu=compute_cap --format=csv,noheader | head -n1 | tr -d '.')"
fi

CUDA_ARCH="${CUDA_ARCH:-sm_120}"

"$ROOT_DIR/scripts/apply-infinicore-local-patches.sh"

cd "$ROOT_DIR/InfiniCore"

mkdir -p /data/infinicore-logs
xmake g --network="${INFINITENSOR_XMAKE_NETWORK:-public}" --theme=plain --cachedir=/data/xmake-cache --pkg_cachedir=/data/xmake-packages --pkg_installdir=/data/xmake-packages-installed
taskset -c "$INFINITENSOR_CPUSET" xmake f -y --cpu=y --omp=n --nv-gpu=y --cudnn=y --cuda="$CUDA_HOME" --cuda_arch="$CUDA_ARCH" -cv 2>&1 | tee "/data/infinicore-logs/xmake-config-nvidia-${CUDA_ARCH}.log"
taskset -c "$INFINITENSOR_CPUSET" xmake build -y -j"${INFINITENSOR_GPU_MAX_JOBS}" 2>&1 | tee "/data/infinicore-logs/xmake-build-nvidia-j${INFINITENSOR_GPU_MAX_JOBS}-include.log"
taskset -c "$INFINITENSOR_CPUSET" xmake install -y 2>&1 | tee /data/infinicore-logs/xmake-install-nvidia.log
taskset -c "$INFINITENSOR_CPUSET" xmake build -y -j"${INFINITENSOR_GPU_MAX_JOBS}" _infinicore 2>&1 | tee /data/infinicore-logs/xmake-build-python-nvidia.log
taskset -c "$INFINITENSOR_CPUSET" xmake install -y _infinicore 2>&1 | tee /data/infinicore-logs/xmake-install-python-nvidia.log
python -m pip install -e . --no-build-isolation 2>&1 | tee /data/infinicore-logs/pip-install-editable-nvidia.log
