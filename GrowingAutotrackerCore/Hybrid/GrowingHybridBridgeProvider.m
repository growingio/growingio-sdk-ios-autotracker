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

#import <WebKit/WebKit.h>
#import "GrowingHybridBridgeProvider.h"
#import "NSString+GrowingHelper.h"
#import "GrowingBaseEvent.h"
#import "GrowingWebViewDomChangedDelegate.h"
#import "GrowingPageEvent.h"
#import "GrowingEventManager.h"
#import "GrowingPageAttributesEvent.h"
#import "UIView+GrowingNode.h"
#import "GrowingDeviceInfo.h"

#import "NSDictionary+GrowingHelper.h"
#import "GrowingHybridCustomEvent.h"
#import "GrowingHybirdPageAttributesEvent.h"
#import "GrowingHybirdPageEvent.h"
#import "GrowingHybirdViewElementEvent.h"
#import "GrowingLoginUserAttributesEvent.h"
#import "GrowingVisitorAttributesEvent.h"
#import "GrowingConversionVariableEvent.h"
#import "GrowingHybirdEventType.h"
#import "GrowingTimeUtil.h"
NSString *const kGrowingJavascriptMessageTypeKey = @"messageType";
NSString *const kGrowingJavascriptMessageDataKey = @"data";
NSString *const kGrowingJavascriptMessageType_dispatchEvent = @"dispatchEvent";
NSString *const kGrowingJavascriptMessageType_setNativeUserId = @"setNativeUserId";
NSString *const kGrowingJavascriptMessageType_clearNativeUserId = @"clearNativeUserId";
NSString *const kGrowingJavascriptMessageType_onDomChanged = @"onDomChanged";

#define KEY_EVENT_TYPE  "eventType"
#define KEY_DOMAIN  "domain"
#define KEY_PATH  "path"
#define KEY_PROTOCOL_TYPE  "protocolType"
#define KEY_QUERY  "query"
#define KEY_REFERRAL_PAGE  "referralPage"
#define KEY_TITLE  "title"
#define KEY_TIMESTAMP  "timestamp"
#define KEY_PAGE_SHOW_TIMESTAMP  "pageShowTimestamp"
#define KEY_ATTRIBUTES  "attributes"
#define KEY_VARIABLES  "variables"
#define KEY_EVENT_NAME  "eventName"
#define KEY_HYPERLINK  "hyperlink"
#define KEY_INDEX  "index"
#define KEY_TEXT_VALUE  "textValue"
#define KEY_XPATH  "xpath"

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
    //TODO: 对接事件发送接口
    NSLog(@"handleJavascriptBridgeMessage: %@", message);
    if (message == nil || message.length == 0) {
        return;
    }

    id dict = [message growingHelper_jsonObject];

    if (![dict isKindOfClass:NSDictionary.class]) {
        return;
    }

    NSDictionary *messageDict = (NSDictionary *) dict;

    NSString *messageType = messageDict[kGrowingJavascriptMessageTypeKey];
    NSString *messageData = messageDict[kGrowingJavascriptMessageDataKey];

    if ([kGrowingJavascriptMessageType_dispatchEvent isEqualToString:messageType]) {
        [self parseEventJsonString:messageData];

    } else if ([kGrowingJavascriptMessageType_setNativeUserId isEqualToString:messageType]) {
//        [growing setLoginUserId:messageData];
    } else if ([kGrowingJavascriptMessageType_clearNativeUserId isEqualToString:messageType]) {
//        [Growing cleanLoginUserId];
    } else if ([kGrowingJavascriptMessageType_onDomChanged isEqualToString:messageType]) {
        [self dispatchWebViewDomChanged];
    }
}

- (void)dispatchWebViewDomChanged {
    if (self.domChangedDelegate != nil && [self.domChangedDelegate respondsToSelector:@selector(webViewDomDidChanged)]) {
        [self.domChangedDelegate webViewDomDidChanged];
    }
}

- (void)getDomTreeForWebView:(WKWebView *)webView completionHandler:(void (^ _Nonnull)(NSDictionary *_Nullable domTee, NSError *_Nullable error))completionHandler {
    __block BOOL finished = NO;
    __block NSDictionary *resultDic = nil;
    __block NSError *resultError = nil;
    CGRect rect = webView.growingNodeFrame;
    CGFloat scale = [UIScreen mainScreen].scale;
    scale = MIN(scale, 2);
    int left = (int) (rect.origin.x*scale);
    int top = (int) (rect.origin.y*scale);
    int width = (int) (rect.size.width*scale);
    int height = (int) (rect.size.height*scale);
    NSString *javaScript = [NSString stringWithFormat:@"window.GrowingWebViewJavascriptBridge.getDomTree(%i, %i, %i, %i, 100)", left, top, width, height];
    //方法不会阻塞线程，而且它的回调代码块总是在主线程中运行。
    [webView evaluateJavaScript:javaScript completionHandler:^(id _Nullable result, NSError *error) {
        if ([result isKindOfClass:[NSDictionary class]]) {
//            completionHandler(result, error);
            resultDic = result;
        } else {
//            completionHandler(nil, error);
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

- (void)parseEventJsonString:(NSString *)jsonString {

    if (!jsonString) {
        return;
    }

    id dict = [jsonString growingHelper_jsonObject];

    if (![dict isKindOfClass:NSDictionary.class]) {
        return;
    }

    NSDictionary *evetDataDict = (NSDictionary *) dict;
    NSString *type = evetDataDict[@"eventType"];

    GrowingBaseBuilder *builder = nil;
    if ([type isEqualToString:GrowingEventTypePage]) {
        builder = GrowingHybirdPageEvent.builder
        .setProtocolType(dict[@KEY_PROTOCOL_TYPE])
        .setQuery(dict[@KEY_QUERY])
        .setTitle(dict[@KEY_TITLE])
        .setReferralPage(dict[@KEY_REFERRAL_PAGE])
        .setPageName(dict[@KEY_PATH])
        .setTimestamp([dict longlongForKey:@KEY_TIMESTAMP fallback:[GrowingTimeUtil currentTimeMillis]])
        .setDomain([self getDomain:dict]);
    } else if ([type isEqualToString:GrowingEventTypePageAttributes]) {
        //TODO:检查@KEY_ATTRIBUTES字段是否符合字典类型
        builder = GrowingHybirdPageAttributesEvent.builder
        .setQuery(dict[@KEY_QUERY])
        .setPageName(dict[@KEY_PATH])
        .setPageShowTimestamp([dict longlongForKey:@KEY_PAGE_SHOW_TIMESTAMP fallback:[GrowingTimeUtil currentTimeMillis]])
        .setAttributes(dict[@KEY_ATTRIBUTES])
        .setDomain([self getDomain:dict]);

    } else if ([type isEqualToString:GrowingEventTypeViewClick]) {
        builder = [self transformViewElementBuilder:dict].setEventType(type);
    } else if ([type isEqualToString:GrowingEventTypeViewChange]) {
        builder = [self transformViewElementBuilder:dict].setEventType(type);
    }else if ([type isEqualToString:GrowingEventTypeFormSubmit]) {
        builder = [self transformViewElementBuilder:dict].setEventType(type);
    } else if ([type isEqualToString:GrowingEventTypeCustom]) {
        builder = GrowingHybridCustomEvent.builder
        .setQuery(dict[@KEY_QUERY])
        .setPageName(dict[@KEY_PATH])
        .setPageShowTimestamp([dict longlongForKey:@KEY_PAGE_SHOW_TIMESTAMP fallback:[GrowingTimeUtil currentTimeMillis]])
        .setAttributes(dict[@KEY_ATTRIBUTES])
        .setEventName(dict[@KEY_EVENT_NAME])
        .setDomain([self getDomain:dict]);
    } else if ([type isEqualToString:GrowingEventTypeLoginUserAttributes]) {
        builder = GrowingLoginUserAttributesEvent.builder
        .setAttributes(dict[@KEY_ATTRIBUTES]);
    } else if ([type isEqualToString:GrowingEventTypeConversionVariables]) {
        builder = GrowingConversionVariableEvent.builder
        .setVariables(dict[@KEY_VARIABLES]);
    }

    [[GrowingEventManager shareInstance] postEventBuidler:builder];

}

- (GrowingBaseBuilder *)transformViewElementBuilder:(NSDictionary *)dict {
    return GrowingHybirdViewElementEvent.builder
    .setHyperlink(dict[@KEY_HYPERLINK])
    .setQuery(dict[@KEY_QUERY])
    .setIndex([dict intForKey:@KEY_INDEX fallback:-1])
    .setTextValue(dict[@KEY_TEXT_VALUE])
    .setXpath(dict[@KEY_XPATH])
    .setPageName(dict[@KEY_PATH])
    .setPageShowTimestamp(dict[@KEY_PAGE_SHOW_TIMESTAMP])
    .setDomain([self getDomain:dict]);
}

@end
