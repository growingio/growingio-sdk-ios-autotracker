//
//  GrowingEventFMDatabase+Private.h
//  GrowingAnalytics
//
//  Created by YoloMao on 2023/8/7.
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

#import "Services/Database/GrowingEventFMDatabase.h"

NS_ASSUME_NONNULL_BEGIN

@interface GrowingEventFMDatabase (Private)

+ (instancetype)databaseWithPath:(NSString *)path persistenceClass:(Class)cls error:(NSError **)error;
- (BOOL)initDB:(NSString *)sqlInit createIndex:(NSString *)sqlCreateIndex;
- (void)enumerateTableUsingBlock:(void (^)(GrowingFMResultSet *set, BOOL *stop))block;

@end

NS_ASSUME_NONNULL_END
