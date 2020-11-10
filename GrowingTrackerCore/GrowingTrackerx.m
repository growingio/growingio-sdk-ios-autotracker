//
//  GrowingTracker.m
//  GrowingTracker
//
//  Created by GrowingIO on 2018/5/14.
//  Copyright (C) 2018 Beijing Yishu Technology Co., Ltd.
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


#import "GrowingTrackerx.h"
#import "GrowingAlert.h"
#import "GrowingInstance.h"
#import "GrowingCustomField.h"
#import "GrowingEventManager.h"
#import "GrowingDeviceInfo.h"
#import "GrowingGlobal.h"
#import "GrowingDispatchManager.h"
#import "GrowingMediator+GrowingDeepLink.h"
#import "NSString+GrowingHelper.h"
#import "NSDictionary+GrowingHelper.h"
#import "GrowingCocoaLumberjack.h"
#import "GrowingConfiguration.h"
#import "GrowingBroadcaster.h"
#import "GrowingWSLoggerFormat.h"


@import CoreLocation;

static NSString* const kGrowingVersion = @"3.0.0";

@implementation Growing

+ (NSString*)getVersion {
    return kGrowingVersion;
}

+ (BOOL)handleURL:(NSURL *)url {
    
    return [[GrowingMediator sharedInstance] performActionWithUrl:url];
}

+ (void)startWithConfiguration:(GrowingConfiguration *)configuration {
    
    [self loggerSetting:configuration.logEnabled];
    
    if (![NSThread isMainThread]) {
        GIOLogError(@"请在applicationDidFinishLaunching中调用startWithAccountId函数,并且确保在主线程中");
    }
    
    if (!configuration.projectId.length) {
        GIOLogError(@"GrowingIO启动失败:ProjectId不能为空");
        return;
    }
    
    BOOL urlSchemeRight = [self urlSchemeCheck];
    
    if (urlSchemeRight) {
        GIOLogError(@"!!! Thank you very much for using GrowingIO. We will do our best to provide you with the best service. !!!");
        GIOLogError(@"!!! GrowingIO version: %@ !!!", [Growing getVersion]);
        [GrowingInstance startWithConfiguration:configuration];
    }
    
    // Notify GrowingInstance Did Start.
    [self notifyTrackerConfigurationDidChange:configuration];
    
    //  默认启动sdk crash 收集
    [self setUploadExceptionEnable:configuration.uploadExceptionEnable];
}

+ (BOOL)urlSchemeCheck {
    if ([GrowingDeviceInfo currentDeviceInfo].urlScheme.length == 0) {
        GrowingAlert *alert = [GrowingAlert createAlertWithStyle:UIAlertControllerStyleAlert
                                                           title:@"未检测到GrowingIO的URLScheme"
                                                         message:@"请参考帮助文档 https://help.growingio.com/SDK/iOS.html#urlscheme 进行集成"];
        [alert addOkWithTitle:@"OK" handler:nil];
        [alert showAlertAnimated:YES];
        GIOLogError(@"未检测到GrowingIO的URLScheme !!!");
        GIOLogInfo (@"请参考帮助文档 https://help.growingio.com/SDK/iOS.html#urlscheme 进行集成");
        return NO;
    } else {
        return YES;
    }
}

+ (void)loggerSetting:(BOOL)enableLog {
    
    if (enableLog) {
        [GrowingLog addLogger:[GrowingTTYLogger sharedInstance] withLevel:GrowingLogLevelDebug];
    } else {
        [GrowingLog removeLogger:[GrowingTTYLogger sharedInstance]];
        [GrowingLog addLogger:[GrowingTTYLogger sharedInstance] withLevel:GrowingLogLevelError];
    }
    
    [GrowingLog addLogger:[GrowingWSLogger sharedInstance] withLevel:GrowingLogLevelVerbose];
    [GrowingWSLogger sharedInstance].logFormatter = [GrowingWSLoggerFormat new];
}

+ (void)setLocation:(double)latitude longitude:(double)longitude {
    CLLocation *location = [[CLLocation alloc] initWithLatitude:latitude longitude:longitude];
    
    [GrowingInstance sharedInstance].gpsLocation = location;
    [GrowingVisitEvent onGpsLocationChanged:location];
}

+ (void)cleanLocation {
    [GrowingInstance sharedInstance].gpsLocation = nil;
}


+ (void)setDataTrackEnabled:(BOOL)enabled {
    g_GDPRFlag = !enabled;
}

+ (void)setDataUploadEnabled:(BOOL)enabled {
    g_DataUploadFlag = enabled;
}

+ (NSString *)getDeviceId {
    return [GrowingDeviceInfo currentDeviceInfo].deviceIDString;
}

+ (NSString *)getSessionId {
    return [GrowingDeviceInfo currentDeviceInfo].sessionID;
}

// 埋点相关
+ (void)setLoginUserId:(NSString *)userId {
    
    if (userId.length == 0 || userId.length > 1000) {
        return;
    }

    [GrowingDispatchManager trackApiSel:_cmd dispatchInMainThread:^{
        [self setUserIdValue:userId];
    }];
}

+ (void)cleanLoginUserId {
    [GrowingDispatchManager trackApiSel:_cmd dispatchInMainThread:^{
        [self setUserIdValue:@""];
    }];
}

+ (void)notifyTrackerConfigurationDidChange:(GrowingConfiguration *)configuration {
    [[GrowingBroadcaster sharedInstance] notifyEvent:@protocol(GrowingTrackerConfigurationMessage)
                                          usingBlock:^(id<GrowingMessageProtocol>  _Nonnull obj) {
        if ([obj respondsToSelector:@selector(growingTrackerConfigurationDidChanged:)]) {
            id<GrowingTrackerConfigurationMessage> message = (id<GrowingTrackerConfigurationMessage>)obj;
            [message growingTrackerConfigurationDidChanged:configuration];
        }
    }];
}

#pragma mark --

+ (void)setConversionVariables:(NSDictionary<NSString *,NSString *> *)variables {
    

}

+ (void)setVisitorAttributes:(NSDictionary<NSString *,NSString *> *)attributes {

}

+ (void)setLoginUserAttributes:(NSDictionary<NSString *,NSString *> *)attributes {

}

#pragma mark Track Custom Event

+ (void)trackCustomEvent:(NSString *)eventName {

    
}

+ (void)trackCustomEvent:(NSString *)eventName withAttributes:(NSDictionary<NSString *,NSString *> *)attributes {

    
}

+ (void)setUploadExceptionEnable:(BOOL)uploadExceptionEnable {
    GrowingMonitorState state = uploadExceptionEnable ? GrowingMonitorStateUploadExceptionEnable : GrowingMonitorStateUploadExceptionDisable;
    [self sendGrowingEBMonitorEventState:state];
}

+ (void)sendGrowingEBMonitorEventState:(GrowingMonitorState)state {
        
    NSDictionary *dataDict = @{@"v": [NSString stringWithFormat:@"GrowingTracker-%@", [self getVersion]],
                               @"u": [GrowingDeviceInfo currentDeviceInfo].deviceIDString ?: @"",
                               @"ai": [GrowingInstance sharedInstance].projectID ?: @"",
    };
    
    [[GrowingBroadcaster sharedInstance] notifyEvent:@protocol(GrowingMonitorMeessage)
                                          usingBlock:^(id<GrowingMessageProtocol>  _Nonnull obj) {
        if ([obj respondsToSelector:@selector(monitorStateDidSettingWithState:userInfo:)]) {
            id<GrowingMonitorMeessage> message = (id<GrowingMonitorMeessage>)obj;
            [message monitorStateDidSettingWithState:state userInfo:dataDict];
        }
    }];
}

+ (instancetype)sharedInstance {
    static id _sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[self alloc] init];
    });

    return _sharedInstance;
}

@end

