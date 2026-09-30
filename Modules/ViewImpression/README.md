# ViewImpression

元素曝光采集：为视图标记一个事件，元素进入可视区域并满足曝光条件时，自动发送对应的自定义事件（`cstm`）。

曝光事件携带 `path`，page 体系本身属于无埋点能力，因此本模块依赖 `AutotrackerCore`，并随无埋点开关 `autotrackEnabled` 一起关闭。不支持 App Extension。

## 集成

CocoaPods：

```ruby
pod 'GrowingAnalytics/ViewImpression'
```

Swift Package Manager：添加 `GrowingModule_ViewImpression` product。

本模块与 `ImpressionTrack` 互斥。两者同时集成时 ViewImpression 接管，ImpressionTrack 自动禁用并输出错误日志。

## 快速开始

在元素上屏前标记即可，列表场景直接在 `cellForRowAt` 里标记复用的 cell 或其子视图：

```objc
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    GoodsCell *cell = [tableView dequeueReusableCellWithIdentifier:@"GoodsCell" forIndexPath:indexPath];
    Goods *goods = self.goodsList[indexPath.row];
    [cell bindGoods:goods];

    [cell growingTrackViewImpression:@"goods_impression"
                          attributes:@{@"goods_id": goods.goodsId, @"position": @(indexPath.row)}];
    return cell;
}
```

```swift
func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "GoodsCell", for: indexPath) as! GoodsCell
    let goods = goodsList[indexPath.row]
    cell.bind(goods)

    cell.trackViewImpression("goods_impression",
                             attributes: ["goods_id": goods.goodsId, "position": indexPath.row])
    return cell
}
```

## API

标记与移除都是 `UIView` 分类方法：

| 方法 | Swift | 说明 |
|---|---|---|
| `growingTrackViewImpression:` | `trackViewImpression(_:)` | 标记，使用全局配置 |
| `growingTrackViewImpression:attributes:` | `trackViewImpression(_:attributes:)` | 同上，附带静态属性 |
| `growingStopTrackViewImpression` | `stopTrackViewImpression()` | 移除该视图上的全部标记 |

所有方法内部都会切到主线程执行，在子线程调用是安全的。

标记遵循无埋点的忽略规则：视图被 `GrowingAutotrackConfiguration.ignoreViewClasses` 命中，或自身/任一祖先设置了 `GrowingIgnoreAll`、`GrowingIgnoreSelf`、`GrowingIgnoreChildren`，标记会被忽略并输出一条警告日志。

重复标记同一事件名时，事件名、属性、配置三者都没有变化则不重置曝光状态；任一项发生变化视为一次新的标记。因此列表刷新时对可见元素原样重标一次是安全的，cell 复用后绑定新数据重新标记也不会残留上一行的内容。

## 曝光条件

| 配置项 | 含义 | 默认值 |
|---|---|---|
| `impressionScale` | 可见面积占元素自身面积的比例阈值，有效范围 0~1 | 0，露出即算 |
| `stayDuration` | 连续可见需要满足的最小时长，单位秒 | 0，无需停留 |

两项通过全局配置统一设置，挂在 `GrowingTrackConfiguration` 上，`GrowingAutotrackConfiguration` 同样适用：

```objc
configuration.viewImpressionConfig = [GrowingImpressionConfig configWithImpressionScale:0.5f
                                                                           stayDuration:1.0];
configuration.viewImpressionEnabled = YES;  // 曝光开关，默认 YES；autotrackEnabled 为 NO 时无论如何都不采集
```

配置在 SDK 启动时读取，启动之后再改不会生效。

可见性这样判定：从元素自身出发逐级向上，遇到会裁剪的祖先（`clipsToBounds` 为 YES，或 `UIScrollView`）就与它的 bounds 求交，最后与所在 window 求交，用剩下的面积比对阈值。

因此，滚出了滚动容器、但屏幕坐标仍落在屏内的元素，会被判定为不可见。

## 重复曝光

默认支持重复曝光：元素满足条件发送一次事件后，**离开可视区再次进入**会再发一次。以下情况不会重复发送：

- 元素一直停留在可视区内，无论停留多久
- App 退到后台再回到前台，期间元素没有离开过可视区
- 重复标记，但事件名、属性、配置三者都没有变化

## 从 ImpressionTrack 迁移

方法名替换：

| ImpressionTrack | ViewImpression |
|---|---|
| `growingTrackImpression:` | `growingTrackViewImpression:` |
| `growingTrackImpression:attributes:` | `growingTrackViewImpression:attributes:` |
| `growingStopTrackImpression` | `growingStopTrackViewImpression` |

三者语义一一对应。此外需要留意这些行为差异：

| 差异 | 影响 |
|---|---|
| 可见性判定更严格 | 按祖先逐级裁剪后与所在 window 求交，不再使用未裁剪的屏幕坐标。原先被误判为可见的元素不再曝光，**迁移后曝光量会下降** |
| 检测节流默认 0.5 秒 | ImpressionTrack 默认每次 runloop 休眠前都检测。极快速滑过的元素可能不再触发 |
| 前后台切换不再重发 | 元素未离开可视区时，App 退到后台再回到前台不会重新曝光。ImpressionTrack 会重发 |
| 标记时不判可见性 | ImpressionTrack 在 `addNode:` 里连 `hidden` / `alpha` / `window` 一起判，标记尚未上屏的视图会被丢弃，靠 swizzle `didMoveToSuperview` 补标。本模块不做 swizzle，标记只判忽略规则，可见性交给每轮检测——先标记后上屏同样会曝光 |
| 配置不互通 | 不读取 `GrowingAutotrackConfiguration.impressionScale`，需改用 `viewImpressionConfig` |
| 不做方法交换 | 不再交换 `UIView` 的任何系统方法 |

## 限制

- **不做遮挡检测。** 被上层视图完全盖住的元素仍按可见处理。
- 元素或其祖先设置了 `transform` 时，面积占比的判定不准确。
