# Scripts

All executable project workflows live here so the repository root stays focused on docs, config, metadata, patches, and submodules.

## Environment

- `env.sh`: shared environment variables, CUDA discovery, cache directories, Python path, and CPU affinity / parallelism defaults derived from `nproc`.
- `configure-china-mirrors.sh`: applies versioned apt, pip, and xmake/Git mirror settings for China-based downloads.
- `init-repos.sh`: initializes submodules, creates `.venv`, and installs editable Python packages.

## InfiniCore

- `apply-infinicore-local-patches.sh`: no-op for the current L4 / `sm_89` workflow unless `INFINITENSOR_INFINICORE_PATCH` points to an explicit patch.
- `build-infinicore-cpu.sh`: CPU build, install, Python extension build, and editable install.
- `build-infinicore-nvidia.sh`: NVIDIA build for CUDA / current L4 `sm_89`, install, Python extension build, and editable install.
- `test-infinicore-cpu-smoke.sh`: CPU smoke tests for `silu` and `add`.
- `test-infinicore-nvidia-smoke.sh`: NVIDIA smoke tests for `silu` and `add`.

## ntops

- `test-ntops.sh`: CUDA pytest run for ntops using `INFINITENSOR_PYTEST_WORKERS` and CPU affinity.

## Codex

- `codex-setup.sh`: writes local Codex config under `.codex/`.
- `codex-run.sh`: launches the local Codex CLI with `CODEX_HOME=.codex`.
