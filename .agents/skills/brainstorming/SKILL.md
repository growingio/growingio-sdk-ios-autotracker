---
name: brainstorming
description: Use when receiving an ambiguous feature request, when scope is unclear, or before writing any plan
---

# Brainstorming: 把想法变成规格

> **Type:** Pattern | **Discipline:** Flexible

把模糊需求通过"一次一个问题"的方式，收敛成一份可用于 `writing-plans` 的设计规格。

<HARD-GATE>
在完成规格并拿到用户批准之前，**不得**调用 `writing-plans`、不得动任何源文件、不得派 subagent 执行实现。
逃生条款：用户明确说 "skip brainstorming"、"已经有规格"、"直接按 X 做" 时可跳过。
</HARD-GATE>

## 何时触发

**必须走本流程**：
- 需求一句话带过（"加个 X 功能"、"优化下 Y"），无验收标准
- 影响范围不清（不知道是否碰公开 API / 是否改数据协议 / 影响哪些平台）
- 用户描述的是"症状"而非"问题"

**不走本流程**：
- 修 bug 且 root cause 已定位
- 严格按既有规格实现
- 用户明示"跳过头脑风暴"

## Checklist（必须转成 TaskCreate，逐条完成）

1. **探查项目上下文** — 读 `AGENTS.md`、相关模块源码、涉及模块的近期 commit
2. **抛 SDK 专有澄清问题**（每次一个，选项式优先）：
   - 影响哪个产品线？仅 SaaS / 仅 CDP / 两者？
   - 是否改动公开 API？覆盖面：模块根 `.h`（如 `GrowingAutotracker/GrowingAutotracker.h`）、`GrowingTrackerCore/Public/`、`GrowingAutotrackerCore/Public/`、各 `Modules/*/Public/`
   - 是否改动数据协议？（新增/修改事件字段、序列化格式、上报路径）若改动，字段命名与类型是否已对齐协议规范？
   - 影响哪些平台？iOS / macOS / watchOS / tvOS / visionOS？
   - 隐私合规影响？（是否采集新字段、是否需在 `GrowingIgnoreFields` 位掩码（`NS_OPTIONS`，定义在 `GrowingTrackerCore/Public/GrowingFieldsIgnore.h`）中新增掩码项）
3. **提 2–3 个方案** — 每个方案写 trade-off（数据准确性 / 接入成本 / 性能 / 包体积）
4. **分段呈现设计** — 按「问题定义 / 方案 / 接口草案 / 数据协议 / 影响面」分节
5. **写规格文档** — 保存到 `docs/specs/YYYY-MM-DD-<topic>.md`
6. **规格自查** — 有无 TODO、有无自相矛盾、范围是否闭合
7. **请用户审阅** — 等明确 "OK/确认/继续"
8. **移交** — 规格确认后回到主流程 → Planning Gate

## Anti-Pattern

- **「需求太简单不用规格」**：简单改动规格可以只有几行，但必须写下来并拿批准
- **「一次问五个问题」**：一次一个问题。多问 = 用户挑 1-2 个回答，其余遗漏

## 关联 skill

- **完成后交接：** 规格确认 → Read relevant docs → Planning Gate
