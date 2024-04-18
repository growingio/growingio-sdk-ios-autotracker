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
#import "GrowingTrackerCore/Utils/GrowingInternalMacros.h"
#import "GrowingTrackerCore/Utils/GrowingArgumentChecker.h"

@interface GrowingGeneralProps ()

@property (nonatomic, strong) NSMutableDictionary<NSString *, NSString *> *internalProps;
@property (nonatomic, strong) NSDictionary<NSString *, NSString *> *dynamicProps;
@property (nonatomic, copy) NSDictionary<NSString *, NSString *> * (^dynamicPropsBlock)(void);

@end

@implementation GrowingGeneralProps {
    GROWING_RW_LOCK_DECLARE(lock);
}

- (instancetype)init {
    if (self = [super init]) {
        GROWING_RW_LOCK_INIT(lock);
    }
    return self;
}

+ (instancetype)sharedInstance {
    static GrowingGeneralProps *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (NSDictionary<NSString *, NSString *> *)getGeneralProps {
    __block NSDictionary *props = nil;
    GROWING_RW_LOCK_READ(lock, props, ^{
        // dynamic general properties > general properties
        NSMutableDictionary *properties = self.internalProps.mutableCopy;
        [properties addEntriesFromDictionary:self.dynamicProps];
        return [self validProperties:properties];
    });
    return [props copy];
}

- (void)setGeneralProps:(NSDictionary<NSString *, NSString *> *)props {
    if ([GrowingArgumentChecker isIllegalAttributes:props]) {
        return;
    }
    GROWING_RW_LOCK_WRITE(lock, ^{
        [self.internalProps addEntriesFromDictionary:props];
    });
}

- (void)removeGeneralProps:(NSArray<NSString *> *)keys {
    if ([GrowingArgumentChecker isIllegalKeys:keys]) {
        return;
    }
    GROWING_RW_LOCK_WRITE(lock, ^{
        [self.internalProps removeObjectsForKeys:keys];
    });
}

- (void)clearGeneralProps {
    GROWING_RW_LOCK_WRITE(lock, ^{
        [self.internalProps removeAllObjects];
    });
}

- (void)registerDynamicGeneralPropsBlock:
    (NSDictionary<NSString *, NSString *> * (^_Nullable)(void))dynamicGeneralPropsBlock {
    GROWING_RW_LOCK_WRITE(lock, ^{
        self.dynamicPropsBlock = dynamicGeneralPropsBlock;
    });
}

- (void)buildDynamicGeneralProps {
    GROWING_RW_LOCK_READ(lock, self.dynamicProps, ^{
        if (self.dynamicPropsBlock) {
            NSDictionary *dynamicProps = self.dynamicPropsBlock();
            if (dynamicProps && [dynamicProps isKindOfClass:[NSDictionary class]]) {
                return (NSDictionary *)[dynamicProps copy];
            }
        }
        return @{};
    });
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

- (NSMutableDictionary<NSString *, NSString *> *)internalProps {
    if (!_internalProps) {
        _internalProps = [NSMutableDictionary dictionary];
    }
    return _internalProps;
}

@end
