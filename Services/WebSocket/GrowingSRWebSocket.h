//
//   Copyright 2012 Square Inc.
//
//   Licensed under the Apache License, Version 2.0 (the "License");
//   you may not use this file except in compliance with the License.
//   You may obtain a copy of the License at
//
//       http://www.apache.org/licenses/LICENSE-2.0
//
//   Unless required by applicable law or agreed to in writing, software
//   distributed under the License is distributed on an "AS IS" BASIS,
//   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//   See the License for the specific language governing permissions and
//   limitations under the License.
//

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

@property (nonatomic, weak) id <GrowingSRWebSocketDelegate> delegate;

@property (nonatomic, readonly) GrowingSRReadyState readyState;
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
