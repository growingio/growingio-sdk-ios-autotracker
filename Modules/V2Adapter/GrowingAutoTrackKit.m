//
//  GrowingAutoTrackKit.m
//  GrowingAnalytics
//
//  Created by YoloMao on 2023/6/26.
//  Copyright (C) 2023 Beijing Yishu Technology Co., Ltd.
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

#if __has_include(<UIKit/UIKit.h>)
#import "Modules/V2Adapter/Public/GrowingAutoTrackKit.h"
#import <objc/message.h>
#import <objc/runtime.h>
#import "GrowingAutotrackerCore/Public/GrowingAutotrackConfiguration.h"
#import "GrowingTrackerCore/GrowingRealTracker.h"
#import "GrowingTrackerCore/Manager/GrowingConfigurationManager.h"
#import "GrowingTrackerCore/Thirdparty/Logger/GrowingLogger.h"
#import "Modules/V2AdapterTrackOnly/Public/GrowingV2Adapter.h"

@interface UIView (Internal)

@property (nonatomic, assign) GrowingIgnorePolicy growingViewIgnorePolicy;
@property (nonatomic, copy) NSString *growingViewCustomContent;
@property (nonatomic, copy) NSString *growingUniqueTag;

- (void)growingTrackImpression:(NSString *)eventName;
- (void)growingTrackImpression:(NSString *)eventName attributes:(NSDictionary<NSString *, NSString *> *)attributes;
- (void)growingStopTrackImpression;

@end

@implementation Growing (AutoTrackKit)

+ (NSString *)autoTrackKitVersion {
    return GrowingTrackerVersionName;
}

+ (void)setGlobalImpScale:(double)scale {
    GIOLogDebug(@"[V2Adapter] %s 请通过初始化配置impressionScale", __FUNCTION__);
}

+ (double)globalImpScale {
    GrowingTrackConfiguration *configuration = GrowingConfigurationManager.sharedInstance.trackConfiguration;
    if ([configuration isKindOfClass:[GrowingAutotrackConfiguration class]]) {
        return ((GrowingAutotrackConfiguration *)configuration).impressionScale;
    }

    return 0.0;
}

@end

@implementation UIView (AutoTrackKit)

- (void)setGrowingAttributesDonotTrack:(BOOL)growingAttributesDonotTrack {
    self.growingViewIgnorePolicy = growingAttributesDonotTrack ? GrowingIgnoreSelf : GrowingIgnoreNone;
}

- (BOOL)growingAttributesDonotTrack {
    return self.growingViewIgnorePolicy != (GrowingIgnoreNone || GrowingIgnoreChildren);
}

- (void)setGrowingAttributesValue:(NSString *)growingAttributesValue {
    self.growingViewCustomContent = growingAttributesValue;
}

- (NSString *)growingAttributesValue {
    return self.growingViewCustomContent;
}

- (void)setGrowingAttributesUniqueTag:(NSString *)growingAttributesUniqueTag {
    self.growingUniqueTag = growingAttributesUniqueTag;
}

- (NSString *)growingAttributesUniqueTag {
    return self.growingUniqueTag;
}

- (void)growingImpTrack:(NSString *)eventId {
    [self growingTrackImpression:eventId];
}

- (void)growingImpTrack:(NSString *)eventId withNumber:(NSNumber *)number {
    [self growingImpTrack:eventId];
}

- (void)growingImpTrack:(NSString *)eventId withVariable:(NSDictionary<NSString *, id> *)variable {
    variable = [GrowingV2Adapter fit3xDictionary:variable];
    [self growingTrackImpression:eventId attributes:variable];
}

- (void)growingImpTrack:(NSString *)eventId
             withNumber:(NSNumber *)number
            andVariable:(NSDictionary<NSString *, id> *)variable {
    [self growingImpTrack:eventId withVariable:variable];
}

- (void)growingStopImpTrack {
    [self growingStopTrackImpression];
}

@end

@implementation Growing (Deprecated)

+ (void)setHybridJSSDKUrlPrefix:(NSString *)urlPrefix {
    GIOLogDebug(@"[V2Adapter] %s 已废弃", __FUNCTION__);
}

+ (void)enableAllWebViews:(BOOL)enable {
    GIOLogDebug(@"[V2Adapter] %s 已废弃，请通过UIView分类属性growingViewIgnorePolicy设置单个webView采集", __FUNCTION__);
}

+ (void)enableHybridHashTag:(BOOL)enable {
    GIOLogDebug(@"[V2Adapter] %s 已废弃，请通过Web JS SDK配置", __FUNCTION__);
}

+ (BOOL)isTrackingWebView {
    GIOLogDebug(@"[V2Adapter] %s 已废弃", __FUNCTION__);
    return YES;
}

+ (void)setImp:(BOOL)imp {
    GIOLogDebug(@"[V2Adapter] %s 已废弃", __FUNCTION__);
}

+ (void)setPageVariable:(NSDictionary<NSString *, NSObject *> *)variable
       toViewController:(UIViewController *)viewController {
    GIOLogDebug(@"[V2Adapter] %s 已废弃，请参考集成文档使用当前最新API", __FUNCTION__);
}

+ (void)setPageVariableWithKey:(NSString *)key
                andStringValue:(NSString *)stringValue
              toViewController:(UIViewController *)viewController {
    GIOLogDebug(@"[V2Adapter] %s 已废弃，请参考集成文档使用当前最新API", __FUNCTION__);
}

+ (void)setPageVariableWithKey:(NSString *)key
                andNumberValue:(NSNumber *)numberValue
              toViewController:(UIViewController *)viewController {
    GIOLogDebug(@"[V2Adapter] %s 已废弃，请参考集成文档使用当前最新API", __FUNCTION__);
}

+ (void)setAppVariable:(NSDictionary<NSString *, NSObject *> *)variable {
    GIOLogDebug(@"[V2Adapter] %s 已废弃", __FUNCTION__);
}

+ (void)setAppVariableWithKey:(NSString *)key andStringValue:(NSString *)stringValue {
    GIOLogDebug(@"[V2Adapter] %s 已废弃", __FUNCTION__);
}

+ (void)setAppVariableWithKey:(NSString *)key andNumberValue:(NSNumber *)numberValue {
    GIOLogDebug(@"[V2Adapter] %s 已废弃", __FUNCTION__);
}

@end

@implementation UIView (Deprecated)

- (double)growingImpScale {
    GIOLogDebug(@"[V2Adapter] %s 已废弃", __FUNCTION__);

    GrowingTrackConfiguration *configuration = GrowingConfigurationManager.sharedInstance.trackConfiguration;
    if ([configuration isKindOfClass:[GrowingAutotrackConfiguration class]]) {
        return ((GrowingAutotrackConfiguration *)configuration).impressionScale;
    }
    return 0.0;
}

- (void)setGrowingImpScale:(double)scale {
    GIOLogDebug(@"[V2Adapter] %s 已废弃", __FUNCTION__);
}

- (void)setGrowingAttributesDonotTrackImp:(BOOL)growingAttributesDonotTrackImp {
    GIOLogDebug(@"[V2Adapter] %s 已废弃", __FUNCTION__);
}

- (BOOL)growingAttributesDonotTrackImp {
    GIOLogDebug(@"[V2Adapter] %s 已废弃", __FUNCTION__);
    return NO;
}

- (void)setGrowingAttributesDonotTrackValue:(BOOL)growingAttributesDonotTrackValue {
    GIOLogDebug(@"[V2Adapter] %s 已废弃", __FUNCTION__);
}

- (BOOL)growingAttributesDonotTrackValue {
    GIOLogDebug(@"[V2Adapter] %s 已废弃", __FUNCTION__);
    return NO;
}

- (void)setGrowingSDCycleBannerIds:(NSArray<NSString *> *)growingSDCycleBannerIds {
    GIOLogDebug(@"[V2Adapter] %s 已废弃", __FUNCTION__);
}

- (NSArray<NSString *> *)growingSDCycleBannerIds {
    GIOLogDebug(@"[V2Adapter] %s 已废弃", __FUNCTION__);
    return @[];
}

- (void)setGrowingAttributesInfo:(NSString *)growingAttributesInfo {
    GIOLogDebug(@"[V2Adapter] %s 已废弃", __FUNCTION__);
}

- (NSString *)growingAttributesInfo {
    GIOLogDebug(@"[V2Adapter] %s 已废弃", __FUNCTION__);
    return @"";
}

@end

@implementation UIViewController (Deprecated)

- (void)setGrowingAttributesInfo:(NSString *)growingAttributesInfo {
    GIOLogDebug(@"[V2Adapter] %s 已废弃", __FUNCTION__);
}

- (NSString *)growingAttributesInfo {
    GIOLogDebug(@"[V2Adapter] %s 已废弃", __FUNCTION__);
    return @"";
}

- (void)setGrowingAttributesPageName:(NSString *)growingAttributesPageName {
    GIOLogDebug(@"[V2Adapter] %s 已废弃，请参考集成文档使用当前最新API", __FUNCTION__);
}

- (NSString *)growingAttributesPageName {
    GIOLogDebug(@"[V2Adapter] %s 已废弃，请参考集成文档使用当前最新API", __FUNCTION__);
    return @"";
}

@end

@implementation WKWebView (Deprecated)

- (void)setGrowingAttributesIsTracked:(BOOL)growingAttributesIsTracked {
    GIOLogDebug(@"[V2Adapter] %s 已废弃", __FUNCTION__);
}

- (BOOL)growingAttributesIsTracked {
    GIOLogDebug(@"[V2Adapter] %s 已废弃", __FUNCTION__);
    return NO;
}

@end
#endif
