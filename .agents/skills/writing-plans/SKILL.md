---
name: writing-plans
description: Use when Planning Gate triggers (affected files ≥3 or public API change) and an implementation plan is needed
---

# Writing Plans

> **Type:** Technique | **Discipline:** Rigid

指导如何写好一份实施规划。Planning Gate（见 `using-growingio-sdk-skills` meta-skill）定义 plan 的**格式**（四节结构），本 skill 定义**内容质量**。

**核心原则：** 写 plan 时多想 10 分钟，实施时少返工 1 小时。

## 影响面自查清单

按改动类型对照清单列全受影响的文件/路径：

| 改动类型 | 必须同时覆盖 |
|---|---|
| **公开 API 新增/改/删** | 模块根 `.h`（如 `GrowingAutotracker/GrowingAutotracker.h`）+ `GrowingTrackerCore/Public/` + `GrowingAutotrackerCore/Public/` + 相关 `Modules/*/Public/` + podspec `public_header_files` + `Package.swift` targets |
| **事件字段变更** | SaaS / CDP 两产品线在"影响产品线"列显式标注（SaaS 用 `projectId`；CDP 额外需要 `dataSourceId`） |
| **核心模块** (`TrackerCore/Event/` `TrackerCore/Database/` `TrackerCore/Network/`) | 实现文件 + 对应 `*Tests` 目录 |
| **GrowingTrackConfiguration 变更** | SaaS / CDP 两种模式的默认值；若涉及 `useProtobuf`，需同时验证 JSON / Protobuf 两条序列化路径 |
| **Autotrack 改动** | iOS / macOS / tvOS 三平台 + Hybrid / WebCircle 模块（如适用） |
| **Session 改动** | 前台触发 + 后台 / 终止 + `sessionInterval`（默认 30s，定义于 `GrowingTrackerCore/GrowingTrackConfiguration.m`）超时逻辑 |
| **事件上报改动** | Protobuf 路径（`Services/Protobuf/`）+ JSON 路径（`Services/JSON/`），由 `trackConfiguration.useProtobuf`（默认 YES）切换；压缩/加密 adapter（`Modules/DefaultServices/`） |
| **模块 (Modules/) 改动** | podspec 对应 subspec + SPM target |

## 任务拆分

**拆成多任务：** 变更逻辑独立且可并行 / 单任务描述 > 200 字还说不清。
**合并为单任务：** 接口与其使用者（拆开编译不过） / 同模块内部重构。

拆分后按 `subagent-driven-development` skill 判定是否走 subagent 模式。

## Rationalizations

| Excuse | Reality |
|---|---|
| "先动手改两个文件再补 plan" | ≥3 文件动手那刻已经违规 |
| "影响文件只列改到的源码" | 头文件 / podspec / Package.swift / 测试都算影响 |
| "公开 API 改只动实现文件" | 必须同时更新公开头文件 + podspec |
| "这次规划口述就行" | 必须落地到 `docs/plans/YYYY-MM-DD-*.md` |
| "事件字段只影响当前产品线" | 两产品线字段要求不同，未标注 = 后端数据出错 |

## Red Flags

- "先改两个文件试试，plan 后面再写" → Planning Gate 触发那一刻就必须先写 plan
- "影响面我心里有数" → 没列出来的文件 = 会返工的文件
- "这个字段只涉及 CDP" → 两产品线必须逐一确认

## 关联 skill

- **完成后交接：** `plan-document-review` → 用户确认 → `subagent-driven-development` 或直接实施
