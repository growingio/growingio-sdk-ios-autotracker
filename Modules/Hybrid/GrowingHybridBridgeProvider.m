//
// GrowingHybridBridgeProvider.m
// GrowingAnalytics
//
//  Created by GrowingIO on 2020/5/27.
//  Copyright (C) 2020 Beijing Yishu Technology Co., Ltd.
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

#import "Modules/Hybrid/GrowingHybridBridgeProvider.h"
#import <WebKit/WebKit.h>
#import "GrowingTrackerCore/Event/Autotrack/GrowingPageEvent.h"
#import "GrowingTrackerCore/Event/GrowingEventManager.h"
#import "GrowingTrackerCore/Event/GrowingLoginUserAttributesEvent.h"
#import "GrowingTrackerCore/Helpers/GrowingHelpers.h"
#import "GrowingTrackerCore/Manager/GrowingSession.h"
#import "GrowingTrackerCore/Public/GrowingAnnotationCore.h"
#import "GrowingTrackerCore/Public/GrowingBaseEvent.h"
#import "GrowingTrackerCore/Thirdparty/Logger/GrowingLogger.h"
#import "GrowingTrackerCore/Thread/GrowingDispatchManager.h"
#import "GrowingTrackerCore/Utils/GrowingDeviceInfo.h"
#import "GrowingULTimeUtil.h"
#import "Modules/Hybrid/Events/GrowingHybridCustomEvent.h"
#import "Modules/Hybrid/Events/GrowingHybridEventType.h"
#import "Modules/Hybrid/Events/GrowingHybridPageEvent.h"
#import "Modules/Hybrid/Events/GrowingHybridViewElementEvent.h"
#import "Modules/Hybrid/GrowingWebViewDomChangedDelegate.h"

NSString *const kGrowingJavascriptMessageTypeKey = @"messageType";
NSString *const kGrowingJavascriptMessageDataKey = @"data";
NSString *const kGrowingJavascriptMessageType_dispatchEvent = @"dispatchEvent";
NSString *const kGrowingJavascriptMessageType_setNativeUserId = @"setNativeUserId";
NSString *const kGrowingJavascriptMessageType_clearNativeUserId = @"clearNativeUserId";
NSString *const kGrowingJavascriptMessageType_setNativeUserIdAndUserKey = @"setNativeUserIdAndUserKey";
NSString *const kGrowingJavascriptMessageType_clearNativeUserIdAndUserKey = @"clearNativeUserIdAndUserKey";
NSString *const kGrowingJavascriptMessageType_onDomChanged = @"onDomChanged";
NSString *const kGrowingJavascriptMessageType_getNativeIdentity = @"getNativeIdentity";

#define KEY_EVENT_TYPE "eventType"
#define KEY_DOMAIN "domain"
#define KEY_PATH "path"
#define KEY_PROTOCOL_TYPE "protocolType"
#define KEY_QUERY "query"
#define KEY_REFERRAL_PAGE "referralPage"
#define KEY_TITLE "title"
#define KEY_TIMESTAMP "timestamp"
#define KEY_ATTRIBUTES "attributes"
#define KEY_VARIABLES "variables"
#define KEY_EVENT_NAME "eventName"
#define KEY_HYPERLINK "hyperlink"
#define KEY_INDEX "index"
#define KEY_TEXT_VALUE "textValue"
#define KEY_XPATH "xpath"
#define KEY_XCONTENT "xcontent"

@interface UIView (GrowingNode) <GrowingNode>
@end

@implementation GrowingHybridBridgeProvider
+ (instancetype)sharedInstance {
    static id _sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[self alloc] init];
    });

    return _sharedInstance;
}

- (void)handleJavascriptBridgeMessage:(NSString *)message {
    [self handleJavascriptBridgeMessage:message fromWebView:nil frameInfo:nil];
}

- (void)handleJavascriptBridgeMessage:(NSString *)message
                          fromWebView:(WKWebView *)webView
                            frameInfo:(WKFrameInfo *)frameInfo {
    GIOLogDebug(@"handleJavascriptBridgeMessage: %@", message);
    if (message == nil || message.length == 0) {
        return;
    }

    id dict = [message growingHelper_jsonObject];

    if (![dict isKindOfClass:NSDictionary.class]) {
        return;
    }

    NSDictionary *messageDict = (NSDictionary *)dict;

    NSString *messageType = messageDict[kGrowingJavascriptMessageTypeKey];
    NSString *messageData = messageDict[kGrowingJavascriptMessageDataKey];

    if ([kGrowingJavascriptMessageType_dispatchEvent isEqualToString:messageType]) {
        [self parseEventJsonString:messageData];
    } else if ([kGrowingJavascriptMessageType_setNativeUserId isEqualToString:messageType]) {
        messageData = [self safeConvertToString:messageData];
        [[GrowingSession currentSession] setLoginUserId:messageData];
    } else if ([kGrowingJavascriptMessageType_clearNativeUserId isEqualToString:messageType]) {
        [[GrowingSession currentSession] setLoginUserId:nil];
    } else if ([kGrowingJavascriptMessageType_setNativeUserIdAndUserKey isEqualToString:messageType]) {
        if (!messageData) {
            return;
        }
        id dict = [messageData growingHelper_jsonObject];
        NSDictionary *eventDataDict = (NSDictionary *)dict;
        NSString *userId = [self safeConvertToString:eventDataDict[@"userId"]];
        NSString *userKey = [self safeConvertToString:eventDataDict[@"userKey"]];
        [[GrowingSession currentSession] setLoginUserId:userId userKey:userKey];
    } else if ([kGrowingJavascriptMessageType_clearNativeUserIdAndUserKey isEqualToString:messageType]) {
        [[GrowingSession currentSession] setLoginUserId:nil];
    } else if ([kGrowingJavascriptMessageType_onDomChanged isEqualToString:messageType]) {
        [self dispatchWebViewDomChanged];
    } else if ([kGrowingJavascriptMessageType_getNativeIdentity isEqualToString:messageType]) {
        [self handleGetNativeIdentity:messageData webView:webView frameInfo:frameInfo];
    }
}

#pragma mark - Native Identity

- (void)handleGetNativeIdentity:(NSString *)messageData
                        webView:(WKWebView *)webView
                      frameInfo:(WKFrameInfo *)frameInfo {
    if (!webView) {
        // WKScriptMessage.webView 为 weak 属性，页面已销毁时为 nil，由 JS 侧超时兜底
        return;
    }
    if (!messageData) {
        return;
    }

    id dict = [messageData growingHelper_jsonObject];
    if (![dict isKindOfClass:NSDictionary.class]) {
        return;
    }
    NSString *callbackId = [self safeConvertToString:((NSDictionary *)dict)[@"callbackId"]];
    if (![self isValidCallbackId:callbackId]) {
        GIOLogWarn(@"getNativeIdentity: invalid callbackId");
        return;
    }

    GrowingSession *session = [GrowingSession currentSession];
    GrowingDeviceInfo *deviceInfo = [GrowingDeviceInfo currentDeviceInfo];

    NSMutableDictionary *identity = [NSMutableDictionary dictionary];
    identity[@"deviceId"] = deviceInfo.deviceIDString ?: @"";
    if (session.loginUserId.length > 0) {
        identity[@"userId"] = session.loginUserId;
    }
    // idMappingEnabled 关闭时 GrowingSession 已将 loginUserKey 置空，此处无需再判断开关
    if (session.loginUserKey.length > 0) {
        identity[@"userKey"] = session.loginUserKey;
    }
    identity[@"isNewDevice"] = @(deviceInfo.isNewDeviceInFirstSession);

    NSString *json = [identity growingHelper_jsonString];
    if (json.length == 0) {
        return;
    }

    NSString *javaScript = [NSString
        stringWithFormat:@"window.GrowingWebViewJavascriptBridge._onNativeCallback('%@', %@);", callbackId, json];
    [self evaluateJavaScript:javaScript webView:webView frameInfo:frameInfo];
}

// callbackId 由页面 JS 传入并拼接进 evaluateJavaScript，做白名单校验避免注入
- (BOOL)isValidCallbackId:(NSString *)callbackId {
    if (callbackId.length == 0 || callbackId.length > 64) {
        return NO;
    }
    static NSCharacterSet *invalidSet = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSCharacterSet *validSet = [NSCharacterSet characterSetWithCharactersInString:
                                                       @"abcdefghijklmnopqrstuvwxyz"
                                                       @"ABCDEFGHIJKLMNOPQRSTUVWXYZ"
                                                       @"0123456789_-"];
        invalidSet = validSet.invertedSet;
    });
    return [callbackId rangeOfCharacterFromSet:invalidSet].location == NSNotFound;
}

- (void)evaluateJavaScript:(NSString *)javaScript webView:(WKWebView *)webView frameInfo:(WKFrameInfo *)frameInfo {
    [GrowingDispatchManager dispatchInMainThread:^{
#if defined(__IPHONE_14_0) && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_14_0
        if (@available(iOS 14.0, *)) {
            // 将回调定向回消息来源的 frame，iframe 内发起的调用同样可以收到；
            // contentWorld 必须显式指定 pageWorld，否则脚本运行在 defaultClientWorld，
            // 其中不存在注入的 shim
            [webView evaluateJavaScript:javaScript
                                inFrame:frameInfo
                         inContentWorld:WKContentWorld.pageWorld
                      completionHandler:nil];
            return;
        }
#endif
        // iOS 14.0 以下 evaluateJavaScript: 只能作用于主 frame，
        // iframe 内发起的调用无法回调，由 JS 侧超时兜底
        if (frameInfo && !frameInfo.isMainFrame) {
            GIOLogWarn(@"getNativeIdentity from iframe requires iOS 14.0+");
            return;
        }
        [webView evaluateJavaScript:javaScript completionHandler:nil];
    }];
}

- (void)dispatchWebViewDomChanged {
    if (self.domChangedDelegate != nil &&
        [self.domChangedDelegate respondsToSelector:@selector(webViewDomDidChanged)]) {
        [self.domChangedDelegate webViewDomDidChanged];
    }
}

- (void)getDomTreeForWebView:(WKWebView *)webView
           completionHandler:
               (void (^_Nonnull)(NSDictionary *_Nullable domTee, NSError *_Nullable error))completionHandler {
    __block BOOL finished = NO;
    __block NSDictionary *resultDic = nil;
    __block NSError *resultError = nil;
    CGRect rect = webView.growingNodeFrame;
    CGFloat scale = [UIScreen mainScreen].scale;
    scale = MIN(scale, 2);
    int left = (int)(rect.origin.x * scale);
    int top = (int)(rect.origin.y * scale);
    int width = (int)(rect.size.width * scale);
    int height = (int)(rect.size.height * scale);
    NSString *javaScript =
        [NSString stringWithFormat:@"window.GrowingWebViewJavascriptBridge.getDomTree(%i, %i, %i, %i, 100)",
                                   left,
                                   top,
                                   width,
                                   height];
    // 方法不会阻塞线程，而且它的回调代码块总是在主线程中运行。
    [webView evaluateJavaScript:javaScript
              completionHandler:^(id _Nullable result, NSError *error) {
                  if ([result isKindOfClass:[NSDictionary class]]) {
                      resultDic = result;
                  } else {
                      resultError = error;
                  }
                  finished = YES;
              }];
    while (!finished) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }

    completionHandler(resultDic, resultError);
}

- (NSString *)getDomain:(NSDictionary *)dict {
    NSString *domain = [dict objectForKey:@KEY_DOMAIN];
    if (!domain) {
        domain = [GrowingDeviceInfo currentDeviceInfo].bundleID;
    }
    return domain;
}

- (NSDictionary *)safeAttributesFromDict:(NSDictionary *)dict {
    NSDictionary *attributes = dict[@KEY_ATTRIBUTES];
    if (!attributes || attributes.count == 0) {
        return nil;
    }
    NSMutableDictionary *safeAttributes = [NSMutableDictionary dictionary];
    for (NSString *key in attributes.allKeys) {
        id value = [self safeConvertToString:attributes[key]];
        if (value) {
            [safeAttributes setObject:value forKey:key];
        }
    }
    return safeAttributes;
}

- (NSString *)safeConvertToString:(id)value {
    if ([value isKindOfClass:[NSString class]]) {
        return (NSString *)value;
    }
    if ([value isKindOfClass:[NSNumber class]]) {
        return [(NSNumber *)value stringValue];
    }
    return nil;
}

- (void)parseEventJsonString:(NSString *)jsonString {
    if (!jsonString) {
        return;
    }

    id dict = [jsonString growingHelper_jsonObject];

    if (![dict isKindOfClass:NSDictionary.class]) {
        return;
    }

    NSDictionary *eventDataDict = (NSDictionary *)dict;
    NSString *type = eventDataDict[@"eventType"];

    [GrowingDispatchManager dispatchInGrowingThread:^{
        GrowingBaseBuilder *builder = nil;
        if ([type isEqualToString:GrowingEventTypePage]) {
            builder = GrowingHybridPageEvent.builder.setProtocolType(dict[@KEY_PROTOCOL_TYPE])
                          .setQuery(dict[@KEY_QUERY])
                          .setTitle(dict[@KEY_TITLE])
                          .setReferralPage(dict[@KEY_REFERRAL_PAGE])
                          .setPath(dict[@KEY_PATH])
                          .setTimestamp([dict growingHelper_longlongForKey:@KEY_TIMESTAMP
                                                                  fallback:[GrowingULTimeUtil currentTimeMillis]])
                          .setAttributes([self safeAttributesFromDict:dict])
                          .setDomain([self getDomain:dict]);
        } else if ([type isEqualToString:GrowingEventTypeViewClick]) {
            builder = [self transformViewElementBuilder:dict].setEventType(type);
        } else if ([type isEqualToString:GrowingEventTypeViewChange]) {
            builder = [self transformViewElementBuilder:dict].setEventType(type);
        } else if ([type isEqualToString:GrowingEventTypeFormSubmit]) {
            builder = [self transformViewElementBuilder:dict].setEventType(type);
        } else if ([type isEqualToString:GrowingEventTypeCustom]) {
            NSDictionary *mergedDic = [self safeAttributesFromDict:dict].copy;
            builder = GrowingHybridCustomEvent.builder.setQuery(dict[@KEY_QUERY])
                          .setPath(dict[@KEY_PATH])
                          .setAttributes(mergedDic)
                          .setEventName(dict[@KEY_EVENT_NAME])
                          .setDomain([self getDomain:dict]);
        } else if ([type isEqualToString:GrowingEventTypeLoginUserAttributes]) {
            builder = GrowingLoginUserAttributesEvent.builder.setAttributes([self safeAttributesFromDict:dict]);
        }
        if (builder) {
            builder = builder.setScene(GrowingEventSceneHybrid);
            [[GrowingEventManager sharedInstance] postEventBuilder:builder];
        }
    }];
}

- (GrowingBaseBuilder *)transformViewElementBuilder:(NSDictionary *)dict {
    return GrowingHybridViewElementEvent.builder.setHyperlink(dict[@KEY_HYPERLINK])
        .setQuery(dict[@KEY_QUERY])
        .setIndex([dict growingHelper_intForKey:@KEY_INDEX fallback:-1])
        .setTextValue(dict[@KEY_TEXT_VALUE])
        .setXpath(dict[@KEY_XPATH])
        .setXcontent(dict[@KEY_XCONTENT])
        .setPath(dict[@KEY_PATH])
        .setDomain([self getDomain:dict])
        .setAttributes([self safeAttributesFromDict:dict]);
}

@end
