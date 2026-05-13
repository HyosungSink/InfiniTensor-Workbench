# 本地初始化、配置、构建和测试记录

记录日期：2026-05-13

## 硬件与资源策略

- CPU：128 vCPU，脚本默认绑定 `0-63`，使用约 50% vCPU。
- GPU：NVIDIA GeForce RTX 5090，compute capability 12.0，CUDA 12.8，driver 570.148.08。
- 内存：约 20 GiB，无 swap。
- NVIDIA 构建并发：`INFINITENSOR_GPU_MAX_JOBS=8`。

## 上游仓库

- `ntops`：`https://github.com/InfiniTensor/ntops.git`，当前提交 `6bc90d5`。
- `InfiniCore`：`https://github.com/InfiniTensor/InfiniCore.git`，当前提交 `90fd438`。

## ntops

命令：

```bash
./test_ntops_50.sh
```

结果：

- `840 passed, 88 skipped, 48 warnings`
- 用时：`297.48s`
- 日志：`/data/ntops-logs/pytest-20260513-064029-n8.log`

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
xmake f -y --cpu=y --omp=n --nv-gpu=y --cudnn=y --cuda=/usr/local/cuda --cuda_arch=sm_120 -cv
```

结果：

- GPU full build 完成：`[100%]: build ok, spent 151.496s`
- 安装完成。
- Python 扩展 `_infinicore` 构建和安装完成。
- `pip install -e . --no-build-isolation` 完成。

关键日志：

- `/data/infinicore-logs/xmake-config-nvidia-sm120.log`
- `/data/infinicore-logs/xmake-build-nvidia-j8-include.log`
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
- 日志：`/data/infinicore-logs/test-silu-nvidia.log`、`/data/infinicore-logs/test-add-nvidia.log`

## 暂缓项

InfiniCore NVIDIA 全量测试尚未运行。用户已明确要求先不要进行全量测试，转而沉淀当前个人文件夹配置为 GitHub 项目。
