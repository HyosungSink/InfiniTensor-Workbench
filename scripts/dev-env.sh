#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

path_has() {
    local list="${1:-}"
    local item="$2"
    case ":$list:" in
        *":$item:"*) return 0 ;;
        *) return 1 ;;
    esac
}

prepend_path_once() {
    local var_name="$1"
    local item="$2"
    local current="${!var_name:-}"

    if [ -z "$item" ] || path_has "$current" "$item"; then
        return 0
    fi

    if [ -n "$current" ]; then
        export "$var_name=$item:$current"
    else
        export "$var_name=$item"
    fi
}

detect_cuda_home() {
    if [ -n "${CUDA_HOME:-}" ]; then
        return 0
    fi

    if [ -d /usr/local/cuda ]; then
        export CUDA_HOME=/usr/local/cuda
    elif [ -d /usr/local/cuda-12.8 ]; then
        export CUDA_HOME=/usr/local/cuda-12.8
    fi
}

default_parallel_jobs() {
    if [ -n "${INFINITENSOR_PARALLEL_JOBS:-}" ]; then
        return 0
    fi

    if command -v nproc >/dev/null 2>&1; then
        CPU_COUNT="$(nproc)"
        export INFINITENSOR_PARALLEL_JOBS="$(((CPU_COUNT * 3 + 3) / 4))"
    else
        export INFINITENSOR_PARALLEL_JOBS="1"
    fi
}

default_cpuset() {
    if [ -n "${INFINITENSOR_CPUSET:-}" ]; then
        return 0
    fi

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
}

env_ready() {
    [ "${INFINITENSOR_ROOT:-}" = "$ROOT_DIR" ] || return 1
    [ "${INFINI_ROOT:-}" = "$ROOT_DIR/.infini" ] || return 1
    [ "${VIRTUAL_ENV:-}" = "$ROOT_DIR/.venv" ] || return 1
    path_has "${PATH:-}" "$ROOT_DIR/.venv/bin" || return 1
    path_has "${LD_LIBRARY_PATH:-}" "$ROOT_DIR/.infini/lib" || return 1
    path_has "${PYTHONPATH:-}" "$ROOT_DIR/ntops/src" || return 1
    path_has "${PYTHONPATH:-}" "$ROOT_DIR/InfiniCore/python" || return 1
    [ "${TRITON_CACHE_DIR:-}" = "/data/triton-cache" ] || return 1
    [ "${PIP_CACHE_DIR:-}" = "/data/pip-cache" ] || return 1
    [ -n "${INFINITENSOR_CPUSET:-}" ] || return 1
    [ -n "${INFINITENSOR_PARALLEL_JOBS:-}" ] || return 1
    [ -n "${INFINITENSOR_PYTEST_WORKERS:-}" ] || return 1
    return 0
}

ensure_cache_dirs() {
    mkdir -p "$ROOT_DIR/.infini" /data/triton-cache /data/xdg-cache /data/torch-cache \
        /data/tmp /data/pip-cache /data/ntops-logs /data/infinicore-logs
}

setup_env() {
    if env_ready; then
        ensure_cache_dirs
        return 0
    fi

    export INFINITENSOR_ROOT="$ROOT_DIR"
    export INFINI_ROOT="$ROOT_DIR/.infini"
    export VIRTUAL_ENV="$ROOT_DIR/.venv"

    prepend_path_once PATH "$VIRTUAL_ENV/bin"
    prepend_path_once PYTHONPATH "$ROOT_DIR/ntops/src"
    prepend_path_once PYTHONPATH "$ROOT_DIR/InfiniCore/python"
    prepend_path_once LD_LIBRARY_PATH "$INFINI_ROOT/lib"

    detect_cuda_home
    if [ -n "${CUDA_HOME:-}" ]; then
        export CUDA_ROOT="${CUDA_ROOT:-$CUDA_HOME}"
        prepend_path_once PATH "$CUDA_HOME/bin"
        prepend_path_once LD_LIBRARY_PATH "$CUDA_HOME/lib64"
        prepend_path_once LD_LIBRARY_PATH "$CUDA_HOME/targets/x86_64-linux/lib"
        prepend_path_once LD_LIBRARY_PATH "/usr/lib/x86_64-linux-gnu"
        prepend_path_once CPATH "$CUDA_HOME/include"
        prepend_path_once CPATH "$CUDA_HOME/targets/x86_64-linux/include"
        prepend_path_once CPLUS_INCLUDE_PATH "$CUDA_HOME/include"
        prepend_path_once CPLUS_INCLUDE_PATH "$CUDA_HOME/targets/x86_64-linux/include"
    fi

    prepend_path_once CPATH "/usr/include/python3.12"
    prepend_path_once CPLUS_INCLUDE_PATH "/usr/include/python3.12"

    export TRITON_CACHE_DIR=/data/triton-cache
    export XDG_CACHE_HOME=/data/xdg-cache
    export TORCH_HOME=/data/torch-cache
    export TMPDIR=/data/tmp
    export PIP_CACHE_DIR=/data/pip-cache
    export XMAKE_ROOT=y

    default_cpuset
    default_parallel_jobs

    export MAX_JOBS="${MAX_JOBS:-$INFINITENSOR_PARALLEL_JOBS}"
    export INFINITENSOR_GPU_MAX_JOBS="${INFINITENSOR_GPU_MAX_JOBS:-$INFINITENSOR_PARALLEL_JOBS}"
    export INFINITENSOR_PYTEST_WORKERS="${INFINITENSOR_PYTEST_WORKERS:-$INFINITENSOR_PARALLEL_JOBS}"
    export CMAKE_BUILD_PARALLEL_LEVEL="${CMAKE_BUILD_PARALLEL_LEVEL:-$INFINITENSOR_PARALLEL_JOBS}"
    export CTEST_PARALLEL_LEVEL="${CTEST_PARALLEL_LEVEL:-$INFINITENSOR_PARALLEL_JOBS}"
    export NINJAFLAGS="${NINJAFLAGS:--j$INFINITENSOR_PARALLEL_JOBS}"
    export MAKEFLAGS="${MAKEFLAGS:--j$INFINITENSOR_PARALLEL_JOBS}"
    export OMP_NUM_THREADS="${OMP_NUM_THREADS:-1}"
    export MKL_NUM_THREADS="${MKL_NUM_THREADS:-1}"

    ensure_cache_dirs
}

copy_if_changed() {
    local src="$1"
    local dst="$2"

    if [ -f "$dst" ] && cmp -s "$src" "$dst"; then
        return 1
    fi

    if [ -f "$dst" ]; then
        cp "$dst" "$dst.bak.$(date +%Y%m%d-%H%M%S)"
    fi
    cp "$src" "$dst"
    return 0
}

git_config_if_needed() {
    local key="$1"
    local value="$2"

    if [ "$(git config --global --get "$key" || true)" = "$value" ]; then
        return 1
    fi

    git config --global "$key" "$value"
    return 0
}

configure_china_mirrors() {
    local changed=0

    if [ -w /etc/apt/sources.list.d ]; then
        APT_TARGET=/etc/apt/sources.list.d/ubuntu.sources
        if copy_if_changed "$ROOT_DIR/config/apt/ubuntu.sources.aliyun" "$APT_TARGET"; then
            apt-get update
            changed=1
        fi
    else
        echo "WARN: cannot write apt sources; run as root to install config/apt/ubuntu.sources.aliyun"
    fi

    git_config_if_needed url.https://github.insteadOf git://github && changed=1
    git_config_if_needed url.https://gitee.com/xmake-mirror/.insteadOf https://github.com/xmake-mirror/ && changed=1
    git_config_if_needed url.https://gitee.com/tboox/xmake-repo.git.insteadOf https://github.com/xmake-io/xmake-repo.git && changed=1

    mkdir -p "$HOME/.config/pip"
    copy_if_changed "$ROOT_DIR/config/pip/pip.conf.china-example" "$HOME/.config/pip/pip.conf" && changed=1

    if [ "$changed" -eq 0 ]; then
        echo "OK: China mirror settings are already configured."
    else
        echo "OK: configured China mirror settings."
    fi
}

python_packages_ready() {
    setup_env
    python - <<'PY' >/dev/null 2>&1
import ntops
import infinicore
import pytest
import xdist
PY
}

install_python_packages() {
    if python_packages_ready; then
        echo "OK: editable Python packages are already available."
        return 0
    fi

    python -m pip install -U pip
    python -m pip install -e "$ROOT_DIR/ntops[testing]" pytest-xdist
    python -m pip install -e "$ROOT_DIR/InfiniCore" --no-build-isolation
}

init_repos() {
    cd "$ROOT_DIR"
    git submodule sync --recursive
    git submodule update --init --recursive

    if [ ! -d "$ROOT_DIR/.venv" ]; then
        python3 -m venv --system-site-packages "$ROOT_DIR/.venv"
    fi

    setup_env
    install_python_packages

    echo "OK: InfiniTensor ntops development environment is initialized."
}

status() {
    if env_ready; then
        echo "environment: ready"
    else
        echo "environment: not configured in this shell"
    fi

    if [ -d "$ROOT_DIR/.venv" ]; then
        echo "venv: present"
    else
        echo "venv: missing"
    fi

    if python_packages_ready; then
        echo "python packages: ready"
    else
        echo "python packages: missing"
    fi
}

usage() {
    cat <<'USAGE'
Usage:
  source ./scripts/dev-env.sh        Set environment variables in the current shell.
  ./scripts/dev-env.sh init          Initialize submodules, .venv, and editable Python packages.
  ./scripts/dev-env.sh china-mirrors Configure apt, pip, and Git mirror settings if needed.
  ./scripts/dev-env.sh status        Show whether the environment is already configured.
  ./scripts/dev-env.sh help          Show this help.
USAGE
}

if [[ "${BASH_SOURCE[0]}" != "$0" ]]; then
    setup_env
    return 0
fi

case "${1:-help}" in
    init)
        init_repos
        ;;
    china-mirrors)
        configure_china_mirrors
        ;;
    status)
        status
        ;;
    help|-h|--help)
        usage
        ;;
    *)
        echo "error: unknown command: $1" >&2
        usage >&2
        exit 2
        ;;
esac
