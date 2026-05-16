# 脚本说明

项目中的可执行工作流统一放在这里，仓库根目录主要保留文档、配置、元数据、补丁和子模块。

## 环境

- `env.sh`：设置共享环境变量、CUDA 探测、缓存目录、Python 路径，以及由 `nproc` 推导的 CPU 亲和性和并发默认值。
- `configure-china-mirrors.sh`：应用版本化的 apt、pip、xmake 和 Git 国内镜像配置。
- `init-repos.sh`：初始化子模块，创建 `.venv`，并安装 editable Python 包。

## InfiniCore

- `apply-infinicore-local-patches.sh`：当前 L4 / `sm_89` 流程默认不修改子模块；只有在 `INFINITENSOR_INFINICORE_PATCH` 指向显式补丁时才应用。
- `build-infinicore-cpu.sh`：执行 CPU 版构建、安装、Python 扩展构建和 editable 安装。
- `build-infinicore-nvidia.sh`：执行 CUDA / 当前 L4 `sm_89` 的 NVIDIA 版构建、安装、Python 扩展构建和 editable 安装。
- `test-infinicore-cpu-smoke.sh`：运行 `silu` 和 `add` 的 CPU smoke test。
- `test-infinicore-nvidia-smoke.sh`：运行 `silu` 和 `add` 的 NVIDIA smoke test。

## ntops

- `test-ntops.sh`：使用 `INFINITENSOR_PYTEST_WORKERS` 和 CPU 亲和性运行 `ntops` 的 CUDA pytest。
- `prepare-2026-submission.sh`：在 `ntops` 中创建或切换比赛分支，并生成 `HONOR_CODE.md`、`REFERENCE.md` 和 PR 描述骨架。
- `scaffold-ntops-operator.sh`：基于本地模板生成 `ntops` 三层算子骨架。

## Codex

- `codex-setup.sh`：在 `.codex/` 下写入本地 Codex 配置。
- `codex-run.sh`：使用 `CODEX_HOME=.codex` 启动本地 Codex CLI。

