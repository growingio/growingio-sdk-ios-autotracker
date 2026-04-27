---
name: test-driven-development
description: Use when implementing or modifying core SDK paths (event pipeline, storage, network, session management)
---

# Test-Driven Development

> **Type:** Technique | **Discipline:** Rigid

在 SDK 核心路径上，**先写会失败的测试，再写通过测试的最小实现**。

**核心原则：** 测试先行 = 接口先行。想不出怎么测，通常是接口设计有问题。

## Red-Green-Refactor 循环

### Red：写一个会失败的测试
- 描述期望的行为（不是实现细节）
- 运行测试，**确认它真的失败**

### Green：写最小实现让测试通过
- 硬编码返回值也可以——目的是让红灯变绿
- 不要在这一步优化、抽象、加功能

### Refactor：在测试保护下重构
- 消除重复、改善命名、拆分职责
- 每次小改动后立即跑测试

**循环节奏：** 红 → 绿 → 重构，单次循环 ≤ 10 分钟。

## 何时应用 TDD

### 必用（核心路径）

- **事件管道**：事件构建（`GrowingBaseEvent`）、事件持久化、事件发送
- **存储层**：`GrowingEventDatabase`（SQLite 读写）
- **网络层**：请求构造、重试策略
- **会话管理**：session 生成、超时判定、App 生命周期
- **用户标识**：userId / userKey 变更触发的 VISIT 事件

### 不必用
- 配置类的纯字段赋值
- 文档、注释
- UI 组件的纯视觉渲染

## XCTest 在本仓库的用法

### 测试文件位置

```
Example/GrowingAnalyticsTests/
├── TrackerCoreTests/        ← CoreTests / DatabaseTests / DeepLinkTests /
│                              EventTests / FileStorageTests / HelpersTests /
│                              HookTests / ManagerTests / MenuTests /
│                              SwizzleTests / ThreadTests / UtilsTests
├── AutotrackerCoreTests/    ← Autotrack / GrowingNodeTests
├── ModulesTests/            ← ABTestingTests / AdvertisingTests / HybridTests /
│                              MobileDebuggerTests / ProtobufTests / WebCircleTests
├── ServicesTests/
├── HostApplicationTests/
├── GrowingAnalyticsStartTests/
├── GrowingAnalyticsUITests/
└── Helper/                  ← 复用的 Mock/Invocation/ManualTrack helper
```

所有测试源码最终都编译进 `GrowingAnalyticsTests` 这个 Xcode target（不是每个子目录一个 target）。运行时按 `GrowingAnalyticsTests.xctestplan` 调度，靠 `-only-testing:` 过滤子集。

### 基础骨架

```objc
@interface GrowingEventDatabaseTest : XCTestCase
@end

@implementation GrowingEventDatabaseTest

- (void)setUp {
    [super setUp];
    // 每个 case 前重置状态
}

- (void)tearDown {
    // 清理副作用，重置单例
    [super tearDown];
}

- (void)test_shouldPersistEventAfterTrack {
    // Red → Green → Refactor
    XCTAssertEqual(count, expectedCount);
}

@end
```

### 断言速查

| 断言 | 用途 |
|------|------|
| `XCTAssertEqual(a, b)` | 相等 |
| `XCTAssertNil(x)` / `XCTAssertNotNil(x)` | 空值 |
| `XCTAssertTrue(x)` / `XCTAssertFalse(x)` | 布尔 |
| `XCTAssertThrows(expr)` | 异常 |
| `XCTAssertEqualObjects(a, b)` | 对象相等 |

### 运行测试

```bash
# 与 .github/workflows/ci.yml 保持一致
xcodebuild test \
  -workspace Example/GrowingAnalytics.xcworkspace \
  -scheme GrowingAnalyticsTests \
  -testPlan GrowingAnalyticsTests \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro' \
  | xcbeautify

# 只跑单个子集（举例）
xcodebuild test \
  -workspace Example/GrowingAnalytics.xcworkspace \
  -scheme GrowingAnalyticsTests \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro' \
  -only-testing:GrowingAnalyticsTests/GrowingEventDatabaseTest \
  | xcbeautify
```

> `| xcbeautify` 是 CI 当前使用的格式化工具（`xcpretty` 亦可，但项目 workflow 已统一到 xcbeautify）。设备名以本机 `xcrun simctl list devices available` 为准。

## SDK 测试特有考量

### 异步事件流

事件从 `track:` 调用到入库是异步链路（后台 GCD 队列）。测试时：
- 使用 `XCTestExpectation` + `waitForExpectations:`
- 或在测试环境注入同步执行器

### 单例状态隔离

`tearDown` 必须重置会被当前 case 污染到的全局状态：SDK 单例、事件数据库、配置缓存等。SDK 本身不暴露统一的 `reset` API，具体策略看对象类型：
- 模块级：调用模块自带的重置方法，如 `[GrowingHybridModule.sharedInstance resetBridgeSettings]`
- 数据库：删除 `Example/GrowingAnalyticsTests/Helper/` 下测试辅助创建的数据库文件
- 配置：通过 `GrowingConfigurationManager` 重新 setConfiguration
- Mock：见 `MockEventQueue`、`InvocationHelper`

```objc
- (void)tearDown {
    // 按本 case 涉及的副作用逐个还原；禁止留空 tearDown
    [super tearDown];
}
```

### dataCollectionEnabled = NO

任何采集路径都必须有"关闭总开关后不采集"的测试。

## Rationalizations

| Excuse | Reality |
|---|---|
| "先写实现再补测试" | 测试退化为"验证代码写了什么" |
| "这块改动太简单不用测试" | 核心路径零例外 |
| "测试第一次就绿了" | 没见过 Red 的 Green 不可信 |
| "dataCollectionEnabled=false 的路径不用测" | 这是隐私合规红线 |

## Red Flags

- "让我先把实现写完，测试等会补" → 删掉实现，从 Red 开始
- "这个函数太简单了" → 核心路径零例外
- "测试第一次就绿了" → 检查测试是否真的覆盖了目标行为

## 关联 skill

- **完成后交接：** 测试通过 → `verification-before-completion`
