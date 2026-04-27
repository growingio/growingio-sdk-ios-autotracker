---
name: writing-skills
description: Use when creating a new skill, editing an existing skill, or verifying a skill works before deployment
---

# Writing Skills

**Writing skills IS Test-Driven Development applied to process documentation.**

**Core principle:** If you didn't watch an agent fail without the skill, you don't know if the skill teaches the right thing.

## The Iron Law

```
NO SKILL WITHOUT A FAILING TEST FIRST
```

This applies to NEW skills AND EDITS to existing skills. No exceptions.

## What is a Skill?

- **Is**: Reusable technique, pattern, or reference guide for future agent instances
- **Is NOT**: Narrative about a one-time problem; project-specific convention (put in `AGENTS.md`)

## Skill Types (two orthogonal dimensions)

| Type | Description | Example |
|---|---|---|
| **Technique** | 具体方法，有步骤可循 | `test-driven-development` |
| **Pattern** | 思维模型 | `brainstorming` |
| **Reference** | 查询式，结构化条目 | —（本项目暂无 Reference 型 skill） |

| Label | Meaning | Requirement |
|---|---|---|
| **Rigid** | 必须严格遵守 | 必须带 Rationalizations + Red Flags |
| **Flexible** | 原则可按场景取舍 | 不需 Rationalizations |

## Directory Structure

```
.agents/skills/                       ← 唯一存储位置（编辑这里）
  <skill-name>/
    SKILL.md                          # 必需
    <supporting-file>.md              # 仅当 >100 行或为可复用 prompt 模板

.claude/skills → ../.agents/skills    ← 软链接，让 Claude Code 默认路径也能读到
```

**只编辑 `.agents/skills/` 下的源文件**——软链接自动同步。不要在 `.claude/skills/` 下新建真实目录（会覆盖软链接）。

SessionStart hook 直接读 `.agents/skills/using-growingio-sdk-skills/SKILL.md`（见 `.claude/hooks/session-start.sh`）。

## Frontmatter (only two fields)

```yaml
---
name: skill-name-with-hyphens
description: Use when <triggering condition>
---
```

## Claude Search Optimization (CSO)

Description rules:
- Start with `Use when` / `Use before` / `Use after`
- **ONLY describe triggering conditions** — NOT workflow summaries
- Keep under 500 characters

**WHY:** When a description summarizes workflow, Claude follows the description instead of reading the full skill body. Description with workflow = agent skips body.

## SKILL.md Body Structure

```markdown
# <Skill Name>

> **Type:** Technique | **Discipline:** Rigid

## Overview

## When to Use / Not to Use

## Process / Checklist

## Rationalizations (Rigid skills required)
| Excuse | Reality |

## Red Flags (Rigid skills required)

## Related Skills
```

## RED-GREEN-REFACTOR for Skills

### RED: Baseline Test
Run pressure scenario WITHOUT skill. Document rationalizations verbatim.

### GREEN: Write Minimal Skill
Address those specific rationalizations. Run same scenarios WITH skill.

### REFACTOR: Close Loopholes
Agent found new rationalization? Add counter. Re-test.

## Rationalizations

| Excuse | Reality |
|---|---|
| "Skill is obviously clear, no need to test" | Clear to you ≠ clear to agents |
| "Description needs workflow context" | Workflow in description → agent skips body |
| "Just adding a section, no test needed" | Same Iron Law |
| "I'll test if problems emerge" | Test BEFORE, not after |

## Red Flags

- "I'll write the skill first, test later" → Delete. Start with RED.
- "This edit is too small to test" → No edit is too small.
- "Description needs to explain what this skill does" → That's what the body is for.

## Note on the symlink layout

- **Canonical source**：`.agents/skills/<skill-name>/SKILL.md`
- **Claude Code 读取路径**：`.claude/skills/<skill-name>/SKILL.md`（通过软链接解析）
- **SessionStart hook 路径**：`.agents/skills/using-growingio-sdk-skills/SKILL.md`（见 `.claude/hooks/session-start.sh`）

这个布局让不同 CLI 工具（各自默认读 `.agents/` 或 `.claude/`）共享同一份文件。**不要**在 `.claude/skills/` 下创建真实目录——会覆盖软链接。
