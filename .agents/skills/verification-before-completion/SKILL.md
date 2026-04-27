---
name: verification-before-completion
description: Use before claiming work is complete, fixed, or ready to review
---

# Verification Before Completion

> **Type:** Technique | **Discipline:** Rigid

在声明工作完成之前，必须运行验证命令并亲眼读完输出。

**核心原则：** 没有运行的验证 = 没有验证。"应该能过"不是证据，`** TEST SUCCEEDED **` 才是。

**绝对禁止：**
- "改好了" / "构建成功" / "应该没问题" —— 在运行验证命令之前
- 看到命令启动就假设它会成功
- 只读前几行输出，跳过后面

## 五步验证门

### Step 1：确定验证命令

| 变更范围 | 验证命令 |
|---------|---------|
| 只改 `GrowingTrackerCore/` 下的源码 | 跑 `GrowingAnalyticsTests` scheme，用 `-only-testing:GrowingAnalyticsTests/<子目录或 case>` 聚焦 TrackerCoreTests 子集 |
| 改了无埋点核心模块 | 同上，聚焦 `AutotrackerCoreTests` 子集 |
| 改了某个可选 Module（`Modules/*/`） | 跑 `ModulesTests` 下对应子集（如 `ModulesTests/HybridTests`、`ModulesTests/ProtobufTests`） |
| 改了 agent/skill/文档配置文件 | 无需构建，确认文件内容正确即可 |
| 改了核心路径（事件/存储/网络/Session） | 完整跑 `GrowingAnalyticsTests.xctestplan`（不加 `-only-testing:`） |

> 测试目标全部编译进 `GrowingAnalyticsTests` 这一个 scheme，`TrackerCoreTests/` 等是源码子目录，不是独立 target/scheme。
>
> 如果不确定范围，直接跑完整 testplan（多花几分钟比漏验证强）。

### Step 2：执行命令

```bash
# 构建 + 运行测试（与 .github/workflows/ci.yml 对齐）
xcodebuild test \
  -workspace Example/GrowingAnalytics.xcworkspace \
  -scheme GrowingAnalyticsTests \
  -testPlan GrowingAnalyticsTests \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro' \
  | xcbeautify

# 仅构建（Example App，无测试）
xcodebuild build \
  -workspace Example/GrowingAnalytics.xcworkspace \
  -scheme Example \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro' \
  | xcbeautify

# Pod lint（发布前校验 podspec）
pod lib lint GrowingAnalytics.podspec --allow-warnings

# SPM 构建（跨平台抽查，参考 .github/workflows/spm.yml）
xcodebuild build -scheme GrowingAutotracker \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro' \
  | xcbeautify
xcodebuild build -scheme GrowingTracker \
  -destination 'platform=macOS' \
  | xcbeautify
```

> 设备名以 `xcrun simctl list devices available` 为准；CI 当前用 `iPhone 17 Pro`。
> 若本机未装 `xcbeautify`（`brew install xcbeautify`），临时可用 `xcpretty` 代替。

等命令执行完毕，不提前下结论。

### Step 3：读完整输出

**测试通过的标志：**
```
** TEST SUCCEEDED **
```

**构建成功的标志：**
```
** BUILD SUCCEEDED **
```

**失败的标志（任意一条 = 失败）：**
```
** TEST FAILED **
** BUILD FAILED **
error:
FAILED
```

### Step 4：确认输出支持你的结论

- [ ] 看到了 `** TEST SUCCEEDED **` 或 `** BUILD SUCCEEDED **`
- [ ] 输出中没有 `error:` 行
- [ ] 如果跑了测试：所有测试通过，无 FAILED

### Step 5：带证据声明完成

✅ **正确做法：**
```
构建通过（** BUILD SUCCEEDED **）。
测试通过（42 tests passed，0 failed）。
```

❌ **错误做法：**
```
改好了。应该没问题。（没有运行命令）
```

## 快速决策树

```
本次改动是什么？
  ├── agent/skill/docs/配置文件 → 确认文件内容正确 → 完成
  ├── SDK 源码（非核心路径） → 构建对应模块 → 通过 → 完成
  │                                           → 失败 → systematic-debugging
  └── SDK 核心路径（事件/存储/网络）
        ├── 构建 → 失败 → systematic-debugging
        │       → 通过
        └── 运行测试 → 失败 → systematic-debugging
                    → 通过 → 完成
```

## Rationalizations

| Excuse | Reality |
|---|---|
| "改完了应该能过吧" | 猜不算证据，跑命令才算 |
| "上次跑过一次没问题" | 当前 commit 要重新跑 |
| "构建过了就算验证" | 构建 ≠ 测试 |
| "改 README 这种不用验证" | 纯文档改动可跳过，但必须显式判定 |

## Red Flags — STOP if you catch yourself thinking these

- "改好了" / "应该没问题" → 在运行验证命令之前，这些话不允许说
- "命令启动了，应该能过" → 等到 `** TEST SUCCEEDED **` 出现才算
- "输出太长，看个大概就行" → 必须找到成功/失败标志

## 关联 skill

- **上游触发：** 任何"声明完成/已修好/准备审查/准备 merge"的时刻
- **完成后交接：** 验证通过 → `sdk-code-review` 或 `finishing-a-development-branch`
- **替代路径：** 验证失败 → `systematic-debugging`
