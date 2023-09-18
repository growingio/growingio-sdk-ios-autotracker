//
//  GrowingAttributesBuilder.m
//  GrowingAnalytics
//
//  Created by MazeMao on 2022/3/7.
//  Copyright (C) 2021 Beijing Yishu Technology Co., Ltd.
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

#import "GrowingTrackerCore/Public/GrowingAttributesBuilder.h"
#import "GrowingTrackerCore/Thirdparty/Logger/GrowingLogger.h"

@interface GrowingAttributesBuilder ()

@property (nonatomic, strong) NSMutableDictionary *dictionary;

@end

@implementation GrowingAttributesBuilder

- (void)setString:(NSString *)value forKey:(NSString *)key {
    if (![key isKindOfClass:[NSString class]] || ![value isKindOfClass:[NSString class]]) {
        return;
    }

    [self.dictionary setObject:value forKey:key];
}

- (void)setArray:(NSArray<NSObject *> *)values forKey:(NSString *)key {
    if (![key isKindOfClass:[NSString class]] || ![values isKindOfClass:[NSArray class]] || values.count == 0) {
        return;
    }

    NSMutableArray *array = NSMutableArray.array;
    for (NSObject *value in values) {
        if ([value isKindOfClass:NSString.class]) {
            [array addObject:value];
        } else if ([value isKindOfClass:NSNumber.class]) {
            [array addObject:value];
        } else if ([value isKindOfClass:NSNull.class]) {
            [array addObject:@""];
        } else {
            [array addObject:value.description];
        }
    }

    NSString *valueString = [array componentsJoinedByString:self.separate];
    [self.dictionary setObject:valueString forKey:key];
}

- (nullable NSDictionary *)build {
    if (self.dictionary.count == 0) {
        return nil;
    }
    return [NSDictionary dictionaryWithDictionary:self.dictionary];
}

- (NSMutableDictionary *)dictionary {
    if (!_dictionary) {
        _dictionary = NSMutableDictionary.dictionary;
    }
    return _dictionary;
}

- (NSString *)separate {
    return @"||";
}

@end
