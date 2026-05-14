#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

export INFINITENSOR_ROOT="$ROOT_DIR"
export INFINI_ROOT="$ROOT_DIR/.infini"
export VIRTUAL_ENV="$ROOT_DIR/.venv"
export PATH="$VIRTUAL_ENV/bin:$PATH"
export LD_LIBRARY_PATH="$INFINI_ROOT/lib:${LD_LIBRARY_PATH:-}"
export PYTHONPATH="$ROOT_DIR/ntops/src:$ROOT_DIR/InfiniCore/python:${PYTHONPATH:-}"

if [ -z "${INFINITENSOR_CPUSET:-}" ]; then
    if command -v nproc >/dev/null 2>&1; then
        CPU_COUNT="$(nproc)"
        CPU_THREADS="$(((CPU_COUNT * 3 + 3) / 4))"
        if [ "$CPU_THREADS" -gt 1 ]; then
            export INFINITENSOR_CPUSET="0-$((CPU_THREADS - 1))"
        else
            export INFINITENSOR_CPUSET="0"
        fi
    else
        export INFINITENSOR_CPUSET="0"
    fi
fi

if [ -z "${CUDA_HOME:-}" ]; then
    if [ -d /usr/local/cuda ]; then
        export CUDA_HOME=/usr/local/cuda
    elif [ -d /usr/local/cuda-12.8 ]; then
        export CUDA_HOME=/usr/local/cuda-12.8
    fi
fi

if [ -n "${CUDA_HOME:-}" ]; then
    export CUDA_ROOT="${CUDA_ROOT:-$CUDA_HOME}"
    export PATH="$CUDA_HOME/bin:$PATH"
    export LD_LIBRARY_PATH="$CUDA_HOME/lib64:$CUDA_HOME/targets/x86_64-linux/lib:/usr/lib/x86_64-linux-gnu:${LD_LIBRARY_PATH:-}"
    export CPATH="$CUDA_HOME/include:$CUDA_HOME/targets/x86_64-linux/include:${CPATH:-}"
    export CPLUS_INCLUDE_PATH="$CUDA_HOME/include:$CUDA_HOME/targets/x86_64-linux/include:${CPLUS_INCLUDE_PATH:-}"
fi

export TRITON_CACHE_DIR=/data/triton-cache
export XDG_CACHE_HOME=/data/xdg-cache
export TORCH_HOME=/data/torch-cache
export TMPDIR=/data/tmp
export PIP_CACHE_DIR=/data/pip-cache

export XMAKE_ROOT=y
if [ -z "${INFINITENSOR_PARALLEL_JOBS:-}" ]; then
    if command -v nproc >/dev/null 2>&1; then
        CPU_COUNT="$(nproc)"
        export INFINITENSOR_PARALLEL_JOBS="$(((CPU_COUNT * 3 + 3) / 4))"
    else
        export INFINITENSOR_PARALLEL_JOBS="1"
    fi
fi

export MAX_JOBS="${MAX_JOBS:-$INFINITENSOR_PARALLEL_JOBS}"
export INFINITENSOR_GPU_MAX_JOBS="${INFINITENSOR_GPU_MAX_JOBS:-$INFINITENSOR_PARALLEL_JOBS}"
export INFINITENSOR_PYTEST_WORKERS="${INFINITENSOR_PYTEST_WORKERS:-$INFINITENSOR_PARALLEL_JOBS}"
export CMAKE_BUILD_PARALLEL_LEVEL="${CMAKE_BUILD_PARALLEL_LEVEL:-$INFINITENSOR_PARALLEL_JOBS}"
export CTEST_PARALLEL_LEVEL="${CTEST_PARALLEL_LEVEL:-$INFINITENSOR_PARALLEL_JOBS}"
export NINJAFLAGS="${NINJAFLAGS:--j$INFINITENSOR_PARALLEL_JOBS}"
export MAKEFLAGS="${MAKEFLAGS:--j$INFINITENSOR_PARALLEL_JOBS}"
export OMP_NUM_THREADS="${OMP_NUM_THREADS:-1}"
export MKL_NUM_THREADS="${MKL_NUM_THREADS:-1}"
export CPATH="/usr/include/python3.12:${CPATH:-}"
export CPLUS_INCLUDE_PATH="/usr/include/python3.12:${CPLUS_INCLUDE_PATH:-}"

mkdir -p "$INFINI_ROOT" /data/triton-cache /data/xdg-cache /data/torch-cache /data/tmp /data/pip-cache /data/ntops-logs /data/infinicore-logs
