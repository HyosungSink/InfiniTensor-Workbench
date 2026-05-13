#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$ROOT_DIR/infinitensor_env.sh"

cd "$ROOT_DIR/upstream/InfiniCore"

python - <<'PY'
import infinicore
from infinicore.lib import _infinicore

print("infinicore", infinicore.__file__)
print("_infinicore", _infinicore.__file__)
print("cpu count", infinicore.get_device_count("cpu"))
print("cuda count", infinicore.get_device_count("cuda"))
PY

mkdir -p /data/infinicore-logs
taskset -c "$INFINITENSOR_CPUSET" python test/infinicore/ops/silu.py --nvidia 2>&1 | tee /data/infinicore-logs/test-silu-nvidia.log
taskset -c "$INFINITENSOR_CPUSET" python test/infinicore/ops/add.py --nvidia 2>&1 | tee /data/infinicore-logs/test-add-nvidia.log
