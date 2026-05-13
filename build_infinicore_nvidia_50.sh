#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$ROOT_DIR/infinitensor_env.sh"

if [ -z "${CUDA_HOME:-}" ]; then
    echo "ERROR: CUDA_HOME is not set and /usr/local/cuda was not found."
    exit 1
fi

"$ROOT_DIR/apply_infinicore_local_patches.sh"

cd "$ROOT_DIR/upstream/InfiniCore"

mkdir -p /data/infinicore-logs
xmake g --network=private --theme=plain --cachedir=/data/xmake-cache --pkg_cachedir=/data/xmake-packages --pkg_installdir=/data/xmake-packages-installed
taskset -c "$INFINITENSOR_CPUSET" xmake f -y --cpu=y --omp=n --nv-gpu=y --cudnn=y --cuda="$CUDA_HOME" --cuda_arch="${CUDA_ARCH:-sm_120}" -cv 2>&1 | tee /data/infinicore-logs/xmake-config-nvidia-sm120.log
taskset -c "$INFINITENSOR_CPUSET" xmake build -y -j"${INFINITENSOR_GPU_MAX_JOBS}" 2>&1 | tee /data/infinicore-logs/xmake-build-nvidia-j8-include.log
taskset -c "$INFINITENSOR_CPUSET" xmake install -y 2>&1 | tee /data/infinicore-logs/xmake-install-nvidia.log
taskset -c "$INFINITENSOR_CPUSET" xmake build -y -j"${INFINITENSOR_GPU_MAX_JOBS}" _infinicore 2>&1 | tee /data/infinicore-logs/xmake-build-python-nvidia.log
taskset -c "$INFINITENSOR_CPUSET" xmake install -y _infinicore 2>&1 | tee /data/infinicore-logs/xmake-install-python-nvidia.log
python -m pip install -e . --no-build-isolation 2>&1 | tee /data/infinicore-logs/pip-install-editable-nvidia.log
