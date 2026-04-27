# GrowingIO iOS SDK

**GrowingIO iOS SDK** 是面向 iOS/macOS/watchOS/tvOS/visionOS 应用的数据分析 SDK，提供自动事件采集和手动埋点 API。

- **GrowingTrackerCore** — 核心 SDK 模块（事件管道、存储、网络、Session）
- **GrowingTracker** — 纯埋点 SDK（无无埋点功能）
- **GrowingAutotrackerCore** — 无埋点核心模块
- **GrowingAutotracker** — 完整 SDK（埋点 + 无埋点）
- **Services/** — `GrowingBaseService` 协议默认实现（Compression、Database、Encryption、JSON、Network、Protobuf、Screenshot、WebSocket）
- **Modules/** — 可选模块（ABTesting、Advertising、APM、DefaultServices、Flutter、Hybrid、ImpressionTrack、MobileDebugger、UniApp、V2Adapter、V2AdapterTrackOnly、WebCircle）

## 技术栈

- 平台：iOS 10+ / macOS 10.12+ / watchOS 7+ / tvOS 12+ / visionOS 1+
- 主要语言：Objective-C（部分 Swift）
- 包管理器：CocoaPods、Swift Package Manager（SPM）
- 构建工具：Xcode / xcodebuild
- 测试框架：XCTest

## 工程指南

> **注意**：以下文档为 lazy-load（不自动注入），按需读取：
>
> - `docs/agents-skills-flow.md` — agents/skills 流转结构图与主控制器工作流
> - `docs/specs/` — brainstorming 产出的功能规格文档
>
> 对 SDK 领域知识（设计约束、场景路由）以"模块快速索引 + 源码 + 近期 commit"为准，不再维护独立手册。

## 模块快速索引

| 模块 | 路径 | 职责 |
|------|------|------|
| Core | `GrowingTrackerCore/Core/` | 上下文（`GrowingContext`）、模块/服务管理器、Annotation |
| Event | `GrowingTrackerCore/Event/` | 事件构建、事件管道（`GrowingEventManager`）、事件通道、过滤 |
| Database | `GrowingTrackerCore/Database/` | 事件持久化入口（`GrowingEventDatabase`，实际存储由 `Services/Database/` 提供） |
| Network | `GrowingTrackerCore/Network/` | 网络可达性监听、请求路径、重试 |
| Manager | `GrowingTrackerCore/Manager/` | `GrowingConfigurationManager`、`GrowingSession` |
| Public API | `GrowingTrackerCore/Public/*.h` | 公开接口头文件（含 `GrowingBaseService`、`GrowingModuleProtocol` 等协议） |
| Services | `Services/` | `GrowingBaseService` 的默认实现（SQLite、加密、压缩、WebSocket 等） |
