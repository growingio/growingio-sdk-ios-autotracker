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
#import "GrowingTracker.h"
#import "NSString+GrowingHelper.h"
#import "GrowingEvent.h"
#import "GrowingWebViewDomChangedDelegate.h"
#import "GrowingPageEvent.h"
#import "GrowingEventManager.h"
#import "GrowingPvarEvent.h"
#import "GrowingActionEvent.h"
#import "GrowingClickEvent.h"
#import "GrowingManualTrackEvent.h"
#import "UIView+GrowingNode.h"

NSString *const kGrowingJavascriptMessageTypeKey = @"messageType";
NSString *const kGrowingJavascriptMessageDataKey = @"data";
NSString *const kGrowingJavascriptMessageType_dispatchEvent = @"dispatchEvent";
NSString *const kGrowingJavascriptMessageType_setNativeUserId = @"setNativeUserId";
NSString *const kGrowingJavascriptMessageType_clearNativeUserId = @"clearNativeUserId";
NSString *const kGrowingJavascriptMessageType_onDomChanged = @"onDomChanged";

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
        [Growing setLoginUserId:messageData];
    } else if ([kGrowingJavascriptMessageType_clearNativeUserId isEqualToString:messageType]) {
        [Growing cleanLoginUserId];
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

    GrowingEvent *event = nil;
    if ([type isEqualToString:kEventTypeKeyPage]) {
        event = [GrowingPageEvent hybridPageEventWithDataDict:evetDataDict];

    } else if ([type isEqualToString:kEventTypeKeyPageAttributes]) {
        event = [GrowingPvarEvent hybridPvarEventWithDataDict:evetDataDict];

    } else if ([type isEqualToString:kEventTypeKeyViewClick]) {
        event = [GrowingClickEvent hybridActionEventWithDataDict:evetDataDict];

    } else if ([type isEqualToString:kEventTypeKeyInputSubmit]) {
        event = [GrowingSubmitEvent hybridActionEventWithDataDict:evetDataDict];

    } else if ([type isEqualToString:kEventTypeKeyViewChange]) {
        event = [GrowingTextEditContentChangeEvent hybridActionEventWithDataDict:evetDataDict];

    } else if ([type isEqualToString:kEventTypeKeyCustom]) {
        event = [GrowingCustomTrackEvent hybridCustomEventWithDataDict:evetDataDict];

    } else if ([type isEqualToString:kEventTypeKeyLoginUserAttributes]) {
        event = [GrowingPeopleVarEvent hybridPeopleVarEventWithDataDict:evetDataDict];

    } else if ([type isEqualToString:kEventTypeKeyVisitor]) {
        event = [GrowingVisitorEvent hybridVisitorEventWithDataDict:evetDataDict];

    } else if ([type isEqualToString:kEventTypeKeyConversionVariable]) {
        event = [GrowingEvarEvent hybridEvarEventWithDataDict:evetDataDict];
    }

    [[GrowingEventManager shareInstance] addEvent:event
                                         thisNode:nil
                                      triggerNode:nil
                                      withContext:nil];

}

@end
