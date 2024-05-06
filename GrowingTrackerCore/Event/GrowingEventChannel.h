//
//  GrowingEventChannel.h
//  GrowingAnalytics
//
//  Created by GrowingIO on 2020/4/14.
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

NS_ASSUME_NONNULL_BEGIN

@interface GrowingEventChannel : NSObject

@property (nonatomic, copy, nullable) NSArray<NSString *> *eventTypes;
@property (nonatomic, assign) BOOL isCustomEvent;
@property (nonatomic, assign) BOOL isUploading;

- (instancetype)initWithTypes:(NSArray<NSString *> *_Nullable)eventTypes
                isCustomEvent:(BOOL)isCustomEvent
                  isUploading:(BOOL)isUploading;

+ (instancetype)eventChannelWithEventTypes:(NSArray<NSString *> *_Nullable)eventTypes isCustomEvent:(BOOL)isCustomEvent;
/// 所有的channels集合
+ (NSMutableArray<GrowingEventChannel *> *)eventChannels;
/// 深拷贝Channels集合，并自动添加一个EventType为nil的Channels
+ (NSArray<GrowingEventChannel *> *)buildAllEventChannels;
/// 根据channels数组，返回 eventType 为key，channel对象为object的字典
+ (NSDictionary *)eventChannelMapFromAllChannels:(NSArray<GrowingEventChannel *> *)channels;

+ (GrowingEventChannel *)otherEventChannelFromAllChannels:(NSArray<GrowingEventChannel *> *)allEventChannels;

@end

NS_ASSUME_NONNULL_END
