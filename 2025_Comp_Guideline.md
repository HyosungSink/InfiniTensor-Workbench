# 2025秋季启元人工智能大赛指南

## 算子开发赛道

选手可以选择使用硬件原生语言（e.g., CUDA) 或九齿（一种基于 Triton 的高层次抽象领域编程语言）进行开发。开发的算子需接入 InfiniCore, 即九源统一算子库，和/或 ntops，即九齿算子库。关于 InfiniCore 和九齿的介绍和教程，可以参考 [框架介绍与教程](#框架介绍与教程)。

- **优胜规则：** 赢者通吃，即每个算子赛题仅有一支队伍获奖。评优规则为：
  - 保证正确性（必须）
  - 均正确的情况下，根据性能排名进行评优，性能最优者胜出。不正确的实现不参与性能评定。性能评判标准：预热后10次循环取25%-75%分位数的均值。相对差异 <= 1% 视为相同
  - 所有主要计算必须在GPU平台上完成。**若有任何疑惑、不确定的界定范围或特殊情况，请及时咨询赛题组**
- **评分细则：**
  - **算子开发赛题 (1-1-X系列)**：
    - CPU 性能不参与评分，但仍建议进行适当优化，以免运行过慢影响正确性评测流程（注：若运行时间过长无法结束则可能被判定为未正确实现）。
    - 九齿实现的算子在性能评定时会关闭自动调优。
    - 使用九齿开发和性能评定时将以最新的 master 分支为准，因此请持续关注和更新九齿。
- **提交方式：** 若选择用九齿实现算子，则需向 ntops 仓库提交 GPU 平台实现的 PR，向 InfiniCore 仓库提交 CPU 实现和 ntops 对应的九齿算子接入算子库的代码；若是硬件原生语言（e.g., CUDA) 实现的算子，则全部向 InfiniCore 仓库提交 PR。具体提交要求：
  - 分支命名需命名为：`2025-autumn-<GitHub ID>-<赛题号>`，例如 ID 为 ABC 的选手选择并提交 T1-1-1 赛题，则该分支需命名为：`2025-autumn-ABC-T1-1-1`
  - PR 命名规范：`[2025秋季][赛题号] GitHub ID`
  - PR 描述中需附上：
    - 该赛题在每个实现的平台上的测试结果截图。截图时可以跑以下指令：

      ```bash
      python test/infinicore/run.py --ops <赛题的五个算子> --<平台> --bench
      ```

    截图：截每个算子的 **TEST SUMMARY**和最后的 **CUMULATIVE TEST SUMMARY**:

    - 署名的 `HONOR_CODE.md` 和 其中提及的 `REFERENCE.md`
    - 值得陈述的技术细节与优化

## 框架介绍与教程

### 九源统一算子库（InfiniCore）

InfiniCore GitHub 主页：GitHub - InfiniTensor/InfiniCore

InfiniCore 文档 GitHub 主页：GitHub - InfiniTensor/InfiniCore-Documentation

- 本仓库中包含 InfiniCore 的算子与各种类型的描述

**注意**：在提供的沐曦平台上编译算子库时，需额外加上 `--use-mc=y` 的编译选项

### 九源统一领域编程语言——九齿（NineToothed）

九齿文档

关于使用九齿完成算子并接入 InfiniCore 的流程：

1. 本地拉取九齿算子库（ntops），并安装 `pip install -e .`
2. 在 ntops 中完成算子的实现；
3. 九齿算子接入 InfiniCore Python 接口可以参考：InfiniCore/python/infinicore/nn/functional/silu.py at main · InfiniTensor/InfiniCore
4. 在 InfiniCore 中运行对应算子的 Python 级测试（uncomment 掉 infiniCore 的算子调用部分），若能通过，则证明接入与实现正确。
