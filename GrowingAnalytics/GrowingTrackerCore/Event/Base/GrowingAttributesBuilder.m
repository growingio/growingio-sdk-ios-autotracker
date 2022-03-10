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

#import "GrowingAttributesBuilder.h"
#import "GrowingLogger.h"

@interface GrowingAttributesBuilder ()

@property (nonatomic, strong) NSMutableDictionary *dictionary;

@end

@implementation GrowingAttributesBuilder

- (void)setString:(NSString *)value forKey:(NSString *)key {
    [self.dictionary setObject:value forKey:key];
}

- (void)setArray:(NSArray<NSString *> *)values forKey:(NSString *)key {
    if (![values isKindOfClass:[NSArray class]]) {
        return;
    }
    
    for (NSString *value in values) {
        if (![value isKindOfClass:NSString.class]) {
            GIOLogError(@"element in array is not kind of NSString class");
            return;
        }
    }
    
    NSString *valueString = [values componentsJoinedByString:self.separate];
    [self.dictionary setObject:valueString forKey:key];
}

- (NSDictionary *)build {
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
