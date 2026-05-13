#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$ROOT_DIR/scripts/env.sh"

cd "$ROOT_DIR/InfiniCore"

python - <<'PY'
import infinicore
from infinicore.lib import _infinicore
import ntops

print("infinicore", infinicore.__file__)
print("_infinicore", _infinicore.__file__)
print("ntops", ntops.__file__)
print("cpu count", infinicore.get_device_count("cpu"))
PY

taskset -c "$INFINITENSOR_CPUSET" python test/infinicore/ops/silu.py --cpu
taskset -c "$INFINITENSOR_CPUSET" python test/infinicore/ops/add.py --cpu
