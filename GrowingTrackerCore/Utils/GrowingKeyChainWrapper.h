//
// GrowingKeyChainWrapper.h
// GrowingAnalytics
//
//  Created by sheng on 2021/4/21.
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

NS_ASSUME_NONNULL_BEGIN

@interface GrowingKeyChainWrapper : NSObject

/**
 往KeyChain中根据key存储一个object
 @param service 对应的key值
 @param value 存储的对象
 */
+ (void)setKeychainObject:(id)value forKey:(NSString *)service;

/**
 获取KeyChain中对应key的对象
 @param key 对应的key值
 @return 存储的对象
 */
+ (id)keyChainObjectForKey:(NSString *)key;

@end

NS_ASSUME_NONNULL_END
