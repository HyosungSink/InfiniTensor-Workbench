# ntops 三层结构指南

2026 春季算子赛预计以 `ntops` 为主。实现一个算子时，可以把它拆成三层来看：核函数层、PyTorch 风格封装层、测试层。

## 1. 核函数层

路径：

```text
ntops/src/ntops/kernels/<op>.py
```

职责：

- 描述张量排布和分块方式。
- 定义 NineToothed 的 `application` 计算主体。
- 暴露 `premake(...)`，返回 `(arrangement, application, tensors)`，供 `ninetoothed.make` 构建内核。

常用工具：

- `ntops.kernels.element_wise.arrangement`：适合扁平逐元素内核。
- `ntops.kernels.reduction.arrangement`：适合按一个或多个维度规约。
- `ninetoothed.language as ntl`：提供数学函数、`where`、规约、类型转换和点乘等操作。

检查点：

- 当 PyTorch reference 涉及类型提升或布尔输出时，要显式处理 dtype。
- 优化前先想清楚非连续张量和广播语义。
- 除非 PyTorch 本身也返回 `NaN`，否则要避免全屏蔽行或空逻辑行产生 `NaN`。

## 2. PyTorch 风格封装层

路径：

```text
ntops/src/ntops/torch/<op>.py
```

职责：

- 提供公开的 `ntops.torch.<op>` 接口。
- 分配 `out` 张量。
- 规整 Python 参数，例如 `dim`、`keepdim`、`alpha` 或可选 mask。
- 调用 `_cached_make(ntops.kernels.<op>.premake, ...)`。

检查点：

- 尽量匹配 PyTorch 的参数命名。
- 简单算子要保留 `out=` 行为。
- 不支持的模式要用清晰的断言说明。
- 只有当内核排布需要占位输入时，才使用 meta 张量表示关闭的可选输入。

## 3. 测试层

路径：

```text
ntops/tests/test_<op>.py
```

职责：

- 将 `ntops.torch.<op>` 与 PyTorch reference 对齐。
- 覆盖 dtype、shape、device、广播、非连续布局和边界条件。

检查点：

- 保持测试可复现；`ntops/tests/conftest.py` 会按模块和测试用例设随机种子。
- 对空行为、全屏蔽行、标量输入、单例维度、负维度等边界做定点覆盖。
- float32 使用更严格容差，float16/bfloat16 使用符合实现实际的容差。

## 注册点

新增算子后，需要同时更新两个入口：

```text
ntops/src/ntops/kernels/__init__.py
ntops/src/ntops/torch/__init__.py
```

定点测试命令：

```bash
source ./scripts/env.sh
cd ntops
pytest -q tests/test_<op>.py
```

