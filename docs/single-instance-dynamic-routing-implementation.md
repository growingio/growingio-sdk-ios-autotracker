# 动态路由实施状态与接入

本分支实现原生切换、分源缓存与上传，以及模块侧的上下文传递。发布仍须通过设计文档的验收；下列外部依赖未完成前保持草稿状态。

## 使用

初始化时设置 `serverHostMapping`，未设置时由初始数据源和采集地址生成单条映射。切换示例：

```objc
[GrowingAutotracker.sharedInstance updateDataSourceId:@"数据源B"
                          dataCollectionServerHost:nil
                                        completion:^(NSError *error) {
    // 回调在主线程；成功表示本地已提交，不表示事件已落盘或上传完成。
}];
```

`GrowingTracker` 使用相同接口。表内数据源可省略地址；表外数据源须提供有效 HTTP(S) 地址，业务负责将新增组合纳入下次初始化配置。

存储采用现有 JSON/PB 共库增加 `dataSourceId` 索引。旧缓存从事件内容恢复归属，表外缓存暂停上传至过期；跨启动改指后，旧缓存使用本次配置的地址。

上传沿用原有通道和定时器，即时发送只触发指定通道。同一通道依次查询各数据源的批次，通过映射表固定请求地址；失败事件保留，继续尝试其他数据源。每通道同一时间一个请求，慢请求会延迟该通道后续数据源；不维护额外调度状态，不反复释放数据库连接。

原生 PAGE 补发复用现有 `currentPage` 和 PAGE builder，在主线程读取页面信息，在切换后的事件线程填入新 Session 和当前时间；不维护额外的页面快照、Session 去重表或展示标识。正常页面生命周期沿用原逻辑。

## 模块协议

核心模块通知 `growingModDataSourceChanged:` 的 `customParam` 包含 `oldContext`、`newContext`。上下文包含 `dataSourceId`、`sessionId`、`sequence` 和身份快照；只在本地及桥接协议中使用。

异步任务在接受时保存上下文，生成派生事件时设置 `GrowingBaseBuilder.eventContext`。未设置的普通事件使用事件入口处理时的当前上下文。

### Web

- 原生通过桥接的 `_updateRoutingContext` 通知现有页面，页面收到 `GrowingIORoutingChange` 事件。
- Web SDK 应用新数据源、Session 并按既有页面口径生成一次 PAGE，然后调用 `confirmRoutingContext(context)`。
- 普通 Session 刷新也使用同一通知；序号相同时用 Session 区分，不能只按序号去重。
- Web SDK 在事件产生时通过 `getRoutingContext()` 获取快照，写入事件消息的 `routingContext`，积压队列保留该快照。
- 未确认前桥接沿用旧上下文；确认按序号匹配，迟到确认不覆盖新状态。切换后缺少上下文的消息会记录协议错误。

### Flutter / UniApp

插件通过 `onDataSourceChanged` 接收新上下文，应用后调用 `confirmRoutingContext:`。Flutter 的页面、元素事件参数携带 `routingContext`；UniApp 使用新增的 `trackPageEvent:attributes:routingContext:`。旧入口在等待同步期间保留原归属，插件须适配新协议才能完成切换。

### 自定义存储

`GrowingEventDatabaseService` 新增可选的 `dataSourceIds` 和 `getEventsByCount:limitSize:policy:dataSourceId:`。动态切换要求实现这两个方法，过滤须先于批次数量限制；不支持时切换返回错误。

插入须按 UUID 幂等，重试不能刷新原创建时间；写盘失败时 SDK 保留待写操作。默认数据库已实现这些约束。

## 发布前待完成

- Web SDK、Flutter、UniApp 外部插件接入以上协议并完成积压、连续切换和 PAGE 去重联调。
- APM 当前依赖的回调没有报告生成时的数据源/Session 快照。历史及延迟报告无法仅凭回调恢复归属；需由 APM 生产端在报告生成时保存并传回上下文，再完成原生转换适配。现阶段不宣称 APM 动态切换支持完成。
- 数据平台验证乱序及上下文缺失的关联、重复请求处理，以及跨启动改指后旧缓存的入库结果（C15、C19）。
- 按设计文档完成多窗口、跨端和失败恢复的完整验收；本地编译与单元回归不替代这些联调。
