# Scripts

All executable project workflows live here so the repository root stays focused on docs, config, metadata, patches, and submodules.

## Environment

- `env.sh`: shared environment variables, CUDA discovery, cache directories, Python path, and 50% CPU affinity defaults.
- `configure-china-mirrors.sh`: applies versioned apt, pip, and xmake/Git mirror settings for China-based downloads.
- `init-repos.sh`: initializes submodules, creates `.venv`, and installs editable Python packages.

## InfiniCore

- `apply-infinicore-local-patches.sh`: idempotently applies the local `sm_120` xmake patch if needed.
- `build-infinicore-cpu.sh`: CPU build, install, Python extension build, and editable install.
- `build-infinicore-nvidia.sh`: NVIDIA build for CUDA / `sm_120`, install, Python extension build, and editable install.
- `test-infinicore-cpu-smoke.sh`: CPU smoke tests for `silu` and `add`.
- `test-infinicore-nvidia-smoke.sh`: NVIDIA smoke tests for `silu` and `add`.

## ntops

- `test-ntops.sh`: CUDA pytest run for ntops using 8 pytest workers and CPU affinity.

## Codex

- `codex-setup.sh`: writes local Codex config under `.codex/`.
- `codex-run.sh`: launches the local Codex CLI with `CODEX_HOME=.codex`.
