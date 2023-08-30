//
//  WebSocketTestHelper.m
//  GrowingAnalytics
//
//  Created by YoloMao on 2023/8/30.
//  Copyright (C) 2023 Beijing Yishu Technology Co., Ltd.
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

#import "WebSocketTestHelper.h"
#import "GrowingTrackerCore/Thread/GrowingDispatchManager.h"

@implementation MockWebSocket

+ (instancetype)sharedInstance {
    static id _sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[self alloc] init];
    });
    return _sharedInstance;
}

- (instancetype)init {
    if (self = [super init]) {
        self.messages = [NSMutableArray arrayWithCapacity:5];
    }
    return self;
}

- (void)cleanMessages {
    [GrowingDispatchManager dispatchInGrowingThread:^{
        [self.messages removeAllObjects];
    }];
}

- (NSString *)lastMessage {
    __block NSString *message = nil;
    [GrowingDispatchManager
        dispatchInGrowingThread:^{
            message = self.messages.lastObject.copy;
        }
                  waitUntilDone:YES];
    return message;
}

- (void)addMessage:(NSString *)message {
    [GrowingDispatchManager dispatchInGrowingThread:^{
        [self.messages addObject:message];
    }];
}

@end

@implementation GrowingSRWebSocket (XCTest)

- (void)send:(id)data {
    [MockWebSocket.sharedInstance addMessage:data];
}

- (void)setDelegate:(id)delegate {
    // 在单测中，使用测试逻辑进行socket
}

- (NSInteger)readyState {
    return Growing_WS_OPEN;
}

@end
