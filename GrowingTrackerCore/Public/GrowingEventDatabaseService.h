//
// GrowingEventDatabaseService.h
// GrowingAnalytics
//
//  Created by YoloMao on 2021/7/2.
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
#import "GrowingBaseEvent.h"
#import "GrowingEventPersistenceProtocol.h"

NS_ASSUME_NONNULL_BEGIN

/// 数据库错误码
typedef NS_ENUM(NSInteger, GrowingEventDatabaseError) {
    GrowingEventDatabaseOpenError = 500,  /// 打开数据库错误
    GrowingEventDatabaseWriteError,       /// 数据库写入错误
    GrowingEventDatabaseReadError,        /// 数据库读取错误
    GrowingEventDatabaseCreateDBError,    /// 创建数据库错误
};

extern NSString *const GrowingEventDatabaseErrorDomain;

@protocol GrowingEventDatabaseService <NSObject>

@required

/// 初始化数据库
/// @param path 本地数据库存储路径
/// @param error 若创建数据库错误，则修改此error值
/// @return 事件数据库实例对象
+ (instancetype)databaseWithPath:(NSString *)path error:(NSError **)error;

/// 返回对应的数据持久化Class
+ (Class)persistenceClass;

/// 生成事件数组的二进制数据
/// @param events 事件数据数组
+ (NSData *)buildRawEventsFromEvents:(NSArray<id<GrowingEventPersistenceProtocol>> *)events;

/// 生成事件数组的二进制数据
/// @param jsonObjects 事件数据数组
+ (NSData *)buildRawEventsFromJsonObjects:(NSArray<NSDictionary *> *)jsonObjects;

/// 生成持久化事件对象
/// @param event 事件数据
/// @param uuid 唯一key
+ (id<GrowingEventPersistenceProtocol>)persistenceEventWithEvent:(GrowingBaseEvent *)event uuid:(NSString *)uuid;

/// 获取已存储的事件数量
/// @return 事件数量，大于等于0；若返回值为-1，表示读取错误
- (NSInteger)countOfEvents;

/// 获取事件
/// @param count 数量
/// @param limitSize 大小限制
/// @param mask 允许的发送协议（数组）
/// @return 事件对象数组，可为空；若返回值为nil，表示读取错误
- (nullable NSArray<id<GrowingEventPersistenceProtocol>> *)getEventsByCount:(NSUInteger)count
                                                                  limitSize:(NSUInteger)limitSize
                                                                     policy:(NSUInteger)mask;

/// 写入事件数据
/// @param event 事件数据
/// @return 写入成功/失败；若返回值为NO，表示写入错误
- (BOOL)insertEvent:(id<GrowingEventPersistenceProtocol>)event;

/// 写入事件数据数组
/// @param events 事件数据数组
/// @return 写入成功/失败；若返回值为NO，表示写入错误
- (BOOL)insertEvents:(NSArray<id<GrowingEventPersistenceProtocol>> *)events;

/// 删除事件
/// @param key 事件唯一key
/// @return 写入成功/失败；若返回值为NO，表示写入错误
- (BOOL)deleteEvent:(NSString *)key;

/// 删除事件数组
/// @param keys 事件唯一key数组
/// @return 写入成功/失败；若返回值为NO，表示写入错误
- (BOOL)deleteEvents:(NSArray<NSString *> *)keys;

/// 清空事件
/// @return 写入成功/失败；若返回值为NO，表示写入错误
- (BOOL)clearAllEvents;

/// 清除过期事件
/// @param expirationDays 过期时间，单位 天
/// @return 写入成功/失败；若返回值为NO，表示写入错误
- (BOOL)cleanExpiredEventIfNeeded:(NSUInteger)expirationDays;

/// 获取数据库错误信息
/// @return NSError对象，在上方函数出错时，自行按照如下方式拼接
/// [NSError errorWithDomain:GrowingEventDatabaseErrorDomain
///                     code:GrowingEventDatabaseError
///                 userInfo:@{NSLocalizedDescriptionKey : @"some message"}]
- (NSError *)lastError;

@end

@protocol GrowingPBEventDatabaseService <GrowingEventDatabaseService>

@end

NS_ASSUME_NONNULL_END
