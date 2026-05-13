# 2026 春季启元人工智能大赛比赛要求：九齿算子开发（1-1-X 系列）

九齿算子开发系列共提供 50 个算子，共打包成 **10 个赛题**。选手可自由选择赛题数量，但每个赛题报名有上限。具体规则将会在之后补充。

### 优胜规则

- 赢者通吃，即每个算子赛题仅有一支队伍获奖。
- 保证正确性（必须）。
- 均正确的情况下，根据提交时间评定，提交时间最早的队伍胜出。
- 若有任何疑惑、不确定的界定范围或特殊情况，请及时咨询赛题组。

### 提交方式

九齿算子实现需向 [ntops](https://github.com/InfiniTensor/ntops) 仓库提交 PR。

- 分支命名需命名为：`2026-spring-<GitHub ID>-<赛题号>`
- 示例：ID 为 `ABC` 的选手选择并提交 `T1-1-1` 赛题，则该分支需命名为：`2026-spring-ABC-T1-1-1`
- PR 命名规范：`[2026春季][赛题号] GitHub ID`
- PR 描述中需附上：
  - 该赛题在每个实现的平台上的测试结果截图
  - 署名的 `HONOR_CODE.md` 和其中提及的 `REFERENCE.md`

## 九齿与 InfiniCore 相关教程

### 九源统一领域编程语言：九齿（NineToothed）

- 九齿文档：https://gxtctab8no8.feishu.cn/wiki/RSZSwpc9siOEXrkUoVyc2lPtnX3

关于使用九齿完成算子并接入 InfiniCore 的流程：

1. 本地拉取九齿算子库 [ntops](https://github.com/InfiniTensor/ntops)，并安装 `pip install -e .`
2. 在 `ntops` 中完成算子的实现。
3. 九齿算子接入 InfiniCore Python 接口可以参考：[InfiniCore/python/infinicore/nn/functional/silu.py](https://github.com/InfiniTensor/InfiniCore/blob/main/python/infinicore/nn/functional/silu.py)
4. 在 InfiniCore 中运行对应算子的 Python 级测试（uncomment 掉 InfiniCore 的算子调用部分），若能通过，则证明接入与实现正确。

### 九源统一计算库（InfiniCore）

- InfiniCore GitHub 主页：https://github.com/InfiniTensor/InfiniCore
- InfiniCore 文档 GitHub 主页：https://github.com/InfiniTensor/InfiniCore-Documentation
- InfiniCore-Documentation 仓库中包含 InfiniCore 的算子与各种类型的描述。

**注意**：在提供的沐曦平台上编译算子库时，需额外加上 `--use-mc=y` 的编译选项。

### 九源统一算子库（InfiniOps）

- InfiniOps GitHub 主页：https://github.com/InfiniTensor/InfiniOps

### FAQ

- 2026 春季启元人工智能大赛 FAQ：https://gxtctab8no8.feishu.cn/wiki/V5hkwjLmJiuE0EkFvmjcKfW4nwg