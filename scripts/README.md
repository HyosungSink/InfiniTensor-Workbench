# 脚本说明

项目中的可执行工作流统一放在这里，仓库根目录主要保留文档、配置、元数据、补丁和子模块。

## 环境

- `dev-env.sh`：统一开发环境入口。
  - `source ./scripts/dev-env.sh`：设置共享环境变量、CUDA 探测、缓存目录、Python 路径，以及由 `nproc` 推导的 CPU 亲和性和并发默认值。
  - `./scripts/dev-env.sh init`：初始化子模块，创建 `.venv`，并安装 editable Python 包。
  - `./scripts/dev-env.sh china-mirrors`：应用版本化的 apt、pip 和 Git 国内镜像配置。
  - `./scripts/dev-env.sh status`：检查当前 shell、`.venv` 和 Python 包是否已配置。

## ntops

- `test-ntops.sh`：使用 `INFINITENSOR_PYTEST_WORKERS` 和 CPU 亲和性运行 `ntops` 的 CUDA pytest。
- 代码不采用模板式开发；新增算子时按语义手写三层文件，并用 `AGENTS-2.md` 中的文件清单检查。

## InfiniCore Python 接入

2026 春季赛主线是 `ntops` / 九齿算子开发。需要验证 InfiniCore 接入时，应在
`InfiniCore` 中按具体算子运行 Python 级 `use_ntops` 测试，例如：

```bash
source ./scripts/dev-env.sh
cd InfiniCore
python test/infinicore/ops/<op>.py --nvidia
```
