---
name: subagent-driven-development
description: Use when executing an implementation plan with 3+ independent tasks in the current session
---

# Subagent-Driven Development

> **Type:** Technique | **Discipline:** Rigid

通过 dispatch 独立 subagent 执行 plan 中的每个任务，每个任务完成后进行两阶段审查（规格合规 → 代码质量）。

**核心原则：** 每任务一个新鲜 subagent + 两阶段审查（规格 → 质量）= 高质量、快迭代

## 何时使用

```
有 plan 文件?
  ├─ NO  → writing-plans 先产出 plan
  └─ YES → 任务数 ≥ 3 且大部分独立?
             ├─ NO  → 手动实施 + sdk-code-review
             └─ YES → 本 skill
```

## 流程

```
读取 plan，提取所有任务全文
  ↓
[Per Task]
  记录 BASE_SHA
  ↓
  Dispatch 实现者 subagent（./implementer-prompt.md）
  ↓
  实现者提问？ ──yes──→ 回答问题 → 重新 dispatch
  │no
  ↓
  实现者实现、测试、提交
  ↓
  记录 HEAD_SHA
  ↓
  Dispatch 规格审查者（./spec-reviewer-prompt.md）
  ↓
  规格合规？ ──no──→ 重新 dispatch 实现者修复 → 重新规格审查
  │yes
  ↓
  Dispatch 质量审查者（./code-quality-reviewer-prompt.md）
  ↓
  质量通过？ ──no──→ 重新 dispatch 实现者修复 → 重新质量审查
  │yes
  ↓
  标记任务完成
[/Per Task]
  ↓
verification-before-completion（全量构建 + 测试）
  ↓
Dispatch 全局 sdk-code-review skill（模式 A: spec-reviewer + code-reviewer）
  ↓
finishing-a-development-branch
```

## 模型选择

| 任务特征 | 推荐模型 |
|---------|---------|
| 1-2 文件、清晰规格、机械实现 | `haiku` |
| 多文件协调、集成逻辑 | `sonnet` |
| 架构、设计和审查任务 | `opus` |

## 处理实现者状态

- **DONE** → 进入规格合规审查
- **DONE_WITH_CONCERNS** → 先读疑虑再决定
- **NEEDS_CONTEXT** → 补充上下文，重新 dispatch
- **BLOCKED** → 评估：上下文不足 / 需要更强模型 / 任务太大 / plan 有问题

## Prompt 模板

- `./implementer-prompt.md`
- `./spec-reviewer-prompt.md`
- `./code-quality-reviewer-prompt.md`

## 上下文构造原则

- **粘贴全文**：任务描述从 plan 中提取完整文本粘贴进 prompt，不让 subagent 自己读文件
- **提供场景设置**：任务在整体 plan 中的位置、前序任务完成了什么、依赖关系

## Rationalizations

| Excuse | Reality |
|---|---|
| "这个任务简单，我自己直接改" | 控制器不写代码——隔离是防 context 污染，不只是并行 |
| "并行 dispatch 多个实现者更快" | 明确禁止，会冲突 |
| "自审过就不用 spec-reviewer" | 自审替代不了独立审查 |
| "先质量审，spec 回头再补" | 顺序不可颠倒 |
| "上一任务的小问题带到下一任务再修" | 带病进下一任务 = 累积漂移 |
| "让 subagent 自己读 plan 省事" | 必须粘贴全文，避免上下文不一致 |

## 关联 skill

- **上游：** `writing-plans` + `plan-document-review`
- **完成后：** `verification-before-completion` → `sdk-code-review` → `finishing-a-development-branch`
