# InfiniTensor Workbench

本仓库是面向 InfiniTensor 九齿算子开发与 2026 春季启元人工智能大赛的本地工作区。它集中管理 `ntops`、`InfiniCore`、本地构建前缀、环境脚本、测试记录、提交模板和算子骨架模板，使初始化、构建、测试和比赛提交流程可复现。

工作区以 `InfiniCore` 官方 README 的配置、编译和测试范式为基础，并补充了本机 NVIDIA L4 环境下的自动化脚本和比赛准备流程。

`InfiniCore` 是跨平台统一编程工具集，为不同芯片平台的计算、运行时、通信等能力提供统一 C 语言接口。本工作区主要面向：

- 九齿算子库 `ntops` 的开发与测试；
- `InfiniCore` CPU 后端构建与 smoke test；
- `InfiniCore` NVIDIA 后端构建与 smoke test；
- 2026 春季赛零日提交、材料生成和算子骨架生成。

## 当前状态

- `ntops` 已完成 editable 安装；当前 NVIDIA L4 CUDA pytest 最新记录为 `840 passed, 88 skipped`。
- `InfiniCore` CPU 版已完成配置、构建、安装和 smoke test：`silu 72/72`，`add 102/102`。
- `InfiniCore` NVIDIA 版已完成配置、构建、安装和 Python 扩展安装，当前目标 GPU 为 NVIDIA L4 / `sm_89`，driver `580.126.20`，CUDA Toolkit `12.8`。
- `InfiniCore` NVIDIA smoke test 已通过：`silu 72/72`，`add 102/102`。
- 2026 春季赛零日提交流水线、`ntops` 三层结构说明和算子模板库已沉淀在 `docs/`、`templates/` 和 `scripts/`。
- InfiniCore NVIDIA 全量测试尚未启动；当前只确认到 smoke test。

详细记录见 [docs/RESULTS.md](docs/RESULTS.md)。

## 目录结构

- `ntops`：九齿算子子模块，已在 `.venv` 中 editable 安装。
- `InfiniCore`：InfiniCore 子模块，提供底层库、Python 接口和算子测试框架。
- `.venv`：Python 虚拟环境，使用 `--system-site-packages` 复用系统 CUDA/PyTorch 包。
- `.infini`：本地 `INFINI_ROOT` 安装前缀。
- `scripts/`：初始化、构建、测试、提交准备和算子骨架生成脚本。
- `templates/`：比赛提交模板和 `ntops` 算子模板。
- `docs/`：测试记录、零日提交流程和 `ntops` 三层结构说明。
- `config/`：apt、pip、Git 等本地配置模板。
- `patches/`：可选本地补丁。
- `/data/*`：pip、pytest、torch、Triton、xmake、日志和临时文件缓存。

## 项目依赖

本工作区依赖如下工具链：

- [Xmake](https://xmake.io/)：用于编译 `InfiniCore`。
- GCC 11 以上或 Clang 16 以上：需要支持 C++17。
- Python 3.10 以上。
- PyTorch：用于 `ntops` 和 InfiniCore Python 测试中的正确性对照。
- CUDA Toolkit：NVIDIA 后端构建和运行所需。

当前本机 NVIDIA 环境：

- GPU：NVIDIA L4，compute capability 8.9，即 `sm_89`。
- Driver：`580.126.20`。
- `nvidia-smi` CUDA Version：`13.0`。
- CUDA Toolkit：`12.8`，`nvcc 12.8.93`。
- `CUDA_HOME=/usr/local/cuda`。

## 初始化

首次进入工作区后执行：

```bash
./scripts/init-repos.sh
source ./scripts/env.sh
```

初始化脚本会完成：

- 同步并初始化 `ntops` 与 `InfiniCore` 子模块；
- 创建 `.venv`；
- editable 安装 `ntops`；
- editable 安装 `InfiniCore` Python 包；
- 应用显式指定的本地补丁。

环境脚本会设置：

- `INFINITENSOR_ROOT`；
- `INFINI_ROOT`；
- `VIRTUAL_ENV`；
- `PATH`；
- `LD_LIBRARY_PATH`；
- `PYTHONPATH`；
- CUDA 相关路径；
- `/data` 下的缓存和日志目录；
- CPU 亲和性与并发默认值。

## 构建与安装

`InfiniCore` 官方安装流程分为底层库、C++ 库和 Python 包三部分。本工作区已将常用路径封装为脚本。

CPU 版本：

```bash
./scripts/build-infinicore-cpu.sh
```

NVIDIA 版本：

```bash
./scripts/build-infinicore-nvidia.sh
```

NVIDIA 构建会优先通过 `nvidia-smi` 识别当前 GPU compute capability。本机 L4 会配置为 `sm_89`。

如果需要手动配置，可参考官方范式：

```bash
cd InfiniCore
xmake f -y --cpu=y --omp=n --nv-gpu=y --cudnn=y --cuda=/usr/local/cuda --cuda_arch=sm_89 -cv
xmake build
xmake install
xmake build _infinicore
xmake install _infinicore
python -m pip install -e . --no-build-isolation
```

## 测试

`ntops` CUDA 测试：

```bash
./scripts/test-ntops.sh
```

InfiniCore CPU smoke test：

```bash
./scripts/test-infinicore-cpu-smoke.sh
```

InfiniCore NVIDIA smoke test：

```bash
./scripts/test-infinicore-nvidia-smoke.sh
```

也可以直接使用 InfiniCore 官方测试入口：

```bash
cd InfiniCore

# 测试单个 InfiniCore Python 算子接口
python test/infinicore/ops/[operator].py [--bench | --debug | --verbose] [--cpu | --nvidia]

# 测试全部 InfiniCore Python 算子接口
python test/infinicore/run.py [--bench | --debug | --verbose] [--cpu | --nvidia]

# 测试单个 InfiniOP 算子
python test/infiniop/[operator].py [--cpu | --nvidia]

# 测试全部 InfiniOP 算子
python scripts/python_test.py [--cpu | --nvidia]
```

## 快速开始

```bash
./scripts/init-repos.sh
source ./scripts/env.sh
./scripts/configure-china-mirrors.sh
./scripts/test-ntops.sh
./scripts/build-infinicore-cpu.sh
./scripts/test-infinicore-cpu-smoke.sh
./scripts/build-infinicore-nvidia.sh
./scripts/test-infinicore-nvidia-smoke.sh
```

## 资源策略

脚本会通过 `nproc` 推导默认 CPU 亲和性和并发数，也可以通过环境变量覆盖：

- `INFINITENSOR_CPUSET`：控制 `taskset` 使用的 CPU 范围。
- `INFINITENSOR_GPU_MAX_JOBS`：控制 GPU 构建并发。
- `INFINITENSOR_PYTEST_WORKERS`：控制 pytest xdist worker 数量。
- `INFINITENSOR_PARALLEL_JOBS`：控制通用构建并发。

默认策略会使用约 75% CPU 线程，并设置 `OMP_NUM_THREADS=1`、`MKL_NUM_THREADS=1`，避免构建和测试时过度抢占资源。

## 国内源与缓存

当前机器的 Ubuntu apt 源已切换到阿里云镜像，备份文件保留在 `/etc/apt/sources.list.d/ubuntu.sources.*.bak`。可复用配置位于 `config/`。

可执行：

```bash
./scripts/configure-china-mirrors.sh
```

常用缓存和日志目录：

- `/data/pip-cache`
- `/data/pytest-tmp-*`
- `/data/torch-cache`
- `/data/triton-cache`
- `/data/xmake-cache`
- `/data/ntops-logs`
- `/data/infinicore-logs`

## 2026 春季赛准备

零日提交流程：

```bash
./scripts/prepare-2026-submission.sh <GitHub ID> T1-1-X
```

算子骨架生成：

```bash
./scripts/scaffold-ntops-operator.sh <op_name> unary
./scripts/scaffold-ntops-operator.sh <op_name> binary
./scripts/scaffold-ntops-operator.sh <op_name> reduction
```

相关文档：

- [docs/2026_ZERO_DAY_WORKFLOW.md](docs/2026_ZERO_DAY_WORKFLOW.md)
- [docs/NTOPS_THREE_LAYER_GUIDE.md](docs/NTOPS_THREE_LAYER_GUIDE.md)

提交模板：

- `templates/competition/HONOR_CODE.md`
- `templates/competition/REFERENCE.md`
- `templates/competition/PR_BODY_2026.md`

## 本地补丁

当前 NVIDIA L4 / `sm_89` 环境不需要额外架构补丁；InfiniCore 原生支持 `sm_89`。`apply-infinicore-local-patches.sh` 默认不修改子模块，仅在显式设置 `INFINITENSOR_INFINICORE_PATCH` 时应用指定补丁：

```bash
INFINITENSOR_INFINICORE_PATCH=/path/to/patch ./scripts/apply-infinicore-local-patches.sh
```

沐曦平台构建时仍需按比赛说明额外加 `--use-mc=y`。

## GitHub 发布

本目录已按 GitHub 项目整理。发布前检查：

```bash
git status --short
git add README.md docs scripts config patches .gitignore .gitmodules package.json package-lock.json InfiniTensor_LOCAL.md InfiniCore ntops
git commit -m "Initialize InfiniTensor local workflow"
git branch -M main
git remote add origin git@github.com:<your-id>/<repo>.git
git push -u origin main
```

不要提交 `.codex/`、`.venv/`、`.infini/`、`node_modules/` 或 `/data` 下的日志和缓存。

## 注意事项

- `ntops` 和 `InfiniCore` 是子模块；修改子模块内容后，需要分别检查子模块内部状态。
- `InfiniCore` CPU 构建使用 `--omp=n`，因为当前 smoke test 不依赖 OpenMP，且可减少环境包要求。
- 当前安装前缀、构建产物、虚拟环境和 `/data` 日志缓存均由本机生成或复用，不属于应提交内容。

