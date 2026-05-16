# 2026 零日提交流程

这份清单面向 2026 春季九齿算子开发赛道。当前规则强调“正确性必须满足”，且正确性都满足时按提交时间评定，因此准备重点是赛题发布后快速、稳定、可复现地提交。

## 赛题发布前

1. 保持本地环境全绿：

   ```bash
   ./scripts/init-repos.sh
   source ./scripts/env.sh
   ./scripts/test-ntops.sh
   ./scripts/test-infinicore-nvidia-smoke.sh
   ```

2. 提前准备身份变量：

   ```bash
   export INFINITENSOR_GITHUB_ID=<your-github-id>
   export INFINITENSOR_AUTHOR_NAME=<your-real-name>
   ```

3. 熟悉当前 `ntops` 的实现范式：

   - 核函数实现：`ntops/src/ntops/kernels/<op>.py`
   - PyTorch 风格封装：`ntops/src/ntops/torch/<op>.py`
   - 正确性测试：`ntops/tests/test_<op>.py`

4. 提前确定截图和日志保存方式。建议把命令输出保存到 `/data/ntops-logs`，截图内容以正式赛题要求为准。

## 赛题发布后

1. 优先选择风险最低的赛题包，而不是只选最眼熟的算子。

   最适合快速首发的组合通常以逐元素算子、广播二元算子、简单规约算子为主。遇到 `sort/topk`、`unique/nonzero`、`scatter/reduce`、卷积、池化边界、随机行为、复杂非连续布局时要更谨慎。

2. 创建比赛分支和提交文件：

   ```bash
   ./scripts/prepare-2026-submission.sh "$INFINITENSOR_GITHUB_ID" T1-1-X
   ```

   该命令会在 `ntops` 子模块中创建或切换到：

   ```text
   2026-spring-<GitHub ID>-<赛题号>
   ```

3. 如果目标算子尚不存在，用模板生成三层骨架：

   ```bash
   ./scripts/scaffold-ntops-operator.sh <op_name> unary
   ./scripts/scaffold-ntops-operator.sh <op_name> binary
   ./scripts/scaffold-ntops-operator.sh <op_name> reduction
   ```

4. 完成实现后，将新算子注册到 `ntops/src/ntops/torch/__init__.py` 和 `ntops/src/ntops/kernels/__init__.py`，然后跑定点测试：

   ```bash
   source ./scripts/env.sh
   cd ntops
   pytest -q tests/test_<op_name>.py
   ```

5. 按正式赛题要求运行整包测试。如果赛题只要求 `ntops` 结果，就跑五个算子的定点测试和必要的汇总测试；如果要求 InfiniCore 接入截图，也要补跑对应的 InfiniCore Python 测试。

## PR 内容

使用自动生成的 `PR_BODY_2026_<赛题号>.md` 作为 PR 描述基础。

命名要求：

```text
分支：2026-spring-<GitHub ID>-<赛题号>
PR 标题：[2026春季][赛题号] GitHub ID
```

必须准备：

- 每个实现平台上的测试结果截图。
- 已署名的 `HONOR_CODE.md`。
- `REFERENCE.md`。
- 简短实现说明和已知限制。

