# InfiniTensor Workbench

本仓库是面向 InfiniTensor 九齿算子开发与 2026 春季启元人工智能大赛的本地工作区。它集中管理 `ntops`、`InfiniCore` Python 接入、环境脚本和比赛材料模板，使初始化、测试和比赛提交流程可复现。

本工作区主要面向：

- 九齿算子库 `ntops` 的开发与测试；
- `InfiniCore` Python 层 `use_ntops` 接入；
- 2026 春季赛零日提交和材料生成。

## 当前状态

- `ntops` 已完成 editable 安装。
- `InfiniCore` Python 包已完成 editable 安装，用于比赛算子的 `use_ntops` 接入。
- 2026 春季赛提交流程和 `ntops` 三层结构说明已整理在 `AGENTS-2.md`、`templates/` 和 `scripts/`。

详细记录见 [docs/RESULTS.md](docs/RESULTS.md)。

## 目录结构

- `ntops`：九齿算子子模块，已在 `.venv` 中 editable 安装。
- `InfiniCore`：InfiniCore 子模块，提供底层库、Python 接口和算子测试框架。
- `.venv`：Python 虚拟环境，使用 `--system-site-packages` 复用系统 CUDA/PyTorch 包。
- `.infini`：本地 `INFINI_ROOT` 安装前缀。
- `scripts/`：初始化、`ntops` 测试和提交准备脚本。
- `templates/`：比赛提交材料模板；代码不采用模板式开发。
- `docs/`：测试记录、零日提交流程和 `ntops` 三层结构说明。
- `config/`：apt、pip、Git 等本地配置模板。
- `patches/`：可选本地补丁。
- `/data/*`：pip、pytest、torch、Triton、xmake、日志和临时文件缓存。

## 项目依赖

本工作区依赖如下工具链：

- Python 3.10 以上。
- PyTorch：用于 `ntops` 和 InfiniCore Python 测试中的正确性对照。
- CUDA Toolkit：运行 CUDA / Triton / NineToothed 测试所需。

当前本机 NVIDIA 环境：

- GPU：NVIDIA L4，compute capability 8.9，即 `sm_89`。
- Driver：`580.126.20`。
- `nvidia-smi` CUDA Version：`13.0`。
- CUDA Toolkit：`12.8`，`nvcc 12.8.93`。
- `CUDA_HOME=/usr/local/cuda`。

## 初始化

首次进入工作区后执行：

```bash
./scripts/dev-env.sh init
source ./scripts/dev-env.sh
```

初始化脚本会完成：

- 同步并初始化 `ntops` 与 `InfiniCore` 子模块；
- 创建 `.venv`；
- editable 安装 `ntops`；
- editable 安装 `InfiniCore` Python 包。

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

## 测试

`ntops` CUDA 测试：

```bash
./scripts/test-ntops.sh
```

InfiniCore Python `use_ntops` 接入测试按具体算子运行：

```bash
cd InfiniCore
python test/infinicore/ops/<operator>.py --nvidia
```

也可以直接使用 InfiniCore 官方测试入口：

```bash
cd InfiniCore

# 测试单个 InfiniCore Python 算子接口
python test/infinicore/ops/[operator].py [--bench | --debug | --verbose] [--cpu | --nvidia]

# 测试全部 InfiniCore Python 算子接口
python test/infinicore/run.py [--bench | --debug | --verbose] [--cpu | --nvidia]
```

## 快速开始

```bash
./scripts/dev-env.sh init
source ./scripts/dev-env.sh
./scripts/dev-env.sh china-mirrors
./scripts/test-ntops.sh
```

## 资源策略

脚本会通过 `nproc` 推导默认 CPU 亲和性和并发数，也可以通过环境变量覆盖：

- `INFINITENSOR_CPUSET`：控制 `taskset` 使用的 CPU 范围。
- `INFINITENSOR_PYTEST_WORKERS`：控制 pytest xdist worker 数量。
- `INFINITENSOR_PARALLEL_JOBS`：控制通用并发默认值。

默认策略会使用约 75% CPU 线程，并设置 `OMP_NUM_THREADS=1`、`MKL_NUM_THREADS=1`，避免构建和测试时过度抢占资源。

## 国内源与缓存

当前机器的 Ubuntu apt 源已切换到阿里云镜像，备份文件保留在 `/etc/apt/sources.list.d/ubuntu.sources.*.bak`。可复用配置位于 `config/`。

可执行：

```bash
./scripts/dev-env.sh china-mirrors
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
git -C ntops switch -c 2026-spring-<GitHub ID>-T1-1-X
```

代码开发：

- 不使用算子代码模板。
- 按每个算子的语义手写 `ntops` kernel、`ntops.torch` wrapper、测试和 InfiniCore
  `use_ntops` 接入。

相关文档：

- [AGENTS-2.md](AGENTS-2.md)

提交模板：

- `templates/competition/HONOR_CODE.md`
- `templates/competition/REFERENCE.md`
- `templates/competition/PR_BODY_2026.md`

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
- 当前安装前缀、虚拟环境和 `/data` 日志缓存均由本机生成或复用，不属于应提交内容。
