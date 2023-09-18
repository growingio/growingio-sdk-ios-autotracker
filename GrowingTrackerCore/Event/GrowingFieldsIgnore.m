//
// GrowingFieldsIgnore.m
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

#import "GrowingTrackerCore/Public/GrowingFieldsIgnore.h"
#import "GrowingTrackerCore/Manager/GrowingConfigurationManager.h"

// 忽略当前所有可设置的属性掩码值
NSUInteger const GrowingIgnoreFieldsAll =
    (GrowingIgnoreFieldsNetworkState | GrowingIgnoreFieldsScreenWidth | GrowingIgnoreFieldsScreenHeight |
     GrowingIgnoreFieldsDeviceBrand | GrowingIgnoreFieldsDeviceModel | GrowingIgnoreFieldsDeviceType);

@implementation GrowingFieldsIgnore

+ (NSArray *)ignoreFieldsItems {
    static NSArray *_ignoreFieldsItems;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _ignoreFieldsItems =
            @[@"networkState", @"screenHeight", @"screenWidth", @"deviceBrand", @"deviceModel", @"deviceType"];
    });
    return _ignoreFieldsItems;
}

+ (NSUInteger)getIgnoreFieldsMask:(NSString *)typeName {
    NSUInteger index = [[[self class] ignoreFieldsItems] indexOfObject:typeName];
    return index == NSNotFound ? 0 : 1 << index;
}

+ (BOOL)isIgnoreFields:(NSString *)fieldsType {
    NSUInteger ignoreFieldsMask = [GrowingConfigurationManager sharedInstance].trackConfiguration.ignoreField;
    NSUInteger typeMask = [GrowingFieldsIgnore getIgnoreFieldsMask:fieldsType];
    if (ignoreFieldsMask && (ignoreFieldsMask & typeMask) > 0) {
        return true;
    }
    return false;
}

+ (NSString *)getIgnoreFieldsLog {
    NSUInteger ignoreFieldsMask = [GrowingConfigurationManager sharedInstance].trackConfiguration.ignoreField;
    if (ignoreFieldsMask <= 0) {
        return nil;
    }
    NSMutableArray *fields = [NSMutableArray array];
    for (int i = 0; i < [[self class] ignoreFieldsItems].count; i++) {
        if (ignoreFieldsMask & (1 << i)) {
            [fields addObject:[[[self class] ignoreFieldsItems] objectAtIndex:i]];
        }
    }
    NSString *logStr =
        [NSString stringWithFormat:@"[Debug] Ignored Fields : %@", [fields componentsJoinedByString:@","]];
    return logStr;
}

@end
