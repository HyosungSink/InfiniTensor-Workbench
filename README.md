# InfiniTensor 本地开发环境

这个项目沉淀 `/root/HyosungSink` 下用于 InfiniTensor 九齿算子开发的本地初始化、构建、配置和测试流程。仓库保存 submodule 指针、InfiniCore 本地代码改动、环境配置模板和可复现脚本；虚拟环境、构建产物和日志仍由本机生成或复用。

## 当前状态

- `ntops` 已完成 editable 安装和 CUDA pytest：`840 passed, 88 skipped`。
- `InfiniCore` CPU 版已完成配置、构建、安装和 smoke test：`silu 72/72`，`add 102/102`。
- `InfiniCore` NVIDIA 版已完成配置、构建、安装和 Python 扩展安装，目标 GPU 为 RTX 5090 / `sm_120`。
- `InfiniCore` NVIDIA smoke test 已通过：`silu 72/72`，`add 102/102`。
- 用户要求暂缓 InfiniCore NVIDIA 全量测试，因此没有继续启动全量 runner。

详细记录见 [docs/RESULTS.md](docs/RESULTS.md)。

## 目录约定

- `ntops`：九齿算子 submodule，URL 为 `https://github.com/yunhanbb/ntops.git`。
- `InfiniCore`：InfiniCore submodule，URL 为 `https://github.com/yunhanbb/InfiniCore.git`，分支为 `hyosungsink-sm120-build`。
- `.venv`：Python 虚拟环境，使用 `--system-site-packages` 复用系统 CUDA/PyTorch。
- `.infini`：`INFINI_ROOT` 安装前缀。
- `/data/*`：pip、pytest、Triton、xmake、日志和临时目录缓存。

## 快速开始

```bash
./scripts/init-repos.sh
source ./scripts/env.sh
./scripts/configure-china-mirrors.sh
./scripts/apply-infinicore-local-patches.sh
./scripts/test-ntops.sh
./scripts/build-infinicore-cpu.sh
./scripts/test-infinicore-cpu-smoke.sh
./scripts/build-infinicore-nvidia.sh
./scripts/test-infinicore-nvidia-smoke.sh
```

脚本默认使用 `taskset -c 0-63`，即当前 128 vCPU 机器的 50% CPU 资源。GPU 构建默认 `INFINITENSOR_GPU_MAX_JOBS=8`，避免 20 GiB 内存环境下 C++/CUDA 编译过载。

## 中国国内源

当前机器的 Ubuntu apt 源已经切到阿里云镜像，备份文件保留在 `/etc/apt/sources.list.d/ubuntu.sources.*.bak`。可版本化配置保存在 `config/` 下，也可以执行：

```bash
./scripts/configure-china-mirrors.sh
```

## 本地补丁

RTX 5090 需要 `sm_120` 支持。这部分改动已经提交到 `yunhanbb/InfiniCore:hyosungsink-sm120-build`，主仓库通过 submodule 引用该 commit。补丁同时保存在 [patches/infinicore-sm120-xmake.patch](patches/infinicore-sm120-xmake.patch)，可用以下命令兜底应用：

```bash
./scripts/apply-infinicore-local-patches.sh
```

补丁内容：

- 移除 InfiniCore 顶层未实际使用的 Boost `add_requires`，绕过当前 xmake/xmake-repo 的 Boost stacktrace 解析问题。
- 给 `cuda_arch` 增加 `sm_120`。
- NVIDIA xmake 规则自动识别 compute capability 12.0 为 `sm_120`。

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
