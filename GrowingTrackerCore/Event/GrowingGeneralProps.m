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
#import "GrowingTrackerCore/Utils/GrowingArgumentChecker.h"
#import "GrowingTrackerCore/Utils/GrowingInternalMacros.h"

@interface GrowingGeneralProps ()

@property (nonatomic, strong) NSMutableDictionary<NSString *, id> *internalProps;
@property (atomic, copy) NSDictionary<NSString *, id> *dynamicProps;
@property (nonatomic, copy) NSDictionary<NSString *, id> * (^dynamicPropsBlock)(void);

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

- (NSDictionary<NSString *, id> *)getGeneralProps {
    if (!self.dynamicProps && self.dynamicPropsBlock) {
        // 动态属性未build
        [self buildDynamicGeneralProps];
    }

    __block NSMutableDictionary *properties = nil;
    GROWING_RW_LOCK_READ(lock, properties, ^{
        return self.internalProps.mutableCopy;
    });

    // dynamic general properties > general properties
    if (self.dynamicProps) {
        [properties addEntriesFromDictionary:self.dynamicProps];
    }

    // 置为nil，保证下一次事件能够获取最新值
    self.dynamicProps = nil;

    return [properties copy];
}

- (void)setGeneralProps:(NSDictionary<NSString *, id> *)props {
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

- (void)registerDynamicGeneralPropsBlock:(NSDictionary<NSString *, id> * (^_Nullable)(void))dynamicGeneralPropsBlock {
    GROWING_RW_LOCK_WRITE(lock, ^{
        self.dynamicPropsBlock = dynamicGeneralPropsBlock;
    });
}

- (void)buildDynamicGeneralProps {
    // 一般情况下，buildDynamicGeneralProps应该在用户线程中调用，以获取实际值
    // 目前有：首次初始化SDK、setLoginUserId、setDataCollectionEnabled（皆对应VISIT事件）
    // 其他非必要的场景则在事件创建过程中调用，也就是在GrowingThread
    GROWING_RW_LOCK_READ(lock, self.dynamicProps, ^{
        if (self.dynamicPropsBlock) {
            NSDictionary *dynamicProps = self.dynamicPropsBlock();
            if (dynamicProps && [dynamicProps isKindOfClass:[NSDictionary class]]) {
                return (NSDictionary *)[dynamicProps copy];
            }
        }
        // always return not nil value
        return @{};
    });
}

#pragma mark - Setter && Getter

- (NSMutableDictionary<NSString *, id> *)internalProps {
    if (!_internalProps) {
        _internalProps = [NSMutableDictionary dictionary];
    }
    return _internalProps;
}

@end
