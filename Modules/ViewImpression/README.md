# ViewImpression 元素曝光

元素进入可视区域时发送自定义事件（cstm）。只依赖 `TrackerCore`，纯埋点 SDK 也可使用。

## 集成

CocoaPods：

```ruby
pod 'GrowingAnalytics/ViewImpression'
```

Swift Package Manager：添加 `GrowingModule_ViewImpression` product。

> 本模块与 `ImpressionTrack` 互斥。两者同时集成时 ViewImpression 接管，ImpressionTrack 自动禁用并输出日志。

## 标记元素

```objc
[cell.titleLabel growingMarkImpression:@"goods_impression"];

[cell growingMarkImpression:@"goods_impression" attributes:@{@"goods_id": goods.identifier}];

[cell growingMarkImpression:@"goods_impression"
                 attributes:@{@"goods_id": goods.identifier}
                 identifier:goods.identifier
                     config:[GrowingViewImpressionConfig configWithViewImpressionScale:0.5f
                                                                          stayDuration:1.0
                                                                            repeatable:NO]];
```

Swift：

```swift
cell.markImp("goods_impression", attributes: ["goods_id": goods.identifier])
```

同一视图可以挂载多个 `identifier` 不同的曝光标记；`identifier` 传 nil 时写入默认槽位。

重复标记同一个槽位时：事件名、属性、配置三者都没变化则保留原有曝光状态，不会重复发送——列表刷新对可见元素原样重标一次是安全的；任一项发生变化则视为新的标记，元素满足曝光条件时会再发送一次。只想改属性请用下面的更新方法。

只更新属性、不触发重新曝光：

```objc
[cell growingUpdateImpressionAttributes:@{@"price": price} identifier:goods.identifier];
```

移除标记：

```objc
[cell growingUnmarkImpression];                                  // 移除该视图上全部标记
[cell growingUnmarkImpressionWithIdentifier:goods.identifier];   // 只移除一个
```

## 曝光条件

| 配置 | 含义 | 默认值 |
|---|---|---|
| `viewImpressionScale` | 可见面积占自身面积的比例阈值，有效范围 0~1 | 0（露出即算曝光） |
| `stayDuration` | 连续可见需满足的最小时长，单位秒 | 0（无需停留） |
| `repeatable` | 是否允许同一元素多次曝光 | YES |

配置优先级：**单元素 config > 全局 `viewImpressionConfig` > 默认值**。

全局配置：

```objc
GrowingAutotrackConfiguration *configuration = [GrowingAutotrackConfiguration configurationWithAccountId:@"..."];
configuration.viewImpressionEnabled = YES;        // 采集总开关，默认 YES
configuration.viewImpressionCheckInterval = 0.1;  // 检测节流间隔，默认 0.1 秒
configuration.viewImpressionConfig = [GrowingViewImpressionConfig configWithViewImpressionScale:0.5f
                                                                                   stayDuration:1.0
                                                                                     repeatable:YES];
```

### repeatable = NO 必须指定 identifier

"只曝光一次"的对象是**元素**而不是视图：cell 复用后视图相同而元素不同，同一元素滚回来又可能落在另一个 cell 实例上。因此已曝光记录按 `identifier` 记在全局，缺少 identifier 时无法区分元素，此时会降级为 `repeatable = YES` 并输出告警。

已曝光记录上限 10000 条，超限按插入顺序淘汰。下拉刷新、切换账号、切换数据源等场景请主动清理：

```objc
[GrowingViewImpression resetImpressionStateWithIdentifier:goods.identifier];
[GrowingViewImpression resetAllImpressionState];
```

重置会同时清掉当前仍停在可视区内的元素的曝光状态，这些元素无需移出再移入即可再次曝光。记录不随 session 自动重置。

## 什么时候会再次曝光

元素**离开可视区后再次进入**时重新曝光。以下情况不会重新曝光：

- 元素一直停留在可视区内，无论停留多久
- App 退到后台再回到前台，期间元素没有离开可视区
- 重复标记但内容未变化（见上）

配置了 `repeatable = NO` 时，同一 `identifier` 全程只曝光一次，直到调用状态重置方法——重置后即便元素一直停在可视区内，也会立刻再曝光一次。

## 曝光回调

```objc
[[GrowingViewImpression sharedInstance] addImpressionDelegate:self];
```

| 方法 | 用途 |
|---|---|
| `growingImpressionShouldTrack:eventName:identifier:` | 返回 NO 则本次不发送；元素离开可视区再次进入时重新询问 |
| `growingImpressionDynamicAttributes:eventName:identifier:` | 曝光时刻才能确定的属性（当时的排序位置、实时价格等），与静态属性合并，同名键以动态属性为准 |
| `growingImpressionDidTrack:eventName:identifier:` | 事件已生成 |

delegate 为弱引用，无需手动移除。三个回调均在主线程同步执行，实现中不要做耗时操作。

## 从 ImpressionTrack 迁移

| ImpressionTrack | ViewImpression |
|---|---|
| `growingTrackImpression:` | `growingMarkImpression:` |
| `growingTrackImpression:attributes:` | `growingMarkImpression:attributes:` |
| `growingStopTrackImpression` | `growingUnmarkImpression` |
| — | `growingMarkImpression:attributes:identifier:config:` |
| — | `growingUpdateImpressionAttributes:identifier:` |
| — | `growingUnmarkImpressionWithIdentifier:` |

前三行一一对应，替换方法名即可。此外需要注意：

| 变化 | 影响 |
|---|---|
| 可见性判定更严格 | 按祖先逐级裁剪后与所在 window 求交，不再使用未裁剪的屏幕坐标。原先被误判为可见的元素不再曝光，**迁移后曝光量会下降** |
| 检测节流默认 0.1 秒 | 原模块默认每次 runloop 休眠前都检测。极快速滑过的元素可能不再触发 |
| 不再受无埋点忽略规则约束 | 被 `ignoreViewClasses` / `ignorePolicy` 命中的视图，其手动标记的曝光将正常发送——主动调用标记 API 本身即表达了采集意图 |
| 配置不互通 | 不读取 `GrowingAutotrackConfiguration.impressionScale`，需改用 `viewImpressionConfig` |
| 前后台切换不再重发 | 元素未离开可视区时，App 退到后台再回到前台不会重新曝光。ImpressionTrack 会重发 |
| 不做 swizzle | 不再交换 `UIView` 的任何系统方法 |

## 已知限制

- 不做遮挡检测。被上层视图盖住的元素仍按可见处理。
- 元素或其祖先设置了 `transform` 时，面积占比的判定不准确。
