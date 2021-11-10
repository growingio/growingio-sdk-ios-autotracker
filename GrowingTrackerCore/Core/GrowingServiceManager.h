//
// GrowingServiceManager.h
// GrowingAnalytics
//
//  Created by sheng on 2021/6/8.
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

@interface GrowingServiceManager : NSObject
@property (nonatomic, assign) BOOL enableException;
@property (nonatomic, copy, readonly) NSMutableDictionary *allServiceDict;
@property (nonatomic, copy, readonly) NSMutableDictionary *allServiceInstanceDict;

+ (instancetype)sharedInstance;

- (void)registerServiceName:(NSString *)serviceName implClassName:(NSString *)serviceClassName;

- (void)registerService:(Protocol*)service implClass:(Class)serviceClass;

- (id)createService:(Protocol*)service;

- (id)serviceImplClass:(Protocol *)service;

- (id)getServiceInstanceForServiceName:(NSString *)serviceName;

- (void)removeServiceInstanceForServiceName:(NSString *)serviceName;

@end

NS_ASSUME_NONNULL_END
