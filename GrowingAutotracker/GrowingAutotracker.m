//
//  Created by xiangyang on 2020/11/6.
//  Copyright (C) 2017 Beijing Yishu Technology Co., Ltd.
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

#import "GrowingAutotracker.h"
#import "GrowingLogMacros.h"
#import "GrowingCocoaLumberjack.h"

static GrowingAutotracker *sharedInstance = nil;

@interface GrowingAutotracker ()
@property(nonatomic, strong, readonly) GrowingRealAutotracker *realAutotracker;
@end

@implementation GrowingAutotracker
- (instancetype)initWithRealAutotracker:(GrowingRealAutotracker *)realAutotracker {
    self = [super init];
    if (self) {
        _realAutotracker = realAutotracker;
    }

    return self;
}

+ (void)startWithConfiguration:(GrowingTrackConfiguration *)configuration launchOptions:(NSDictionary *)launchOptions {
    if (![NSThread isMainThread]) {
        @throw [NSException exceptionWithName:@"初始化异常" reason:@"请在applicationDidFinishLaunching中调用startWithConfiguration函数,并且确保在主线程中" userInfo:nil];
    }

    if (!configuration.projectId.length) {
        @throw [NSException exceptionWithName:@"初始化异常" reason:@"ProjectId不能为空" userInfo:nil];
    }

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        GrowingRealAutotracker *autotracker = [GrowingRealAutotracker trackerWithConfiguration:configuration launchOptions:launchOptions];
        sharedInstance = [[self alloc] initWithRealAutotracker:autotracker];
    });
}

+ (instancetype)sharedInstance {
    if (!sharedInstance) {
        @throw [NSException exceptionWithName:@"GrowingAutotracker未初始化" reason:@"请在applicationDidFinishLaunching中调用startWithConfiguration函数,并且确保在主线程中" userInfo:nil];
    }
    return sharedInstance;
}

//- (void)trackCustomEvent:(NSString *)eventName {
//    [_realAutotracker trackCustomEvent:eventName];
//}
//
//- (void)trackCustomEvent:(NSString *)eventName withAttributes:(NSDictionary<NSString *, NSString *> *)attributes {
//    [_realAutotracker trackCustomEvent:eventName withAttributes:attributes];
//}
//
//- (void)setLoginUserAttributes:(NSDictionary<NSString *, NSString *> *)attributes {
//    [_realAutotracker setLoginUserAttributes:attributes];
//}
//
//- (void)setVisitorAttributes:(NSDictionary<NSString *, NSString *> *)attributes {
//    [_realAutotracker setVisitorAttributes:attributes];
//}
//
//- (void)setConversionVariables:(NSDictionary<NSString *, NSString *> *)variables {
//    [_realAutotracker setConversionVariables:variables];
//}
//
//- (void)setLoginUserId:(NSString *)userId {
//    [_realAutotracker setLoginUserId:userId];
//}
//
//- (void)cleanLoginUserId {
//    [_realAutotracker cleanLoginUserId];
//}
//
//- (void)setDataCollectionEnabled:(BOOL)enabled {
//    [_realAutotracker setDataCollectionEnabled:enabled];
//}
//
//- (NSString *)getDeviceId {
//    return [_realAutotracker getDeviceId];
//}
///// 设置经纬度坐标
///// @param latitude 纬度
///// @param longitude 经度
//- (void)setLocation:(double)latitude longitude:(double)longitude {
//    [_realAutotracker setLocation:latitude longitude:longitude];
//}
//
///// 清除地理位置
//- (void)cleanLocation {
//    [_realAutotracker cleanLocation];
//}

#pragma mark - proxy protocol

- (id)forwardingTargetForSelector:(SEL)selector {
    return _realAutotracker;
}

- (void)forwardInvocation:(NSInvocation *)invocation {
    if (![_realAutotracker respondsToSelector:[invocation selector]]) {
        GIOLogError(@"GrowingAutotracker can't find method name %@",NSStringFromSelector([invocation selector]));
    }
    void *null = NULL;
    [invocation setReturnValue:&null];
}

@end
