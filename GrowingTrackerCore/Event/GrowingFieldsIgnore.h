//
// GrowingFieldsIgnore.h
// GrowingAnalytics
//
//  Created by rq on 2021/7/14.
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

typedef NS_OPTIONS(NSUInteger, GrowingIgnoreFields) {
    
    GrowingIgnoreFieldsNetworkState     = (1 << 0),
    GrowingIgnoreFieldsScreenWidth      = (1 << 1),
    GrowingIgnoreFieldsScreenHeight     = (1 << 2),
    GrowingIgnoreFieldsDeviceBrand      = (1 << 3),
    GrowingIgnoreFieldsDeviceModel      = (1 << 4),
    GrowingIgnoreFieldsDeviceType       = (1 << 5),
};

//忽略当前所有可设置的属性掩码值
extern NSUInteger const GrowingIgnoreFieldsAll;

@interface GrowingFieldsIgnore : NSObject

+ (NSArray*)ignoreFieldsItems;

// 通过字段名称获取其对应的掩码值
+ (NSUInteger)getIgnoreFieldsMask:(NSString *)typeName;

+ (BOOL)isIgnoreFields:(NSString *)fieldsType;

+ (NSString*)getIgnoreFieldsLog;

@end
