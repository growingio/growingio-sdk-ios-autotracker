//
//  GrowingKIFTestConfiguration.m
//  GrowingAnalytics
//
//  Copyright (C) 2026 Beijing Yishu Technology Co., Ltd.
//

#import <KIF/KIF.h>
#import <KIF/UIApplication-KIFAdditions.h>
#import <XCTest/XCTest.h>

/// KIF 的每次交互（tap 前后各一次）都会调用 waitForAnimationsToFinish，
/// 其开头无条件等待 animationStabilizationTimeout（默认 0.5s），与是否真的存在动画无关，
/// 且该等待按 [UIApplication sharedApplication].animationSpeed 缩放
/// （见 KIFUITestActor.m -waitForAnimationsToFinishWithTimeout:stabilizationTime:）。
///
/// 提速后 UIKit 动画（window.layer.speed）与 KIF 的固定等待一并缩短，
/// 本 target 65 个用例实测 206.7s -> 130.2s。
static const float kGrowingKIFAnimationSpeed = 10.0f;

@interface GrowingKIFTestConfiguration : NSObject <XCTestObservation>

@end

@implementation GrowingKIFTestConfiguration

+ (void)load {
    static GrowingKIFTestConfiguration *observer = nil;
    observer = [[GrowingKIFTestConfiguration alloc] init];
    [[XCTestObservationCenter sharedTestObservationCenter] addTestObserver:observer];
}

- (void)testCaseWillStart:(XCTestCase *)testCase {
    // animationSpeed 写入的是当前已存在 window 的 layer.speed，之后新建的 window 不会继承，
    // 因此每个用例开始前设置一次，而非仅在 bundle 启动时设置
    [UIApplication sharedApplication].animationSpeed = kGrowingKIFAnimationSpeed;
}

@end
