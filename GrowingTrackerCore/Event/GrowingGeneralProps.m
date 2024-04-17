//
//  GrowingGeneralProps.m
//  GrowingAnalytics
//
//  Created by YoloMao on 2023/10/20.
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

#import "GrowingTrackerCore/Event/GrowingGeneralProps.h"

@interface GrowingGeneralProps ()

@property (nonatomic, strong) NSMutableDictionary<NSString *, NSString *> *internalProps;
@property (nonatomic, copy) NSDictionary<NSString *, NSString *> *(^dynamicPropsBlock)(void);

@end

@implementation GrowingGeneralProps

- (void)setGeneralProps:(NSDictionary<NSString *, NSString *> *)props {
    [self.internalProps addEntriesFromDictionary:props];
}

- (void)registerDynamicGeneralPropsBlock:(NSDictionary<NSString *, NSString *> *(^_Nullable)(void))dynamicGeneralPropsBlock {
    self.dynamicPropsBlock = dynamicGeneralPropsBlock;
}

- (void)removeGeneralProps:(NSArray<NSString *> *)keys {
    [self.internalProps removeObjectsForKeys:keys];
}

- (void)clearGeneralProps {
    [self.internalProps removeAllObjects];
}

- (NSDictionary<NSString *, NSString *> *)validProperties:(NSDictionary *)properties {
    if (![properties isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    
    NSMutableDictionary *result = [NSMutableDictionary dictionary];
    for (NSString *key in properties.allKeys) {
        id value = properties[key];
        if ([value isKindOfClass:[NSString class]]) {
            result[key] = value;
        } else if ([value isKindOfClass:[NSNumber class]]) {
            result[key] = ((NSNumber *)value).stringValue;
        }
    }
    return [result copy];
}

#pragma mark - Setter && Getter

- (NSDictionary<NSString *, NSString *> *)props {
    // dynamic general properties > general properties
    NSMutableDictionary *finalProps = self.internalProps.mutableCopy;
    if (self.dynamicPropsBlock) {
        NSDictionary *dynamicProps = self.dynamicPropsBlock();
        if (dynamicProps && [dynamicProps isKindOfClass:[NSDictionary class]]) {
            [finalProps addEntriesFromDictionary:dynamicProps];
        }
    }
    return [self validProperties:finalProps];
}

- (NSMutableDictionary<NSString *, NSString *> *)internalProps {
    if (!_internalProps) {
        _internalProps = [NSMutableDictionary dictionary];
    }
    return _internalProps;
}

@end
