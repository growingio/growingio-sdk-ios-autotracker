//
//  GrowingMediator.h
//  GrowingTracker
//
//  Created by GrowingIO on 2018/4/16.
//  Copyright (C) 2018 Beijing Yishu Technology Co., Ltd.
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

@interface GrowingMediator : NSObject

+ (instancetype)sharedInstance;

/**
 * 调用模块类方法
 * @param className   类名称
 * @param actionName  方法名称
 * @param params      方法参数->字典的key为第几个参数,从0开始 比如xx是第0个参数 @{@"0":xx}
 */
- (id)performClass:(NSString *)className action:(NSString *)actionName params:(NSDictionary *)params;

/**
 * 调用模块实例方法
 * @param target      实例
 * @param actionName  方法名称
 * @param params      方法参数->字典的key为第几个参数,从0开始 比如xx是第0个参数 @{@"0":xx}
 */
- (id)performTarget:(NSObject *)target action:(NSString *)actionName params:(NSDictionary *)params;


@end
