# ViewImpression

元素曝光采集：为视图标记一个事件，元素进入可视区域并满足曝光条件时，自动发送对应的自定义事件（`cstm`）。

只依赖 `TrackerCore`，纯埋点 SDK 也可使用。不支持 App Extension。

## 集成

CocoaPods：

```ruby
pod 'GrowingAnalytics/ViewImpression'
```

Swift Package Manager：添加 `GrowingModule_ViewImpression` product。

本模块与 `ImpressionTrack` 互斥。两者同时集成时 ViewImpression 接管，ImpressionTrack 自动禁用并输出错误日志。

## 快速开始

在 cell 绑定数据的地方标记即可，不需要在 `prepareForReuse` 里做任何清理。标记 cell 里的某个子视图（角标、价格标签等）同样如此。

```objc
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    GoodsCell *cell = [tableView dequeueReusableCellWithIdentifier:@"GoodsCell" forIndexPath:indexPath];
    Goods *goods = self.goodsList[indexPath.row];
    [cell bindGoods:goods];

    [cell growingMarkImpression:@"goods_impression"
                     attributes:@{@"goods_id": goods.goodsId, @"position": @(indexPath.row)}
                     identifier:goods.goodsId
                         config:nil];
    return cell;
}
```

```swift
func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "GoodsCell", for: indexPath) as! GoodsCell
    let goods = goodsList[indexPath.row]
    cell.bind(goods)

    cell.markImp("goods_impression",
                 attributes: ["goods_id": goods.goodsId, "position": indexPath.row],
                 identifier: goods.goodsId,
                 config: nil)
    return cell
}
```

`identifier` 填**业务上能唯一标识这个元素的值**（商品 ID、内容 ID 等），不是视图的标识。它决定了"只曝光一次"的判定口径，也是多槽位和精确移除的 key。

## API

标记与移除都是 `UIView` 分类方法：

| 方法 | Swift | 说明 |
|---|---|---|
| `growingMarkImpression:` | `markImp(_:)` | 标记，使用全局配置，写入默认槽位 |
| `growingMarkImpression:attributes:` | `markImp(_:attributes:)` | 同上，附带静态属性 |
| `growingMarkImpression:attributes:identifier:config:` | `markImp(_:attributes:identifier:config:)` | 完整形式，`identifier` 与 `config` 均可传 nil |
| `growingUpdateImpressionAttributes:identifier:` | `updateImpAttributes(_:identifier:)` | 只替换属性，不影响曝光状态 |
| `growingUnmarkImpression` | `unmarkImp()` | 移除该视图上的全部标记 |
| `growingUnmarkImpressionWithIdentifier:` | `unmarkImp(identifier:)` | 只移除一个标记 |

所有方法内部都会切到主线程执行，在子线程调用是安全的。

一个视图可以挂多个标记，槽位以 `identifier` 区分，各自独立判定、独立发送；`identifier` 传 nil 时写入默认槽位。

```objc
[cell growingMarkImpression:@"card_impression" attributes:nil identifier:@"card" config:nil];
[cell growingMarkImpression:@"badge_impression" attributes:nil identifier:@"badge" config:nil];

[cell growingUnmarkImpressionWithIdentifier:@"badge"];  // card 不受影响
```

**同一个事件名在一个视图上只保留一个槽位。** 再次标记时 `identifier` 变了，意味着这个视图承载的元素换了——cell 及其子视图被复用就是这种情况——旧槽位随即丢弃。所以在 `cellForRowAt` 里直接标记就行，既不需要在 `prepareForReuse` 里清理，也不会残留上一行的属性。

## 曝光条件

| 配置项 | 含义 | 默认值 |
|---|---|---|
| `viewImpressionScale` | 可见面积占元素自身面积的比例阈值，有效范围 0~1 | 0，露出即算 |
| `stayDuration` | 连续可见需要满足的最小时长，单位秒 | 0，无需停留 |
| `repeatable` | 是否允许同一元素多次曝光 | YES |

三项都可以按元素单独配置，也可以配全局默认值。优先级：**单元素 `config` > 全局 `viewImpressionConfig` > 默认值**。

```objc
GrowingViewImpressionConfig *config = [GrowingViewImpressionConfig configWithViewImpressionScale:0.5f
                                                                                    stayDuration:1.0
                                                                                      repeatable:NO];
[cell growingMarkImpression:@"goods_impression" attributes:nil identifier:goods.goodsId config:config];
```

全局配置挂在 `GrowingTrackConfiguration` 上，`GrowingAutotrackConfiguration` 同样适用：

```objc
configuration.viewImpressionEnabled = YES;        // 采集总开关，默认 YES
configuration.viewImpressionCheckInterval = 0.1;  // 检测节流间隔，单位秒，默认 0.1
configuration.viewImpressionConfig = [GrowingViewImpressionConfig configWithViewImpressionScale:0.5f
                                                                                   stayDuration:1.0
                                                                                     repeatable:YES];
```

这三项在 SDK 启动时读取，启动之后再改不会生效。

全局默认值不要配 `repeatable = NO`：它依赖 `identifier`，而未指定 `identifier` 的元素会被降级处理（见下文）。

可见性这样判定：从元素自身出发逐级向上，遇到会裁剪的祖先（`clipsToBounds` 为 YES，或 `UIScrollView`）就与它的 bounds 求交，最后与所在 window 求交，用剩下的面积比对阈值。

因此，滚出了滚动容器、但屏幕坐标仍落在屏内的元素，会被判定为不可见。

## 曝光时机

元素满足曝光条件时发送一次事件，此后**离开可视区再次进入**才会再发。以下情况不会重复发送：

- 元素一直停留在可视区内，无论停留多久
- App 退到后台再回到前台，期间元素没有离开过可视区
- 重复标记，但事件名、属性、配置三者都没有变化

最后一条使得列表刷新时对可见元素原样重标一次是安全的。三者中任一项发生变化则视为一次新的标记，曝光状态重置，元素满足条件时会再发送一次——所以**只想改属性时请用 `growingUpdateImpressionAttributes:identifier:`**，它不会触发重新曝光。

```objc
[cell growingUpdateImpressionAttributes:@{@"price": goods.currentPrice} identifier:goods.goodsId];
```

更新属性后，元素上保留的是更新后的属性。此后列表刷新若仍按原属性重新标记，将被视为属性发生变化，曝光状态随之重置，元素未离开可视区也会再次曝光。

## 只曝光一次

`repeatable = NO` 表示同一元素全程只曝光一次。

**此时必须指定 `identifier`。** "只曝光一次"的对象是元素而不是视图：cell 复用后视图相同而元素不同，同一元素滚回来又可能落在另一个 cell 实例上。已曝光记录因此按 `identifier` 记在模块的全局集合里，缺少 `identifier` 就无法区分元素——此时配置会被降级为 `repeatable = YES` 并输出告警日志。

该记录不区分事件名：同一 `identifier` 曝光一次后，以其标记的其他事件名均不再发送。需要各自独立判定时，应使用不同的 `identifier`。

下拉刷新、切换账号、切换数据源等场景需要主动清理记录：

```objc
[GrowingViewImpression resetImpressionStateWithIdentifier:goods.goodsId];  // 清一个
[GrowingViewImpression resetAllImpressionState];                          // 全清
```

重置会连同元素当前的曝光状态一起清掉，因此仍停在可视区内的元素无需移出再移入，下一个检测周期就会再曝光一次。

记录不随 session 自动重置。全局集合上限 10000 条，超限按插入顺序淘汰最早的记录并告警一次。

## 曝光回调

```objc
[[GrowingViewImpression sharedInstance] addImpressionDelegate:self];
```

| 方法 | 用途 |
|---|---|
| `growingImpressionShouldTrack:eventName:identifier:` | 返回 NO 则本次不发送。元素离开可视区再次进入时会重新询问；注册了多个 delegate 时任一返回 NO 即不发送 |
| `growingImpressionDynamicAttributes:eventName:identifier:` | 补充曝光时刻才能确定的属性（当时的排序位置、实时价格等），与标记时的静态属性合并，同名键以动态属性为准 |
| `growingImpressionDidTrack:eventName:identifier:` | 事件已生成 |

三个方法都是可选的。delegate 以弱引用持有，无需手动移除。

回调均在主线程同步执行，处在曝光检测的链路上，实现中不要做耗时操作。

## 从 ImpressionTrack 迁移

方法名替换：

| ImpressionTrack | ViewImpression |
|---|---|
| `growingTrackImpression:` | `growingMarkImpression:` |
| `growingTrackImpression:attributes:` | `growingMarkImpression:attributes:` |
| `growingStopTrackImpression` | `growingUnmarkImpression` |

三者语义一一对应。此外需要留意这些行为差异：

| 差异 | 影响 |
|---|---|
| 可见性判定更严格 | 按祖先逐级裁剪后与所在 window 求交，不再使用未裁剪的屏幕坐标。原先被误判为可见的元素不再曝光，**迁移后曝光量会下降** |
| 检测节流默认 0.1 秒 | ImpressionTrack 默认每次 runloop 休眠前都检测。极快速滑过的元素可能不再触发 |
| 前后台切换不再重发 | 元素未离开可视区时，App 退到后台再回到前台不会重新曝光。ImpressionTrack 会重发 |
| 不再受无埋点忽略规则约束 | 被 `ignoreViewClasses` / `ignorePolicy` 命中的视图，其手动标记的曝光将正常发送——主动调用标记 API 本身即表达了采集意图 |
| 配置不互通 | 不读取 `GrowingAutotrackConfiguration.impressionScale`，需改用 `viewImpressionConfig` |
| 不做方法交换 | 不再交换 `UIView` 的任何系统方法 |

## 限制

- **不做遮挡检测。** 被上层视图完全盖住的元素仍按可见处理。
- 元素或其祖先设置了 `transform` 时，面积占比的判定不准确。
