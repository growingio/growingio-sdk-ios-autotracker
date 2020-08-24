//
// GrowingLoggerDebugger.m
// GrowingAnalytics
//
//  Created by GrowingIO on 2020/8/13.
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


#import "GrowingLoggerDebugger.h"
#import "GrowingSRWebSocket.h"
#import "GrowingInstance.h"
#import "GrowingNetworkConfig.h"
#import "NSDictionary+GrowingHelper.h"
#import "NSData+GrowingHelper.h"
#import "GrowingCocoaLumberjack.h"
#import "GrowingTracker.h"
#import "GrowingWSLogger.h"
#import "NSString+GrowingHelper.h"
#import "GrowingDeviceInfo.h"

static NSString * const kWebSocketMsgType = @"msgType";
static NSString * const kLoggerWsEndPoint = @"wss://gta1.growingio.com/app/%@/circle/%@";

@interface GrowingLoggerDebugger ()<GrowingSRWebSocketDelegate>

@property (nonatomic, strong) GrowingSRWebSocket  *webSocket;
@property (nonatomic, copy) NSString *wsKey;
@end

@implementation GrowingLoggerDebugger

static GrowingLoggerDebugger* _loggerDebugger = nil;

+ (void)startLoggerDebuggerWithKey:(NSString *)key {
    
    if ([NSString growingHelper_isBlankString:key]) {
        return;
    }
    if (!_loggerDebugger) {
        _loggerDebugger = [[self alloc] init];
        _loggerDebugger.wsKey = key;
    }
    
    if (!_loggerDebugger.webSocket) {
        NSString* urlStr = [NSString stringWithFormat:kLoggerWsEndPoint, [GrowingInstance sharedInstance].projectID, _loggerDebugger.wsKey];
        _loggerDebugger.webSocket = [[GrowingSRWebSocket alloc] initWithURLRequest: [NSURLRequest requestWithURL: [NSURL URLWithString:urlStr]]];
        _loggerDebugger.webSocket.delegate = _loggerDebugger;
        [_loggerDebugger.webSocket open];
    }
}

+ (void)stopLoggerDebugger {
    
    [_loggerDebugger disconnect];
    [GrowingWSLogger sharedInstance].loggerBlock = nil;
}

- (void)sendData:(id) data {
    
    if (self.webSocket.readyState == Growing_SR_OPEN && ([data isKindOfClass:NSDictionary.class] || [data isKindOfClass:NSArray.class])) {
        NSString *jsonString = [data growingHelper_jsonString];
        [self.webSocket send:jsonString];
    }
}

- (void)sendClientInfo {
    
    NSMutableDictionary *info = [NSMutableDictionary dictionary];
    info[kWebSocketMsgType] = @"client_info";
    info[@"sdkVersion"] = [Growing getVersion];
    
    GrowingDeviceInfo *deviceInfo = [GrowingDeviceInfo currentDeviceInfo];
    CGRect screenRect = [UIScreen mainScreen].bounds;
    NSString    *w    = [NSString stringWithFormat:@"%f", screenRect.size.width];
    NSString    *h    = [NSString stringWithFormat:@"%f", screenRect.size.height];
    NSNumber* stm = GROWGetTimestamp();
    [info setObject:@{@"deviceBrand": deviceInfo.deviceBrand,
                      @"appChannel" : @"App Store",
                      @"screenSize" : @{@"w":w, @"h":h},
                      @"os"         : deviceInfo.systemName,
                      @"osVersion"  : deviceInfo.systemVersion,
                      @"deviceType" : deviceInfo.deviceType,
                      @"deviceModel": deviceInfo.deviceModel,
                      @"appVersion" : deviceInfo.appFullVersion,
                      @"stm" : stm
                      } forKey:@"device"];
    [self sendData:info];
}

- (void)sendReadyMessage {

    NSMutableDictionary *readyDic = [NSMutableDictionary dictionary];
    [readyDic setValue:@"ready" forKey:kWebSocketMsgType];
    [readyDic setValue:[GrowingInstance sharedInstance].projectID forKey:@"projectId"];
    [readyDic setValue:GROWGetTimestamp() forKey:@"timestamp"];
    [readyDic setValue:[Growing getVersion] forKey:@"sdkVersion"];
    [readyDic setValue:[Growing getVersion] forKey:@"sdkVersionCode"];
    [readyDic setValue:@"iOS" forKey:@"os"];
    [self sendData:readyDic];
    
}

- (void)disconnect {
    if (_loggerDebugger.webSocket) {
        [_loggerDebugger.webSocket close];
        _loggerDebugger.webSocket.delegate = nil;
        _loggerDebugger.webSocket = nil;
    }
    _loggerDebugger = nil;
}

#pragma mark - GrowingSRWebSocketDelegate
- (void)webSocket:(GrowingSRWebSocket *)webSocket didReceiveMessage:(id)message {
    if ([[message growingHelper_jsonObject] isKindOfClass:NSDictionary.class]) {
        NSDictionary *msgDic = [message growingHelper_jsonObject];
        NSString *msg = msgDic[kWebSocketMsgType];
        if ([msg isKindOfClass:NSString.class]) {
            if ([msg isEqualToString:@"quit"]) {
                [GrowingLoggerDebugger stopLoggerDebugger];
            } else if ([msg isEqualToString:@"ready"]) {
                [self sendClientInfo];
                [GrowingWSLogger sharedInstance].loggerBlock = ^(NSArray * logMessageArray) {
                    if (logMessageArray.count > 0) {
                        NSMutableDictionary *cacheDic = [NSMutableDictionary dictionary];
                        cacheDic[kWebSocketMsgType] = @"logger_data";
                        cacheDic[@"logs"] = logMessageArray;
                        [self sendData:cacheDic.copy];
                    }
                };
                GIOLogDebug(@"LoggerDebugger ready");
            }
        }
    }
}

- (void)webSocketDidOpen:(GrowingSRWebSocket *)webSocket {
    GIOLogDebug(@"LoggerDebugger did open");
    [self sendReadyMessage];
}

- (void)webSocket:(GrowingSRWebSocket *)webSocket didFailWithError:(NSError *)error {
    GIOLogError(@"error : %@", error);
    [GrowingLoggerDebugger stopLoggerDebugger];
}

- (void)webSocket:(GrowingSRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean {
    
    NSString *message = nil;
    if (code != 1000) {
        message = @"已从服务器断开链接";
    }
    [GrowingLoggerDebugger stopLoggerDebugger];
}

@end
