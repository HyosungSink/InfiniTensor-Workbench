# InfiniTensor Local Setup

This workspace was initialized from `InfiniTensor_Comp.md`.

## Layout

- `upstream/ntops`: local NineToothed operator repo, installed editable in `.venv`.
- `upstream/InfiniCore`: local InfiniCore repo.
- `.venv`: Python environment with system CUDA/PyTorch packages visible.
- `.infini`: local `INFINI_ROOT` install prefix.
- `/data/*`: build, pip, pytest, torch, and Triton caches.

## Resource Limits

Scripts use CPU affinity `taskset -c ${INFINITENSOR_CPUSET:-0-63}`, i.e. 64 of 128 vCPU on this machine. CUDA builds use `INFINITENSOR_GPU_MAX_JOBS=8` to avoid exhausting memory.

## Commands

```bash
./init_infinitensor_repos.sh
source ./infinitensor_env.sh
./apply_infinicore_local_patches.sh
./test_ntops_50.sh
./build_infinicore_cpu_50.sh
./test_infinicore_cpu_smoke.sh
./build_infinicore_nvidia_50.sh
./test_infinicore_nvidia_smoke.sh
```

## Notes

- Apt sources were switched to Aliyun Ubuntu mirror in `/etc/apt/sources.list.d/ubuntu.sources`; a timestamped backup exists next to it.
- `upstream/InfiniCore` has local xmake adaptations stored in `patches/infinicore-sm120-xmake.patch`: remove the unused top-level Boost `add_requires`, add `sm_120`, and map RTX 5090 compute capability 12.0 to `sm_120`.
- InfiniCore CPU was configured with `--omp=n` because the container did not have OpenMP package metadata and CPU smoke tests do not require OpenMP.
- InfiniCore NVIDIA full test is intentionally not started yet per user request; only `silu` and `add` smoke tests have been run.
