---
name: sdk-code-review
description: Use when a feature, bugfix, or refactoring step is completed and needs review, or before merging to main, or when user says "review", "审查", "帮我看看代码"
---

# SDK 代码审查

> **Type:** Technique | **Discipline:** Rigid

dispatch 审查 subagent 对已完成的工作进行独立审查。审查者不继承当前会话历史——你负责构造它需要的全部上下文。

## 何时触发

**强制：**
- 触发了 Planning Gate 的改动完成后
- 涉及公开 API 变更的改动完成后
- 合并到 master 之前
- subagent-driven-development 全部任务完成后的全局审查

**可选但推荐：**
- 修复复杂 bug 后 / 重构后 / 卡住时

## 审查模式选择

```
工作完成，需要审查?
  │
  ▼
纯文档/注释/格式/typo 且 < 3 files 且无行为变更?
  ├─ YES → 可跳过（须向用户明示并得到默示/确认）
  └─ NO
      ▼
  有 plan 文件对应本次改动?
  ├─ YES → 模式 A：完整审查（spec-reviewer → code-reviewer）
  └─ NO  → 变更文件 < 3 且不涉及公开 API?
            ├─ YES → 模式 B：独立审查（仅 code-reviewer）
            └─ NO  → 回退补 plan（writing-plans），再走模式 A
```

> 跳过分支只适用于"显然无行为影响"的改动（如修 typo、更新注释、调整格式）。一旦触碰逻辑、接口、数据字段、构建脚本，立刻退回 Mode A/B。

### 模式 A：完整审查

1. dispatch `spec-reviewer` subagent → 通过后进入步骤 2
2. dispatch `code-reviewer` subagent

### 模式 B：独立审查

满足**全部**条件时，只 dispatch `code-reviewer`：
- 无对应 plan 文件
- 变更文件 < 3 个
- 不涉及公开 API 变更

## 调度步骤

### 1. 确定变更范围

```bash
# 场景 A：review 整个功能分支
BASE_SHA=$(git merge-base HEAD master)
HEAD_SHA=$(git rev-parse HEAD)

# 场景 B：单个任务（subagent-driven-development 中）
# BASE_SHA 在 dispatch 实现者前记录，HEAD_SHA 在实现者提交后记录

# 查看变更文件
git diff --name-only $BASE_SHA..$HEAD_SHA
```

### 2. Dispatch 审查者时必须提供

**spec-reviewer：** 变更内容、规格/规划全文、实现者报告、BASE_SHA、HEAD_SHA、变更文件列表

**code-reviewer：** 变更内容、plan 文件路径（参考）、BASE_SHA、HEAD_SHA、变更文件列表

> 若变更文件包含 `.agents/` 或 `.claude/` 路径，显式注明："本次变更包含 skill/agent 配置文件，请额外执行维度 7（Skill/Agent 架构一致性）检查。"

### 3. 处理审查结果

```
审查者返回结果
  ├── "通过" → 继续后续工作
  ├── "需要修改"
  │     ├── Critical → 立即修复，重新 dispatch 同审查者
  │     ├── Important → 合并前修复，重新 dispatch
  │     └── Suggestion → 记录，可后续处理
  └── "需要讨论" → 与用户讨论后决定
```

## Rationalizations

| Excuse | Reality |
|---|---|
| "改动小，跳过审查吧" | 模式 B 已是最轻量路径，再跳 = 裸奔 |
| "我自己看过一遍没问题" | 自审替代不了独立审查 |
| "先做质量审查，规格审查之后补" | 顺序不可颠倒 |
| "改完了，直接声明通过" | Critical/Important 修复后必须重新 dispatch |

## Red Flags

- "这个改动太小了不需要审查" → 模式 B 就是为小改动设计的
- "我自己检查过了" → 自审替代不了独立审查
- "先跑质量审查" → 顺序不可颠倒
- "修完 Critical 了，不用重新 dispatch" → 必须重新 dispatch

## 关联 skill

- **上游触发：** 前置 `verification-before-completion` 通过后进入本 skill
- **调度 subagent：** `spec-reviewer`（模式 A 第一阶段）/ `code-reviewer`（模式 A 第二阶段 / 模式 B）
- **完成后交接：** 通过 → `finishing-a-development-branch`
- **处理反馈：** `receiving-code-review`（修复后先 verify 再重新 dispatch reviewer）
