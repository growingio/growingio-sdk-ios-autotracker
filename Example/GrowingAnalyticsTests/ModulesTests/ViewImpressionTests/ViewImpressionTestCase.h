//
//  ViewImpressionTestCase.h
//  GrowingAnalytics
//
//  Created by YoloMao on 2026/9/21.
//  Copyright (C) 2026 Beijing Yishu Technology Co., Ltd.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

@class GrowingCustomEvent;

NS_ASSUME_NONNULL_BEGIN

/// 曝光用例的公共夹具：每个用例独占一个 375x667 的 window 与一个铺满的根视图，
/// 用例结束后 window 被销毁，标记过的视图随之释放，不会泄漏到下一个用例。
@interface ViewImpressionTestCase : XCTestCase

@property (nonatomic, strong, readonly) UIWindow *window;
@property (nonatomic, strong, readonly) UIView *rootView;

- (UIView *)addViewWithFrame:(CGRect)frame;
- (UIView *)addViewWithFrame:(CGRect)frame toView:(UIView *)parent;

/// 创建一个会裁剪子视图的滚动容器，用于构造"滚出容器但仍在屏幕内"的场景
- (UIScrollView *)addScrollViewWithFrame:(CGRect)frame contentSize:(CGSize)contentSize;

/// 驱动主 runloop 若干秒。检测循环挂在 runloop observer 上，用例中必须显式驱动才会触发
- (void)pumpRunLoopFor:(NSTimeInterval)seconds;

/// 等待自定义事件累积到 count 个，期间持续驱动 runloop
- (BOOL)waitForCustomEventCount:(NSUInteger)count timeout:(NSTimeInterval)timeout;

/// 当前已捕获的自定义事件个数
- (NSUInteger)customEventCount;

/// 最近一个自定义事件
- (nullable GrowingCustomEvent *)lastCustomEvent;

/// 断言在 seconds 内不再产生新的自定义事件
- (void)assertNoMoreCustomEventsWithin:(NSTimeInterval)seconds;

@end

NS_ASSUME_NONNULL_END
