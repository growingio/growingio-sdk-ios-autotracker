---
name: using-growingio-sdk-skills
description: Use when starting any interaction as the GrowingIO iOS SDK engineer main controller agent
---

<SUBAGENT-STOP>
If you were dispatched as a subagent to execute a specific task — this includes but is not limited to:

- `code-reviewer` / `spec-reviewer` (reviewing code or specs)
- implementer subagents dispatched by `subagent-driven-development`
- any general-purpose agent invoked via the `Agent` / `Task` tool with a specific assigned task
- any subagent whose prompt explicitly hands you a narrow job

**then SKIP THIS META-SKILL ENTIRELY.** Do not apply the routing, Planning Gate, or workflow below. Just execute your assigned task as specified in the prompt you received. The meta-skill's rules are for the main controller agent only; you are not it.

**但"跳过 meta-skill"不等于"不用任何 skill"**：子 agent 仍可（且应当）自主调用与任务相关的**域 skill**，例如：
- `test-driven-development`（实现核心路径时）
- `systematic-debugging`（遇到 build/test/runtime 失败时）
- `verification-before-completion`（声称任务完成前）

跳过的**只是** meta-skill 的三项硬规则：**Planning Gate + Workflow Routing + TaskCreate 强制**。域 skill 的判断由子 agent 按自身任务自行决定。

Signal of subagent context: your prompt starts with "你是…" / "You are…" followed by a specific role description, or you received a structured task payload.
</SUBAGENT-STOP>

<EXTREMELY-IMPORTANT>
If you think there is even a 1% chance a skill might apply to what you are doing, you MUST invoke the skill. This is not negotiable.
</EXTREMELY-IMPORTANT>

# Using GrowingIO SDK Skills

> **Type:** Technique | **Discipline:** Rigid

This is the **entry gate** for the GrowingIO iOS SDK engineer (main controller agent).

## How this skill reaches you

The full content of this SKILL.md is injected into every session automatically by the SessionStart hook (`.claude/hooks/session-start.sh`), and re-injected after `/clear` or auto-compact. You do NOT need to call the `Skill` tool to load it.

## Instruction Priority

1. **User's explicit instructions** — highest
2. **SDK skills** (including this meta-skill) — override default behavior
3. **Default model behavior** — lowest

## The Rule

**Invoke relevant skills BEFORE any response or action.** Even a 1% chance a skill applies means invoke it.

## Skill Checklist → TaskCreate (HARD RULE)

当被调用的 skill 包含步骤清单，控制器**必须**立即调用 `TaskCreate` 把每一条转为独立 todo，并在完成每一步后用 `TaskUpdate` 更新状态。**禁止只在脑内执行 checklist**。

## Skill Catalog

### Process skills（优先检查——决定如何做）
- `brainstorming` — 模糊需求 / 范围不清 / 写 plan 前
- `writing-plans` — 编写实施规划到 `docs/plans/`
- `plan-document-review` — plan 写完后、请求用户确认前
- `subagent-driven-development` — 有 plan 且任务 ≥ 3 个独立任务时
- `systematic-debugging` — 任何 build/test/runtime 失败且根因不明
- `test-driven-development` — 实现核心 SDK 路径（事件管道、存储、网络）

### Review skills
- `sdk-code-review` — 功能完成后、合并前、用户要求 review 时
- `receiving-code-review` — 收到 reviewer subagent 或人类 reviewer 反馈时

### Closing skills
- `verification-before-completion` — 声称工作完成/已修好/准备审查前
- `finishing-a-development-branch` — 验证与审查通过后收尾分支

### Meta 侧流（改 skill / 改 agent 本身时才用）
- `writing-skills` — 新建或修改 `.agents/skills/` 下任何 SKILL.md 时

## Planning Gate (HARD GATE)

Before writing ANY code, check these triggers:

**Trigger (any ONE suffices):**
- Affected file count ≥ 3
- Any change to public API surface — covers all of:
  - Module root `.h` (e.g., `GrowingAutotracker/GrowingAutotracker.h`, `GrowingTracker/GrowingTracker.h`)
  - `GrowingTrackerCore/Public/*.h`
  - `GrowingAutotrackerCore/Public/*.h`
  - Any `Modules/*/Public/*.h`
  - `GrowingAnalytics.podspec` `public_header_files` 声明或 `Package.swift` targets

**If triggered:**
1. Invoke `writing-plans` → save plan to `docs/plans/YYYY-MM-DD-<feature>.md`
2. Invoke `plan-document-review` → dispatch reviewer subagent
3. Show user plan path + reviewer summary, ask for confirmation
4. **Do NOT touch any source file until user confirms**

Required sections in every plan (missing any = incomplete):
- 影响文件列表
- 公开 API 变更（无则填"无"）
- 数据协议变更（无则填"无"）
- 需同步修改的文档（无则填"无"）

### Rationalizations (all invalid)

| Excuse | Reality |
|--------|---------|
| "改动很简单，不需要规划" | 简单改动也有影响面，规划 2 分钟没有例外 |
| "先改完再补规划" | 规划的价值在事前对齐 |
| "用户没要求规划" | 触发条件满足即强制 |
| "只改内部实现，不影响公开 API" | 内部实现影响 ≥3 文件同样触发 |
| "步骤很清楚，脑内过 checklist 就行" | TaskCreate 落盘 30 秒，无例外 |

## Workflow Routing

主线（按序，跳过条件见每条 skill 的 description）：

1. 模糊需求 → `brainstorming` → `docs/specs/` → 用户确认
2. 读领域知识（AGENTS.md 模块索引 + 源码 + 近期 commit）
3. **Planning Gate**（见上节）→ `writing-plans` → `plan-document-review` → 用户确认
4. 任务 ≥3 且独立 → `subagent-driven-development`；否则直接实施
5. `verification-before-completion`
6. `sdk-code-review`（有 plan 走模式 A，无 plan + <3 files + 不动公开 API 走模式 B）
7. 反馈 → `receiving-code-review` → 回到 5
8. `finishing-a-development-branch`

**旁路（随时插入）：**
- 改核心路径 → `test-driven-development`
- build/test/runtime 失败 → `systematic-debugging`

完整流程图见 `docs/agents-skills-flow.md`。

## Red Flags — STOP if you catch yourself thinking these

| Thought | Reality |
|---------|---------|
| "这是个简单问题，直接回答就行" | 问题也是任务，先查 skill |
| "小改动不用走流程" | Planning Gate 的触发条件本身就是"小改动"判定器 |
| "用户没要求，跳过吧" | skill 适用性由触发条件判定，不由用户触发 |
| "checklist 我记住了，不用 TaskCreate" | 落盘是约束力，立刻 TaskCreate |
| "需求我看懂了，不用 brainstorming" | 看懂字面 ≠ 规格闭合 |

**Remember:** The persona defines who you are. Skills define how you work.
