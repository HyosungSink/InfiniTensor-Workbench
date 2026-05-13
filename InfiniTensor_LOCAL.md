# InfiniTensor Local Setup

This workspace was initialized from `InfiniTensor_Comp.md`.

## Layout

- `ntops`: NineToothed operator submodule, installed editable in `.venv`.
- `InfiniCore`: InfiniCore submodule.
- `.venv`: Python environment with system CUDA/PyTorch packages visible.
- `.infini`: local `INFINI_ROOT` install prefix.
- `/data/*`: build, pip, pytest, torch, and Triton caches.

## Resource Limits

Scripts use CPU affinity `taskset -c ${INFINITENSOR_CPUSET:-0-63}`, i.e. 64 of 128 vCPU on this machine. CUDA builds use `INFINITENSOR_GPU_MAX_JOBS=8` to avoid exhausting memory.

## Commands

```bash
./scripts/init-repos.sh
source ./scripts/env.sh
./scripts/apply-infinicore-local-patches.sh
./scripts/test-ntops.sh
./scripts/build-infinicore-cpu.sh
./scripts/test-infinicore-cpu-smoke.sh
./scripts/build-infinicore-nvidia.sh
./scripts/test-infinicore-nvidia-smoke.sh
```

## Notes

- Apt sources were switched to Aliyun Ubuntu mirror in `/etc/apt/sources.list.d/ubuntu.sources`; a timestamped backup exists next to it.
- `InfiniCore` points to `yunhanbb/InfiniCore:hyosungsink-sm120-build`, which includes the local xmake adaptations also stored in `patches/infinicore-sm120-xmake.patch`: remove the unused top-level Boost `add_requires`, add `sm_120`, and map RTX 5090 compute capability 12.0 to `sm_120`.
- InfiniCore CPU was configured with `--omp=n` because the container did not have OpenMP package metadata and CPU smoke tests do not require OpenMP.
- InfiniCore NVIDIA full test is intentionally not started yet per user request; only `silu` and `add` smoke tests have been run.
