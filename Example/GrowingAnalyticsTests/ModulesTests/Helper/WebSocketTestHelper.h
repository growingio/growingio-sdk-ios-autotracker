//
//  WebSocketTestHelper.h
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

#import <Foundation/Foundation.h>
#import "GrowingModuleManager.h"
#import "Services/WebSocket/GrowingSRWebSocket.h"

NS_ASSUME_NONNULL_BEGIN

@interface MockWebSocket : NSObject

@property (nonatomic, strong) NSMutableArray<NSString *> *messages;

+ (instancetype)sharedInstance;

- (void)cleanMessages;
- (NSString *)lastMessage;
- (void)addMessage:(NSString *)message;

@end

@interface GrowingModuleManager (XCTest)

@property (nonatomic, strong) NSMutableArray *modules;

@end

NS_ASSUME_NONNULL_END
