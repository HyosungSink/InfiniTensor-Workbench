# InfiniTensor 本地开发环境

这个项目沉淀 `/home/sink/InfiniTensor-Workbench` 下用于 InfiniTensor 九齿算子开发的本地初始化、构建、配置和测试流程。仓库保存 submodule 指针、InfiniCore 本地代码改动、环境配置模板和可复现脚本；虚拟环境、构建产物和日志仍由本机生成或复用。

## 当前状态

- `ntops` 已完成 editable 安装；当前 NVIDIA L4 CUDA pytest 最新记录为 `1 failed, 839 passed, 88 skipped`，失败项为 `scaled_dot_product_attention` 的一个 CUDA 参数化用例。
- `InfiniCore` CPU 版已完成配置、构建、安装和 smoke test：`silu 72/72`，`add 102/102`。
- `InfiniCore` NVIDIA 版已完成配置、构建、安装和 Python 扩展安装，当前目标 GPU 为 NVIDIA L4 / `sm_89`，driver `580.126.20`，CUDA Toolkit `12.8`。
- `InfiniCore` NVIDIA smoke test 已通过：`silu 72/72`，`add 102/102`。
- 用户要求暂缓 InfiniCore NVIDIA 全量测试，因此没有继续启动全量 runner。

详细记录见 [docs/RESULTS.md](docs/RESULTS.md)。

## 目录约定

- `ntops`：九齿算子 submodule，URL 为 `https://github.com/yunhanbb/ntops.git`。
- `InfiniCore`：InfiniCore submodule，URL 为 `https://github.com/yunhanbb/InfiniCore.git`，当前固定在可构建提交 `20857c2d`。
- `.venv`：Python 虚拟环境，使用 `--system-site-packages` 复用系统 CUDA/PyTorch。
- `.infini`：`INFINI_ROOT` 安装前缀。
- `/data/*`：pip、pytest、Triton、xmake、日志和临时目录缓存。

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

脚本会通过 `nproc` 推导默认 CPU 亲和性和并发数，也可以用 `INFINITENSOR_CPUSET`、`INFINITENSOR_GPU_MAX_JOBS`、`INFINITENSOR_PYTEST_WORKERS` 覆盖。NVIDIA 构建会优先用 `nvidia-smi` 自动识别当前 GPU compute capability；当前 L4 会配置为 `sm_89`。

## 中国国内源

当前机器的 Ubuntu apt 源已经切到阿里云镜像，备份文件保留在 `/etc/apt/sources.list.d/ubuntu.sources.*.bak`。可版本化配置保存在 `config/` 下，也可以执行：

```bash
./scripts/configure-china-mirrors.sh
```

## 本地补丁

当前 NVIDIA L4 / `sm_89` 环境不需要额外架构补丁；InfiniCore 原生支持 `sm_89`。`apply-infinicore-local-patches.sh` 默认不修改 submodule，仅在显式设置 `INFINITENSOR_INFINICORE_PATCH` 时应用指定补丁：

```bash
INFINITENSOR_INFINICORE_PATCH=/path/to/patch ./scripts/apply-infinicore-local-patches.sh
```

## GitHub 发布

本目录已按 GitHub 项目整理。发布前检查：

```bash
git status --short
git add README.md docs scripts config patches .gitignore .gitmodules package.json package-lock.json InfiniTensor_Comp.md InfiniTensor_LOCAL.md InfiniCore ntops
git commit -m "Initialize InfiniTensor local workflow"
git branch -M main
git remote add origin git@github.com:<your-id>/<repo>.git
git push -u origin main
```

不要提交 `.codex/`、`.venv/`、`.infini/`、`node_modules/` 或 `/data` 下的日志和缓存。
