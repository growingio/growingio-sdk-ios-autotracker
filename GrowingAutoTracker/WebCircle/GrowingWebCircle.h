//
//  GrowingWebCircle.h
//  Growing
//
//  Created by 陈曦 on 15/8/26.
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
#import "GrowingNode.h"
#import "GrowingSRWebSocket.h"

@interface GrowingWebCircle : NSObject

@property (nonatomic, retain) GrowingSRWebSocket *webSocket;
+ (instancetype)shareInstance;

+ (BOOL)isRunning;
+ (void)runWithCircleRoomNumber:(NSString *)circleRoomNumber readyBlock:(void(^)(void))readyBlock finishBlock:(void(^)(void))finishBlock;
+ (void)stop;

+ (void)setNeedUpdateScreen;

// for webview based add-tag-menu
+ (CGFloat)impressScale;
+ (BOOL)isContainer:(id<GrowingNode>)node;
+ (void)retrieveAllElementsAsync:(void(^)(NSString *))callback;

@end
