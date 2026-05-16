# 本地初始化、配置、构建和测试记录

记录日期：2026-05-16

## 硬件与资源策略

- CPU：脚本通过 `nproc` 推导默认 CPU 亲和性和并发数，可由 `INFINITENSOR_CPUSET`、`INFINITENSOR_GPU_MAX_JOBS`、`INFINITENSOR_PYTEST_WORKERS` 覆盖。
- GPU：NVIDIA L4，compute capability 8.9（`sm_89`），driver 580.126.20，`nvidia-smi` CUDA Version 13.0，CUDA Toolkit 12.8 (`nvcc 12.8.93`)。
- 内存：约 20 GiB，无 swap。
- NVIDIA 构建并发：当前环境变量记录为 `INFINITENSOR_GPU_MAX_JOBS=12`。

## 上游仓库

- `ntops`：`https://github.com/InfiniTensor/ntops.git`，当前提交 `6bc90d5`。
- `InfiniCore`：`https://github.com/InfiniTensor/InfiniCore.git`，当前提交 `20857c2d`。

## ntops

命令：

```bash
./scripts/test-ntops.sh
```

结果：

- `1 failed, 839 passed, 88 skipped, 56 warnings`
- 失败项：`tests/test_scaled_dot_product_attention.py::test_scaled_dot_product_attention[...]`
- 用时：`403.86s`（`n12` 最新记录）
- 日志：`/data/ntops-logs/pytest-20260514-053330-n12.log`

## InfiniCore CPU

配置：

```bash
xmake f -y --cpu=y --omp=n -cv
```

结果：

- C/C++ 构建和安装完成。
- Python 扩展 `_infinicore` 构建和安装完成。
- `pip install -e . --no-build-isolation` 完成。

Smoke test：

- `python test/infinicore/ops/silu.py --cpu`：`72/72 passed`
- `python test/infinicore/ops/add.py --cpu`：`102/102 passed`

## InfiniCore NVIDIA

配置：

```bash
xmake f -y --cpu=y --omp=n --nv-gpu=y --cudnn=y --cuda=/usr/local/cuda --cuda_arch=sm_89 -cv
```

结果：

- GPU full build 完成：`[100%]: build ok, spent 27.723s`（`j8` 记录）和 `[100%]: build ok, spent 14.294s`（`j12` 记录）。
- 安装完成。
- Python 扩展 `_infinicore` 构建和安装完成。
- `pip install -e . --no-build-isolation` 完成。

关键日志：

- `/data/infinicore-logs/xmake-config-nvidia-sm_89.log`
- `/data/infinicore-logs/xmake-build-nvidia-j8-include.log`
- `/data/infinicore-logs/xmake-build-nvidia-j12-include.log`
- `/data/infinicore-logs/xmake-install-nvidia.log`
- `/data/infinicore-logs/xmake-build-python-nvidia.log`
- `/data/infinicore-logs/xmake-install-python-nvidia.log`
- `/data/infinicore-logs/pip-install-editable-nvidia.log`

设备检查：

- `infinicore.get_device_count("cpu") == 1`
- `infinicore.get_device_count("cuda") == 1`

Smoke test：

- `python test/infinicore/ops/silu.py --nvidia`：`72/72 passed`
- `python test/infinicore/ops/add.py --nvidia`：`102/102 passed`
- 日志：`/data/infinicore-logs/test-silu-nvidia.log`、`/data/infinicore-logs/test-add-nvidia.log`（2026-05-16 已重跑确认）

## 暂缓项

InfiniCore NVIDIA 全量测试尚未运行。用户已明确要求先不要进行全量测试，转而沉淀当前个人文件夹配置为 GitHub 项目。
