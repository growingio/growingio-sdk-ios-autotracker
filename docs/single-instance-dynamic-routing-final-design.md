# 单实例数据源与上报地址切换

SDK 维护 `dataSourceId → 上报地址` 映射。切换后，新事件使用新的 dataSourceId 和 Session；旧缓存保留原字段，发送时通过自身的 dataSourceId 查询原地址。

## 1 初始化

```objc
GrowingAutotrackConfiguration *configuration =
    [GrowingAutotrackConfiguration configurationWithAccountId:@"accountId"];
configuration.dataSourceId = @"A";
configuration.serverHostMapping = @{
    @"A": @"https://host-a.example.com",
    @"B": @"https://host-b.example.com",
};
[GrowingAutotracker startWithConfiguration:configuration launchOptions:nil];
```

`GrowingTracker` 使用 `GrowingTrackConfiguration`，配置与切换方式相同。

- 提供 `serverHostMapping` 时以表为准，初始 dataSourceId 必须在表内；未提供时，由初始 dataSourceId 和 `dataCollectionServerHost` 生成单条映射。
- 地址须为绝对 HTTP(S) URL，可带基路径，不接受用户名、密码、查询参数或 fragment。地址按传入字符串保存和比较。
- 映射只决定采集上报地址，`accountId` 保持不变。

## 2 切换接口与时序

```objc
- (void)updateDataSourceId:(NSString *)dataSourceId
 dataCollectionServerHost:(nullable NSString *)serverHost
               completion:(void (^ _Nullable)(NSError * _Nullable error))completion;
```

| 入参 | 行为 |
| --- | --- |
| dataSourceId 已在表中 | serverHost 可为 nil；传入时须与已注册地址一致 |
| dataSourceId 不在表中 | 须提供有效地址，成功时追加映射并切换 |
| dataSourceId 与当前相同 | 地址校验通过后成功返回，不刷新 Session 或补事件 |
| 参数无效、地址冲突或 SDK 未初始化 | 返回错误，保持原状态 |

复用 `dispatchInGrowingThread` 更新配置、刷新 Session 并生成事件，完成回调派发到主线程。成功表示本地切换完成，不表示事件已落盘或上传；切换不等待历史缓存清空。

后台调用时，无埋点 SDK 需要先回主线程读取页面。依赖新数据源的埋点应等成功回调后发送：

```objc
[GrowingAutotracker.sharedInstance updateDataSourceId:@"B"
                          dataCollectionServerHost:nil
                                        completion:^(NSError *error) {
    if (error) {
        NSLog(@"切换失败：%@", error.localizedDescription);
        return;
    }
    [GrowingAutotracker.sharedInstance trackCustomEvent:@"afterSwitch"];
}];
```

事件和切换进入 GrowingThread 后按实际处理顺序生效。事件构建时读取当前 dataSourceId、Session 和登录身份，已构建或入库的事件保持原字段。连续切换时，回调对应的数据源可能已被后续切换替代；业务应等待一次切换完成后再发起依赖它的操作。

## 3 Session 与 PAGE

- 每次有效切换创建新 Session，包括 A→B→A；按采集开关和现有事件过滤规则生成 VISIT。
- 无埋点 SDK 由 `GrowingRealAutotracker` 复用 `currentPage` 和现有 PAGE 构建逻辑，为符合采集规则的当前页面补发一次 PAGE，使用新 Session 和当前时间。后台、无当前页面、纯埋点模式不补 PAGE；正常页面生命周期照常采集。
- Device ID、登录身份、采集开关和计时器保持原有行为。计时事件在 A 开始、B 结束时，完整时长归 B 与结束时的 Session。

## 4 缓存与上传

沿用现有 JSON/PB 数据库、表结构和查询接口。所有数据源共用原有数据库，事件正文中的 dataSourceId 和 Session 不改写。

发送流程：

1. 在原有通道中按发送策略查询一批事件，沿用 500 条、2 MB 的限制及现有过滤逻辑。
2. 取出后按事件自身的 dataSourceId 分组，跳过映射表外的数据源，按首次出现顺序依次发送各组。
3. 每组通过 dataSourceId 查表取得地址，并固定本次请求的地址和事件批次。
4. 成功后按该组 UUID 删除事件；失败保留事件，继续处理本批其他组。各组处理完后释放通道上传状态；全部成功且剩余缓存至少 500 条时立即续传，否则等待下次上传触发。

复用原有通道、上传定时器和即时发送入口。每个通道同时一个请求，不同通道仍可并行，网络到达顺序不保证。同一通道前面的失败或表外缓存可能占满查询批次，使后面的数据源等待。

写入、删除和过期清理沿用原有逻辑。过期数据在初始化时按 `dataValidityPeriod`（默认 7 天）清理；表外缓存暂停上传。

## 5 重启与模块边界

SDK 不持久化映射表。业务重启时传入包含旧组合的完整映射，历史缓存才能继续通过原 dataSourceId 找到旧地址；新采集使用启动配置和新 Session。

**旧 dataSourceId 应持续映射旧地址，更换地址使用新的 dataSourceId。** SDK 只校验本次运行内的地址冲突；若业务跨启动将同一 ID 改指新地址，旧缓存也会按新映射发送，无法满足旧缓存发往旧域名的要求。

各模块及跨端协议沿用现有实现。异步回调和跨端消息在原生构建事件时使用当前配置。业务等待 ABTesting 等异步操作回调后再切换；实验缓存、调试与圈选 WebSocket、各模块服务地址保持原有行为。

## 6 验收重点

| 场景 | 预期结果 |
| --- | --- |
| 当前页面 A→B→A | 两次新 Session，按规则生成 VISIT/PAGE；后续事件归属正确 |
| 返回保留页面后切换、后台或纯埋点模式切换 | 当前页面补发正确，无页面时不补发 |
| 相同数据源、无效参数、地址冲突、SDK 未初始化 | 幂等或返回错误，状态与事件增量符合第 2 节 |
| A 的缓存和在途请求存在时切 B | A 的请求及重试仍发 A 地址，B 的事件发 B 地址 |
| 混合数据源、数量或大小达到批次上限、某源失败 | 请求不混源、地址正确；仅删除成功组，失败保留并处理本批其他组，续传沿用第 4 节条件 |
| 关闭采集、计时事件跨切换、后台线程发起切换 | 开关和计时规则保持，回调后依赖事件使用新配置 |
| 旧 JSON/PB 缓存、重启后补报 | 直接读取原事件归属，通过旧映射恢复旧地址 |
| Tracker/Autotracker、CocoaPods/SPM 与原有模块回归 | 接口和既有模块行为保持可用 |

单元测试结果、构建结果及尚未完成的验证记录在 PR 说明中。
