//
// GrowingWebSocketService.h
// Pods
//
//  Created by YoloMao on 2021/6/24.
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


#import <Foundation/Foundation.h>
#import "GrowingAnnotationCore.h"

NS_ASSUME_NONNULL_BEGIN

//websocket当前运行状态
typedef NS_ENUM(NSInteger, GrowingWebSocketReadyState) {
    Growing_WS_CONNECTING   = 0, //正在连接
    Growing_WS_OPEN         = 1, //已打开
    Growing_WS_CLOSING      = 2, //正在关闭
    Growing_WS_CLOSED       = 3, //已关闭
};

//websocket当前状态码
//可参考：https://datatracker.ietf.org/doc/html/rfc6455
//可参考：https://github.com/Luka967/websocket-close-codes
typedef NS_ENUM(NSInteger, GrowingWebSocketStatusCode) {
    // 0-999: Reserved and not used.
    GrowingWebSocketStatusCodeNormal = 1000,
    GrowingWebSocketStatusCodeGoingAway = 1001,
    GrowingWebSocketStatusCodeProtocolError = 1002,
    GrowingWebSocketStatusCodeUnhandledType = 1003,
    // 1004 reserved.
    GrowingWebSocketStatusNoStatusReceived = 1005,
    GrowingWebSocketStatusCodeAbnormal = 1006,
    GrowingWebSocketStatusCodeInvalidUTF8 = 1007,
    GrowingWebSocketStatusCodePolicyViolated = 1008,
    GrowingWebSocketStatusCodeMessageTooBig = 1009,
    GrowingWebSocketStatusCodeMissingExtension = 1010,
    GrowingWebSocketStatusCodeInternalError = 1011,
    GrowingWebSocketStatusCodeServiceRestart = 1012,
    GrowingWebSocketStatusCodeTryAgainLater = 1013,
    // 1014: Reserved for future use by the WebSocket standard.
    GrowingWebSocketStatusCodeTLSHandshake = 1015,
    // 1016-1999: Reserved for future use by the WebSocket standard.
    // 2000-2999: Reserved for use by WebSocket extensions.
    // 3000-3999: Available for use by libraries and frameworks. May not be used by applications. Available for registration at the IANA via first-come, first-serve.
    // 4000-4999: Available for use by applications.
};

#pragma mark - GrowingWebSocketDelegate

@protocol GrowingWebSocketDelegate;

#pragma mark - GrowingWebSocketService

@protocol GrowingWebSocketService <NSObject>

@required

/// 回调delegate，需遵循GrowingWebSocketDelegate协议
@property (nonatomic, weak) id <GrowingWebSocketDelegate> delegate;

/// websocket当前运行状态
@property (nonatomic, assign, readonly) GrowingWebSocketReadyState readyState;

/// 当前连接url
@property (nonatomic, strong, readonly) NSURL *url;

/// 初始化websocket
/// @param request NSURLRequest对象
- (instancetype)initWithURLRequest:(NSURLRequest *)request;

/// 启动websocket
- (void)open;

/// 关闭websocket
- (void)close;

/// 发送UTF-8 string或binary data到服务端
/// @param data UTF-8 string或binary data
- (void)send:(id)data;

@end

#pragma mark - GrowingWebSocketDelegate

@protocol GrowingWebSocketDelegate <NSObject>

//need to call these delegate methods in the correct websocket state
//自定义GrowingWebSocketService需在正确的时机调用delegate methods，SDK内部处理

@required

/// websocket收到消息
/// @param webSocket webSocket对象
/// @param message 消息内容
- (void)webSocket:(id <GrowingWebSocketService>)webSocket didReceiveMessage:(id)message;

/// websoket已打开
/// @param webSocket webSocket对象
- (void)webSocketDidOpen:(id <GrowingWebSocketService>)webSocket;

/// websocket发生错误
/// @param webSocket webSocket对象
/// @param error 错误信息
- (void)webSocket:(id <GrowingWebSocketService>)webSocket didFailWithError:(NSError *)error;

/// websocket已关闭
/// @param webSocket webSocket对象
/// @param code 服务端返回的code
/// @param reason 服务端返回的原因（可以为nil）
/// @param wasClean websocket是否在clean状态下关闭
- (void)webSocket:(id <GrowingWebSocketService>)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean;

@end

NS_ASSUME_NONNULL_END
