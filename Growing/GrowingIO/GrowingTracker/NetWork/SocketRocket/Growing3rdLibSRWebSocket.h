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

typedef NS_ENUM(NSInteger, Growing3rdLibSRReadyState) {
    Growing3rdLib_SR_CONNECTING   = 0,
    Growing3rdLib_SR_OPEN         = 1,
    Growing3rdLib_SR_CLOSING      = 2,
    Growing3rdLib_SR_CLOSED       = 3,
};

typedef enum Growing3rdLibSRStatusCode : NSInteger {
    Growing3rdLibSRStatusCodeNormal = 1000,
    Growing3rdLibSRStatusCodeGoingAway = 1001,
    Growing3rdLibSRStatusCodeProtocolError = 1002,
    Growing3rdLibSRStatusCodeUnhandledType = 1003,
    // 1004 reserved.
    SRStatusNoStatusReceived = 1005,
    // 1004-1006 reserved.
    Growing3rdLibSRStatusCodeInvalidUTF8 = 1007,
    Growing3rdLibSRStatusCodePolicyViolated = 1008,
    Growing3rdLibSRStatusCodeMessageTooBig = 1009,
} Growing3rdLibSRStatusCode;

@class Growing3rdLibSRWebSocket;

extern NSString *const kGrowing3rdLibSRWebSocketErrorDomain;
extern NSString *const kGrowing3rdLibSRHTTPResponseErrorKey;

#pragma mark - Growing3rdLibSRWebSocketDelegate

@protocol Growing3rdLibSRWebSocketDelegate;

#pragma mark - Growing3rdLibSRWebSocket

@interface Growing3rdLibSRWebSocket : NSObject <NSStreamDelegate>

@property (nonatomic, weak) id <Growing3rdLibSRWebSocketDelegate> delegate;

@property (nonatomic, readonly) Growing3rdLibSRReadyState readyState;
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

// By default, it will schedule itself on +[NSRunLoop Growing3rdLib_SR_networkRunLoop] using defaultModes.
- (void)scheduleInRunLoop:(NSRunLoop *)aRunLoop forMode:(NSString *)mode;
- (void)unscheduleFromRunLoop:(NSRunLoop *)aRunLoop forMode:(NSString *)mode;

// Growing3rdLibSRWebSockets are intended for one-time-use only.  Open should be called once and only once.
- (void)open;

- (void)close;
- (void)closeWithCode:(NSInteger)code reason:(NSString *)reason;

// Send a UTF8 String or Data.
- (void)send:(id)data;

// Send Data (can be nil) in a ping message.
- (void)sendPing:(NSData *)data;

@end

#pragma mark - Growing3rdLibSRWebSocketDelegate

@protocol Growing3rdLibSRWebSocketDelegate <NSObject>

// message will either be an NSString if the server is using text
// or NSData if the server is using binary.
- (void)webSocket:(Growing3rdLibSRWebSocket *)webSocket didReceiveMessage:(id)message;

@optional

- (void)webSocketDidOpen:(Growing3rdLibSRWebSocket *)webSocket;
- (void)webSocket:(Growing3rdLibSRWebSocket *)webSocket didFailWithError:(NSError *)error;
- (void)webSocket:(Growing3rdLibSRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean;
- (void)webSocket:(Growing3rdLibSRWebSocket *)webSocket didReceivePong:(NSData *)pongPayload;

@end

#pragma mark - NSURLRequest (Growing3rdLibCertificateAdditions)

@interface NSURLRequest (Growing3rdLibCertificateAdditions)

@property (nonatomic, retain, readonly) NSArray *growing3rdLib_SR_SSLPinnedCertificates;

@end

#pragma mark - NSMutableURLRequest (Growing3rdLibCertificateAdditions)

@interface NSMutableURLRequest (Growing3rdLibCertificateAdditions)

@property (nonatomic, retain) NSArray *growing3rdLib_SR_SSLPinnedCertificates;

@end

#pragma mark - NSRunLoop (Growing3rdLibSRWebSocket)

@interface NSRunLoop (Growing3rdLibSRWebSocket)

+ (NSRunLoop *)growing3rdLib_SR_networkRunLoop;

@end
