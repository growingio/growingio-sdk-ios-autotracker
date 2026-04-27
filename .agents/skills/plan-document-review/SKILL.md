---
name: plan-document-review
description: Use after writing a plan document in docs/plans/, before requesting user confirmation
---

# Plan Document Review

> **Type:** Technique | **Discipline:** Rigid

在 Planning Gate 输出完规划文档后、请求用户确认前，dispatch 一个 plan reviewer subagent 审查规划本身的质量。

**核心原则：** plan 是实施的蓝本，蓝本有洞 = 实施有洞。

## 何时触发

**强制：** Planning Gate 保存完 plan 到 `docs/plans/` 之后、提示用户确认之前。

**可跳过：** Planning Gate 未触发的小改动（< 3 文件且不涉及公开 API）。

## 调度方式

```
Agent({
  description: "Review plan document",
  subagent_type: "general-purpose",
  prompt: `
你是 GrowingIO iOS SDK 的规划审查员。验证以下规划是否完备、可实施。

## 待审查规划

文件路径：{PLAN_FILE_PATH}

规划全文（已粘贴，不用再读）：

---
{PLAN_FULL_TEXT}
---

## 原始需求 / 任务描述

{ORIGINAL_TASK_DESCRIPTION}

## 检查维度

### 1. 四节完整性

规划必须包含以下四节，缺一不可：
- [ ] 影响文件列表
- [ ] 公开 API 变更
- [ ] 数据协议变更
- [ ] 需同步修改的文档

### 2. 影响文件列表准确性

- 文件路径是否真实存在？
- 是否有明显遗漏：
  - 新增公开 API 但没列对应路径：模块根 \`.h\` / \`GrowingTrackerCore/Public/\` / \`GrowingAutotrackerCore/Public/\` / \`Modules/*/Public/\`
  - 修改事件字段但没列对应测试文件
  - 修改某模块但没列 podspec / Package.swift
- 有没有列了但实际不需要改的（scope creep）？

### 3. 公开 API 变更一致性

- 是否在影响文件列表中包含了公开头文件 + podspec + Package.swift？
- 签名是否完整（参数类型、返回类型）？
- 删除/重命名是否考虑了兼容性？

### 4. 数据协议变更覆盖

- 涉及字段变更时，"影响产品线"是否完整（SaaS / CDP）？
- 字段类型是否与数据协议规范对齐？

### 5. 文档同步完整性

- 公开 API 变更是否列了对应文档？
- 涉及核心模块是否列了对应模块文档？

### 6. 任务拆分质量

- 任务是否大部分相互独立？
- 任务粒度是否合理？

### 7. 场景覆盖

- Autotrack 改动：iOS / macOS / tvOS 三平台？Hybrid / WebCircle 适配？
- Session 改动：前台/后台/终止三种触发时机？
- 事件改动：Protobuf / JSON 双格式？

## 输出格式

### 问题

#### Critical（阻塞）
#### Important（应修复）
#### Suggestion（建议）

### 检查清单

- [ ] 四节完整
- [ ] 影响文件列表准确无遗漏
- [ ] 公开 API 变更同步头文件 + podspec + Package.swift
- [ ] 数据协议产品线完整
- [ ] 文档同步列表完整
- [ ] 任务拆分合理
- [ ] 场景覆盖完整

### 结论

**通过** / **需要修改** / **需要讨论**
`
})
```

## 处理审查结果

```
reviewer 返回结果
  ├── "通过" → 向用户展示 plan + reviewer 摘要，请求确认
  ├── "需要修改"
  │     ├── Critical/Important → 修改 plan，重新 dispatch reviewer（最多 2 轮）
  │     └── 第 2 轮后仍有问题 → 停止，向用户说明
  └── "需要讨论" → 与用户讨论后决定
```

## Rationalizations

| Excuse | Reality |
|---|---|
| "自己写的 plan 自己审就行" | 自审替代不了独立审查 |
| "跳过 reviewer 直接请求用户确认" | 独立审查是硬性流程 |
| "修完 Critical 不用重新 dispatch" | 必须重新 dispatch |

## Red Flags

- "plan 很短，走个形式就行" → 短 plan 也要过 reviewer，四节完整性是硬约束
- "只是小调整，不用再 dispatch" → 任何触及影响文件列表 / 公开 API / 数据协议的修改都必须重审
- "reviewer 返回 Important 但我觉得不重要" → Important 至少要在 plan 中写明权衡后再请求用户确认
- "先让用户看，他确认了再过 reviewer" → 顺序不可颠倒，reviewer 在前、用户确认在后
- "上一轮 reviewer 通过过，这次小改不用跑" → plan 改过就重走一轮，否则审查基线漂移

## 关联 skill

- **上游触发：** `writing-plans` 产出 plan 文件后
- **完成后交接：** 通过 → 请求用户确认 → 进入实施
