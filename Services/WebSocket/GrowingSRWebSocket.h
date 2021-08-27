//  BSD License
//
//  For SocketRocket software
//
//  Copyright (c) 2016-present, Facebook, Inc. All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without modification,
//  are permitted provided that the following conditions are met:
//
//   * Redistributions of source code must retain the above copyright notice, this
//     list of conditions and the following disclaimer.
//
//   * Redistributions in binary form must reproduce the above copyright notice,
//     this list of conditions and the following disclaimer in the documentation
//     and/or other materials provided with the distribution.
//
//   * Neither the name Facebook nor the names of its contributors may be used to
//     endorse or promote products derived from this software without specific
//     prior written permission.
//
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
//  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
//  WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
//  DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR
//  ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
//  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
//  LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
//  ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
//  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
//  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//
//  GrowingSRWebSocket.h
//  GrowingAnalytics
//
//  Created by GrowingIO on 2021/6/28.
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

#import <Foundation/Foundation.h>
#import <Security/SecCertificate.h>
#import "GrowingWebSocketService.h"

typedef NS_ENUM(NSInteger, GrowingSRReadyState) {
    Growing_SR_CONNECTING   = 0,
    Growing_SR_OPEN         = 1,
    Growing_SR_CLOSING      = 2,
    Growing_SR_CLOSED       = 3,
};

typedef enum GrowingSRStatusCode : NSInteger {
    GrowingSRStatusCodeNormal = 1000,
    GrowingSRStatusCodeGoingAway = 1001,
    GrowingSRStatusCodeProtocolError = 1002,
    GrowingSRStatusCodeUnhandledType = 1003,
    // 1004 reserved.
    GrowingSRStatusNoStatusReceived = 1005,
    // 1004-1006 reserved.
    GrowingSRStatusCodeInvalidUTF8 = 1007,
    GrowingSRStatusCodePolicyViolated = 1008,
    GrowingSRStatusCodeMessageTooBig = 1009,
} GrowingSRStatusCode;

@class GrowingSRWebSocket;

extern NSString *const kGrowingSRWebSocketErrorDomain;
extern NSString *const kGrowingSRHTTPResponseErrorKey;

#pragma mark - GrowingSRWebSocketDelegate

@protocol GrowingSRWebSocketDelegate;

#pragma mark - GrowingSRWebSocket

@interface GrowingSRWebSocket : NSObject <GrowingWebSocketService, NSStreamDelegate>

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wincompatible-property-type"
@property (nonatomic, weak) id <GrowingSRWebSocketDelegate> delegate;
@property (nonatomic, readonly) GrowingSRReadyState readyState;
#pragma clang diagnostic pop

@property (nonatomic, readonly, retain) NSURL *url;
// This returns the negotiated protocol.
// It will be nil until after the handshake completes.
@property (nonatomic, readonly, copy) NSString *protocol;

// Protocols should be an array of strings that turn into Sec-WebSocket-Protocol.
- (id)initWithURLRequest:(NSURLRequest *)request protocols:(NSArray *)protocols;
- (id)initWithURLRequest:(NSURLRequest *)request;

// Some helper constructors.
- (id)initWithURL:(NSURL *)url protocols:(NSArray *)protocols;
- (id)initWithURL:(NSURL *)url;

// Delegate queue will be dispatch_main_queue by default.
// You cannot set both OperationQueue and dispatch_queue.
- (void)setDelegateOperationQueue:(NSOperationQueue*) queue;
- (void)setDelegateDispatchQueue:(dispatch_queue_t) queue;

// By default, it will schedule itself on +[NSRunLoop Growing_SR_networkRunLoop] using defaultModes.
- (void)scheduleInRunLoop:(NSRunLoop *)aRunLoop forMode:(NSString *)mode;
- (void)unscheduleFromRunLoop:(NSRunLoop *)aRunLoop forMode:(NSString *)mode;

// GrowingSRWebSockets are intended for one-time-use only.  Open should be called once and only once.
- (void)open;

- (void)close;
- (void)closeWithCode:(NSInteger)code reason:(NSString *)reason;

// Send a UTF8 String or Data.
- (void)send:(id)data;

// Send Data (can be nil) in a ping message.
- (void)sendPing:(NSData *)data;

@end

#pragma mark - GrowingSRWebSocketDelegate

@protocol GrowingSRWebSocketDelegate <NSObject>

// message will either be an NSString if the server is using text
// or NSData if the server is using binary.
- (void)webSocket:(GrowingSRWebSocket *)webSocket didReceiveMessage:(id)message;

@optional

- (void)webSocketDidOpen:(GrowingSRWebSocket *)webSocket;
- (void)webSocket:(GrowingSRWebSocket *)webSocket didFailWithError:(NSError *)error;
- (void)webSocket:(GrowingSRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean;
- (void)webSocket:(GrowingSRWebSocket *)webSocket didReceivePong:(NSData *)pongPayload;

@end

#pragma mark - NSURLRequest (GrowingCertificateAdditions)

@interface NSURLRequest (GrowingCertificateAdditions)

@property (nonatomic, retain, readonly) NSArray *growing_SR_SSLPinnedCertificates;

@end

#pragma mark - NSMutableURLRequest (GrowingCertificateAdditions)

@interface NSMutableURLRequest (GrowingCertificateAdditions)

@property (nonatomic, retain) NSArray *growing_SR_SSLPinnedCertificates;

@end

#pragma mark - NSRunLoop (GrowingSRWebSocket)

@interface NSRunLoop (GrowingSRWebSocket)

+ (NSRunLoop *)growing_SR_networkRunLoop;

@end
