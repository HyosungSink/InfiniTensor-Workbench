# 2026 春季赛 ntops / 九齿算子开发指南

本指南是 2026 春季启元人工智能大赛 `1-1 九齿算子开发` 的开发入口。目标是在
`ntops` 中用九齿完成所选赛题包的算子实现、测试，并把完成的算子接入
`InfiniCore` Python 层的 `use_ntops` 路径，最后准备 PR 材料。

## 赛题包

| 赛题号 | 算子 |
| --- | --- |
| `T1-1-1` | `rad2deg`, `copysign`, `lcm`, `nextafter`, `lgamma` |
| `T1-1-2` | `eye`, `flatten`, `chunk`, `unbind`, `repeat` |
| `T1-1-3` | `tril`, `triu`, `triu_indices`, `trace`, `outer` |
| `T1-1-4` | `roll`, `column_stack`, `mode`, `meshgrid`, `cartesian_prod` |
| `T1-1-5` | `linspace`, `logspace`, `nan_to_num`, `logit`, `trapezoid` |
| `T1-1-6` | `tensor_split`, `unflatten`, `moveaxis`, `channel_shuffle`, `im2col` |
| `T1-1-7` | `feature_alpha_dropout`, `pixel_unshuffle`, `mse_loss`, `flip`, `fliplr` |
| `T1-1-8` | `kl_div`, `combinations`, `narrow`, `corrcoef`, `count_nonzero` |
| `T1-1-9` | `scatter_add`, `multilabel_margin_loss`, `frac`, `fractional_max_pool2d`, `fractional_max_pool3d` |
| `T1-1-10` | `gumbel_softmax`, `slice_scatter`, `slogdet`, `heaviside`, `hsplit` |

## 仓库分工

- `ntops/`: 主要开发仓库，包含九齿 kernel、`ntops.torch` wrapper、注册入口和测试。
- `InfiniCore/`: Python 接入仓库，完成 `ntops` 算子后添加或更新 `use_ntops` 路径和对应测试。
- `2026_Comp_Guideline.md`: 赛题清单、提交格式和外部参考链接。
- `scripts/`: 环境初始化、测试和比赛分支准备脚本。
- `templates/`: 比赛材料模板；代码不采用模板式开发。

开始前先确认主仓和子仓状态：

```bash
git status --short --branch
git -C ntops status --short --branch
git -C InfiniCore status --short --branch
```

加载本地环境：

```bash
source ./scripts/dev-env.sh
```

## 分支与提交格式

比赛分支命名：

```text
2026-spring-<GitHub ID>-<赛题号>
```

PR 标题命名：

```text
[2026春季][赛题号] GitHub ID
```

比赛分支和材料手动准备；本仓库不再提供自动生成提交分支或 PR 材料的脚本。

## ntops 三层实现

每个算子在 `ntops` 中按三层实现。

Kernel 层：

```text
ntops/src/ntops/kernels/<op>.py
```

职责：

- 描述张量排布和分块方式。
- 定义 NineToothed `application` 计算主体。
- 暴露 `premake(...)`，返回 `(arrangement, application, tensors)`，供
  `ninetoothed.make` 构建 kernel。

常用公共模式：

- `ntops.kernels.element_wise.arrangement`: 适合扁平逐元素 kernel。
- `ntops.kernels.reduction.arrangement`: 适合按一个或多个维度规约。
- `ninetoothed.language as ntl`: 用于数学函数、`where`、规约、类型转换和点乘等操作。

Python wrapper 层：

```text
ntops/src/ntops/torch/<op>.py
```

职责：

- 暴露 `ntops.torch.<op>`。
- 规整 Python 参数，例如 `dim`、`keepdim`、`alpha`、mask 或 `out=`。
- 分配输出张量，并显式处理 dtype、shape、device、广播和不支持的参数组合。
- 调用 `_cached_make(ntops.kernels.<op>.premake, ...)` 并启动 kernel。

测试层：

```text
ntops/tests/test_<op>.py
```

职责：

- 使用 PyTorch reference 对齐正确性；PyTorch 只能作为测试 reference。
- 覆盖 dtype、shape、device、广播、非连续布局、边界值和 `out=` 行为。
- 保持测试可复现；`ntops/tests/conftest.py` 会按模块和测试用例设置随机种子。

新增算子必须注册：

```text
ntops/src/ntops/kernels/__init__.py
ntops/src/ntops/torch/__init__.py
```

代码不采用模板式开发。新增算子时按算子语义手写 kernel、wrapper 和测试，并使用上面的
三层文件清单检查不要漏注册、漏测试或漏 InfiniCore 接入。

## 实现原则

- 按 PyTorch 对应算子的公开语义实现，但运行时不得调用 PyTorch 高层等价算子冒充 kernel。
- 可以参考项目已有算子的公共结构、helper、注册方式和测试组织方式。
- 当 reference 涉及类型提升、布尔输出、`NaN`、空张量、广播或非连续布局时，
  wrapper 和测试都要显式处理。
- 除非 PyTorch 本身也返回 `NaN`，否则避免全屏蔽行或空逻辑行产生 `NaN`。
- 简单算子尽量支持 `out=`；暂不支持的模式要用清晰断言或错误信息说明。
- 只有内核排布确实需要占位输入时，才使用 meta tensor 表示关闭的可选输入。
- 不要为了单个样例硬编码 shape、dtype、axis、参数组合或特定值域。
- 改动范围集中在当前赛题包相关算子、注册入口、测试、InfiniCore 接入和比赛材料。

## ntops 测试

单个算子至少运行：

```bash
source ./scripts/dev-env.sh
cd ntops
pytest tests/test_<op>.py -q
```

一个赛题包完成后，运行该包 5 个算子的定点测试。必要时运行完整 `ntops` 测试：

```bash
./scripts/test-ntops.sh
```

测试设计重点：

- 逐元素和比较类：标量、广播、非连续输入、`out=`、float / integer / bool 组合。
- 规约类：`dim`、负维度、`keepdim`、空张量、单例维度和 dtype 结果。
- shape 操作类：视图语义、copy 语义、非连续输入和边界维度。
- 随机或含 mask 的算子：固定随机种子，写清和 PyTorch 行为的对齐范围。
- 浮点比较使用合适的 `rtol` / `atol`；布尔和整数结果优先用精确比较。

## InfiniCore 接入

每个完成的比赛算子都要接入 InfiniCore Python 层。接入只做 `use_ntops` 路径：

- GPU 输入且 `infinicore.use_ntops` 为真时，调用 `ntops.torch.<op>`。
- 其他路径明确保留限制、复用已有合法路径或保持 unsupported。
- 不新增 InfiniOP native、pybind 或 C++ bridge 路径来替代 `ntops` 实现。
- 为接入补充或更新对应 InfiniCore Python 测试，证明开启 `use_ntops` 时会调用
  `ntops.torch.<op>` 并与 PyTorch reference 对齐。

参考模式：

```text
InfiniCore/python/infinicore/nn/functional/silu.py
```

接入后运行对应 InfiniCore Python 级测试。按算子所在模块选择实际路径，例如：

```bash
source ./scripts/dev-env.sh
cd InfiniCore
python test/infinicore/ops/<op>.py --nvidia
python test/infinicore/ops/<op>.py --cpu
```

若算子只接入 GPU `use_ntops` 路径，CPU 测试应明确保持 unsupported 或原有行为；
不要为了 CPU 测试新增 native 实现。

## 本地环境要点

当前工作区已按 NVIDIA 环境组织脚本和日志目录：

- GPU: NVIDIA L4，compute capability 8.9，即 `sm_89`。
- Driver: `580.126.20`。
- CUDA Toolkit: `12.8`，`nvcc 12.8.93`。
- 常用日志目录：`/data/ntops-logs`、`/data/infinicore-logs`。
- 常用缓存目录：`/data/pip-cache`、`/data/pytest-tmp-*`、`/data/torch-cache`、
  `/data/triton-cache`、`/data/xmake-cache`。

InfiniCore NVIDIA 配置范式：

```bash
cd InfiniCore
xmake f -y --cpu=y --omp=n --nv-gpu=y --cudnn=y --cuda=/usr/local/cuda --cuda_arch=sm_89 -cv
```

## PR 材料

PR 描述中通常需要：

- 每个实现平台上的测试结果截图。
- 已署名的 `HONOR_CODE.md`。
- `REFERENCE.md`。
- 赛题包内 5 个算子的实现说明。
- `ntops` 测试和 InfiniCore Python 级测试结果。
- 已知限制和未覆盖参数。

提交前整理：

- 赛题号和 5 个算子。
- 修改的 `ntops` 和 `InfiniCore` 文件路径。
- 每个算子的支持范围。
- 测试命令和结果。
- PyTorch 是否作为运行时实现：结论应为否；PyTorch 仅作为测试 reference。

## Git 工作流

- 先提交并推送 `ntops` 子仓。
- 再提交并推送 `InfiniCore` 子仓。
- 最后在主仓提交文档、比赛材料和子模块指针。
- 不要 stage 无关文件、缓存、日志、构建产物或他人未提交改动。

推送前检查：

```bash
git -C ntops status --short --branch
git -C InfiniCore status --short --branch
git status --short --branch
git submodule status ntops InfiniCore
```

提交信息保持简短聚焦，例如：

```text
Add ntops linspace operator
Connect linspace to InfiniCore ntops path
Prepare T1-1-5 submission materials
```
