---
name: receiving-code-review
description: Use when receiving feedback from code-reviewer subagent or human reviewer
---

# 接收代码审查反馈

> **Type:** Technique | **Discipline:** Rigid

收到 code-reviewer subagent 或人类 reviewer 的反馈后，按本技能规范处理。

**核心原则：** 验证先于实施，澄清先于假设，技术正确性高于社交舒适度。

## 响应模式

```
收到审查反馈
  ↓
1. READ：完整读完所有反馈，不急于行动
2. UNDERSTAND：用自己的话复述每条要求（或提问）
3. VERIFY：对照代码库现状核实
4. EVALUATE：对本项目是否技术合理？
5. RESPOND：技术性确认或有理据的 push back
6. IMPLEMENT：逐条修复，每条单独测试
```

## STOP-ASK 模式

```
如果反馈中任何一项不明确：
  → 全部暂停，不实施任何一项
  → 先对不明确的项提问澄清
  → 澄清完毕后再开始实施
```

**示例：**
```
reviewer 返回 6 条问题，你理解 1、2、3、6，不确定 4、5。

❌ 错误：先改 1、2、3、6，回头再问 4、5
✅ 正确："第 1、2、3、6 条已理解。第 4 条和第 5 条需要澄清：
    - 第 4 条提到 'session 边界处理'，是指 UIApplication 进入后台还是 App 终止？
    - 第 5 条 '协议对齐'，具体是哪个字段？"
```

## YAGNI 检查

```
当 reviewer 建议"实现得更完善"时：
  → 先 grep 代码库确认是否有实际调用
  如果没有调用："这个接口当前没有调用方，是否需要实现？（YAGNI）"
```

## 禁止行为

**绝不说：**
- "你说得对！" / "好建议！" / "让我立刻实现"（在验证之前）

**应该说：**
- "已修复。[简述改了什么]"
- "确认是个问题。已在 `file:line` 修复。"

## 何时 Push Back

- 建议会破坏已有功能
- reviewer 缺少完整上下文
- 违反 YAGNI
- 对本技术栈不适用
- 与用户的架构决策冲突

## 实施顺序

```
1. 先澄清所有不明确项（STOP-ASK）
2. 按优先级实施：
   a. Critical（崩溃、数据丢失、隐私泄露）
   b. 简单修复（格式、导入）
   c. 复杂修复（重构、逻辑变更）
3. 每条修复后单独验证
4. 全部完成后确认无回归
```

## 下游 / loop-back（HARD RULE）

反馈项全部实施完成后：

1. **回到同一个 reviewer 复审**
2. **所有项通过后** → `verification-before-completion` 重跑
3. **verify 通过** → 回到主流程

## Rationalizations

| Excuse | Reality |
|---|---|
| "reviewer 说的有理，全盘接受" | 表演式认同是失职，先验证 |
| "改完了不用重新 dispatch" | Critical/Important 修完必须重新 review |
| "先改 Critical，Important 合并前再说" | Important 也阻塞合并 |
| "部分听懂了就开始改" | STOP-ASK，不明确项必须澄清 |
| "我改得很小，不用重跑 verify" | 任何修改后 verify 都要重跑 |

## Red Flags

- "reviewer 说得对！让我立刻实现" → 先验证
- "这条反馈我不同意，跳过" → 必须 push back 并给技术理由
- "部分理解了就先改" → STOP-ASK
- "改完了不用重新 dispatch" → Critical/Important 修完必须重新 review

## 关联 skill

- **上游触发：** `sdk-code-review` 的 reviewer 或人类 reviewer 返回反馈
- **完成后交接：** 重新 dispatch 同 reviewer → `verification-before-completion` → 主流程
