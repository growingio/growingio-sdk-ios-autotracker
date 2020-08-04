//
//  GrowingBroadcaster.h
//  GrowingTracker
//
//  Created by GrowingIO on 2020/7/6.
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
#import "GrowingMessageProtocol.h"

NS_ASSUME_NONNULL_BEGIN

#define GrowingAnnotationDATA __attribute((used, section("__DATA,GIOBroadcaster")))

// 注册时机在模块加载进Mach-O文件时
#define GrowingBroadcasterRegister(protocolName,cls) \
protocol GrowingMessageProtocol; \
char * kGrowingBroadcaster_##protocolName##cls GrowingAnnotationDATA = "P:"#protocolName":"#cls"";


@interface GrowingBroadcaster : NSObject

+ (instancetype)sharedInstance;

- (void)registerEvent:(Protocol *)type observer:(id <GrowingMessageProtocol>)observer;

- (void)unregisterEvent:(Protocol *)type observer:(id <GrowingMessageProtocol>)observer;

/// Remove all observers which comform to the protocol
- (void)unregisterEvent:(Protocol *)type;

- (void)notifyEvent:(Protocol *)type usingBlock:(void(^)(id <GrowingMessageProtocol> obj))usingBlock;

@end

NS_ASSUME_NONNULL_END
