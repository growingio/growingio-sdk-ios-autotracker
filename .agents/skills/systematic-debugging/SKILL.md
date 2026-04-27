---
name: systematic-debugging
description: Use when facing Xcode build errors, linker failures, XCTest failures, event pipeline bugs, network issues, SDK crashes, or any technical problem where a first attempt didn't work or the cause is unclear
---

# Systematic Debugging

> **Type:** Technique | **Discipline:** Rigid

遇到技术问题时，用纪律代替直觉。随机猜测让问题变得更复杂；系统性方法让每次尝试都增加信息量。

**核心原则：** 在不理解根本原因之前，不修改代码。每次修改只验证一个假设。

## 何时触发

- 出现编译错误 / 构建失败 / 测试失败
- 一次尝试没有修复问题
- 时间压力下有"随便试试"的冲动（尤其需要此 skill）
- 同一问题反复出现

## 四阶段方法

### Phase 1：调查根因（先读，不动代码）

目标：用一句话准确描述问题。"X 在 Y 处因为 Z 失败。" 填不上这句话 → 继续调查。

**Xcode / xcodebuild 编译错误：**
- 找到 `error:` 行和具体文件路径 + 行号
- 区分是 ObjC 编译错误、链接错误还是 Swift 编译错误
- 不要只看第一个错误——连带错误可能掩盖真正的根因

**XCTest 测试失败：**
- 读完整栈追踪，找到失败的 `XCTAssert*` 断言
- 确认实际值 vs 期望值
- 检查 `setUp` / `tearDown` 是否正确重置了单例状态

**运行时 / 事件管道问题：**
- 事件未入库：检查 `dataCollectionEnabled` 开关，检查后台队列任务是否静默失败
- 事件入库但未上报：检查网络状态，检查上报调度是否启动
- 字段值错误：在事件构建处打 log，确认构建时的值
- Session 异常：检查 `sessionInterval` 超时逻辑，检查 App 生命周期钩子

**SDK 特有规律速查：**

| 症状 | 常见根因 |
|------|---------|
| Debug 正常，Release 失败 | 编译优化 / 符号剥离 / 混淆导致方法找不到 |
| 第一次测试通过，第二次失败 | 单例状态未在 `tearDown` 中重置 |
| 本地正常，CI 失败 | 模拟器版本差异 / 缺少 CocoaPods 依赖 |
| 事件入库后消失 | 上报成功删除逻辑误触发 |
| 首次 VISIT 事件重复 | 多次调用 `startWithConfiguration:` / AppDelegate 钩子重复触发 |
| 主线程 watchdog 杀掉 | 数据库写入在主线程执行 |
| 无埋点点击不触发 | method swizzling 失败 / load 顺序问题 |

### Phase 2：模式识别

- 问题是孤立的（单个文件 / 单个测试）还是系统性的（多处同时出现）？
- 查历史：`git log --oneline --grep="关键词" -10`

### Phase 3：最小假设

用一句话陈述假设：

> "我认为 **[具体的 X]** 导致了 **[具体的 Y]**，因为 **[具体的 Z]**。"

确定**最小验证手段**——改一行代码 + 一条命令能证伪或证实。

**禁止行为：**
- 调试过程中同时重构代码
- 修多处然后"看哪个起效了"

### Phase 4：单点修复 + 验证

只实施假设对应的最小修复，然后立即验证：

```bash
xcodebuild test \
  -workspace Example/GrowingAnalytics.xcworkspace \
  -scheme GrowingAnalyticsTests \
  -testPlan GrowingAnalyticsTests \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro' \
  | xcbeautify
```

修复后问题消失 → 记录根因 → **回到 `verification-before-completion` 重跑**。

## 升级条件

**3 次假设验证后问题仍未解决 → 强制停止，输出升级报告：**

```
## 调试报告

问题描述：[一句话]

已尝试：
1. 假设 [X]，修改了 [Y]，结果 [Z]
2. 假设 [X]，修改了 [Y]，结果 [Z]
3. 假设 [X]，修改了 [Y]，结果 [Z]

当前状态：[问题仍然存在]
疑似方向：[你的猜测和为什么卡住]
需要：[具体需要什么帮助]
```

## Rationalizations

| Excuse | Reality |
|---|---|
| "直接改一下看看行不行" | 无假设的试探 = 随机游走 |
| "这个错误面熟" | 面熟是陷阱；Phase 1 要读完整错误再判断 |
| "同时试 3 个修复" | 无法分离原因 |
| "失败 3 次再试第 4 次" | 3 次是硬上限，强制升级 |

## Red Flags

- "先改一下看看" → 没有假设的修改是随机游走
- "这个错误我见过" → 面熟 ≠ 理解根因
- "顺手重构一下" → 调试期间不引入新变量
- "第 3 次失败了，再试一次" → 3 次是硬上限

## 关联 skill

- **完成后交接：** 修复后 → `verification-before-completion`
- **替代路径：** 3 次失败 → 报告 BLOCKED
