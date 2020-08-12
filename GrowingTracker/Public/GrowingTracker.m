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


#import "GrowingTracker.h"
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
        UIAlertView *view = [[UIAlertView alloc] initWithTitle:@"未检测到GrowingIO的URLScheme"
                                                       message:@"请参考帮助文档 https://help.growingio.com/SDK/iOS.html#urlscheme 进行集成"
                                                      delegate:nil
                                             cancelButtonTitle:@"OK"
                                             otherButtonTitles:nil];
        [view show];
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
}

+ (void)setLocation:(double)latitude longitude:(double)longitude {
    CLLocation *location = [[CLLocation alloc] initWithLatitude:latitude longitude:longitude];
    
    [GrowingInstance sharedInstance].gpsLocation = location;
    [GrowingVisitEvent onGpsLocationChanged:location];
}

+ (void)cleanLocation {
    [GrowingInstance sharedInstance].gpsLocation = nil;
}

+ (void)setUserIdValue:(nonnull NSString *)value {
    NSString * oldValue = [GrowingCustomField shareInstance].userId;
    
    if ([value isKindOfClass:[NSNumber class]]) {
        value = [(NSNumber *)value stringValue];
    }
    
    if (![value isKindOfClass:[NSString class]] || value.length == 0) {
        [GrowingCustomField shareInstance].userId = nil;
    } else {
        [GrowingCustomField shareInstance].userId = value;
    }
    
    NSString *newValue = [GrowingCustomField shareInstance].userId;
    
    [self resetSessionIdWhileUserIdChangedFrom:oldValue toNewValue:newValue];
    
    // Notify userId changed
    [[GrowingBroadcaster sharedInstance] notifyEvent:@protocol(GrowingUserIdChangedMeessage)
                                          usingBlock:^(id<GrowingMessageProtocol>  _Nonnull obj) {
        if ([obj respondsToSelector:@selector(userIdDidChangedFrom:to:)]) {
            id<GrowingUserIdChangedMeessage> message = (id<GrowingUserIdChangedMeessage>)obj;
            [message userIdDidChangedFrom:oldValue to:newValue];
        }
    }];
}

+ (void)resetSessionIdWhileUserIdChangedFrom:(NSString *)oldValue toNewValue:(NSString *)newValue {
    // lastUserId 记录的是上一个有值的 CS1
    static NSString *kGrowinglastUserId = nil;
    
    // 保持 lastUserId 为最近有值的值
    if (oldValue.length > 0) {
        kGrowinglastUserId = oldValue;
    }
    
    // 如果 lastUserId 有值，并且新设置 CS1 也有值，当两个不同的时候，启用新的 Session 并发送 visit
    if (kGrowinglastUserId.length > 0 && newValue.length > 0 && ![kGrowinglastUserId isEqualToString:newValue]) {
        [[GrowingDeviceInfo currentDeviceInfo] resetSessionID];
        [GrowingVisitEvent send];
        
        //重置session, 发 Visitor 事件
        if ([[GrowingCustomField shareInstance] growingVistorVar]) {
            [[GrowingCustomField shareInstance] sendVisitorEvent:[[GrowingCustomField shareInstance] growingVistorVar]];
        }
    }
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
                                          usingBlock:^(id<GrowingTrackerConfigurationMessage>  _Nonnull obj) {
        if ([obj respondsToSelector:@selector(growingTrackerConfigurationDidChanged:)]) {
            id<GrowingTrackerConfigurationMessage> message = (id<GrowingTrackerConfigurationMessage>)obj;
            [message growingTrackerConfigurationDidChanged:configuration];
        }
    }];
}

#pragma mark --

+ (void)setConversionVariables:(NSDictionary<NSString *,NSString *> *)variables {
    
    if (variables == nil || ![variables isKindOfClass:[NSDictionary class]]) {
        GIOLogError(parameterKeyErrorLog);
        return ;
    }
    
    for (NSString *key in variables) {
        if (![key isKindOfClass:NSString.class] || ![key isValidKey]) {
            GIOLogError(parameterValueErrorLog);
            return;
        }
        
        NSString *stringValue = variables[key];
        
        if (![stringValue isKindOfClass:NSString.class]) {
            GIOLogError(parameterValueErrorLog);
            return;;
        }
        
        if (stringValue.length > 1000 || stringValue.length == 0) {
            GIOLogError(parameterValueErrorLog);
            return ;
        }
    }
    
    [GrowingDispatchManager trackApiSel:_cmd dispatchInMainThread:^{
        [[GrowingCustomField shareInstance] sendEvarEvent:variables];
    }];
}

+ (void)setVisitorAttributes:(NSDictionary<NSString *,NSString *> *)attributes {
    
    [GrowingDispatchManager trackApiSel:_cmd dispatchInMainThread:^{
        
        [[GrowingCustomField shareInstance] sendVisitorEvent:attributes];
        //  GrowingBroadcaster 传入 GTouch
        NSDictionary *variable = [GrowingCustomField shareInstance].growingVistorVar?:@{};
        [[GrowingBroadcaster sharedInstance] notifyEvent:@protocol(GrowingManualTrackMessage)
                                              usingBlock:^(id<GrowingMessageProtocol>  _Nonnull obj) {
            
            if ([obj respondsToSelector:@selector(manualEventDidTrackWithUserInfo:manualTrackEventType:)]) {
                id <GrowingManualTrackMessage> message = (id <GrowingManualTrackMessage>)obj;
                [message manualEventDidTrackWithUserInfo:variable manualTrackEventType:GrowingManualTrackVisitorEventType];
            }
        }];
    }];
}

+ (void)setLoginUserAttributes:(NSDictionary<NSString *,NSString *> *)attributes {
    if (![attributes isKindOfClass:[NSDictionary class]]) {
        GIOLogError(parameterValueErrorLog);
        return ;
    }
    
    for (NSString *key in attributes) {
        if (![key isKindOfClass:NSString.class] || ![key isValidKey]) {
            GIOLogError(parameterValueErrorLog);
            return;
        }
        
        NSString *stringValue = attributes[key];
        
        if (![stringValue isKindOfClass:NSString.class]) {
            GIOLogError(parameterValueErrorLog);
            return;;
        }
        
        if (stringValue.length > 1000 || stringValue.length == 0) {
            GIOLogError(parameterValueErrorLog);
            return ;
        }
    }
    
    [GrowingDispatchManager trackApiSel:_cmd dispatchInMainThread:^{
        
         [[GrowingCustomField shareInstance] sendPeopleEvent:attributes];
    }];
}

#pragma mark Track Custom Event

+ (void)trackCustomEvent:(NSString *)eventName {
    if (![eventName isKindOfClass:[NSString class]]) {
        GIOLogError(parameterKeyErrorLog);
        return ;
    }
    if (![eventName isValidKey]) {
        GIOLogError(parameterValueErrorLog);
        return ;
    }
    
    [GrowingDispatchManager trackApiSel:_cmd dispatchInMainThread:^{
        
         [[GrowingCustomField shareInstance] sendCustomTrackEventWithName:eventName andVariable:nil];
        
    }];
    
}

+ (void)trackCustomEvent:(NSString *)eventName withAttributes:(NSDictionary<NSString *,NSString *> *)attributes {
    if (![eventName isKindOfClass:[NSString class]]) {
        GIOLogError(parameterKeyErrorLog);
        return ;
    }
    if (![attributes isKindOfClass:[NSDictionary class]]) {
        GIOLogError(parameterValueErrorLog);
        return ;
    }
    if (attributes.count > 100 ) {
        GIOLogError(parameterValueErrorLog);
        return ;
    }
    if (![eventName isValidKey] || ![attributes isValidDictVariable]) {
        return ;
    }
    
    [GrowingDispatchManager trackApiSel:_cmd dispatchInMainThread:^{
         [[GrowingCustomField shareInstance] sendCustomTrackEventWithName:eventName andVariable:attributes];
    }];
    
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

@end

