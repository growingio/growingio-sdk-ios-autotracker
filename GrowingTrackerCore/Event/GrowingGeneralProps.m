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
#import "GrowingTrackerCore/Thread/GrowingDispatchManager.h"
#import "GrowingTrackerCore/Utils/GrowingArgumentChecker.h"

@interface GrowingGeneralProps ()

@property (nonatomic, strong) NSMutableDictionary<NSString *, id> *internalProps;
@property (nonatomic, copy) NSDictionary<NSString *, id> * (^dynamicPropsGenerator)(void);

@end

@implementation GrowingGeneralProps

+ (instancetype)sharedInstance {
    static GrowingGeneralProps *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (NSDictionary<NSString *, id> *)getGeneralProps {
    // running on GrowingThread
    NSDictionary<NSString *, id> *dynamicProps = nil;
    if (self.dynamicPropsGenerator) {
        NSDictionary *dic = self.dynamicPropsGenerator();
        if (dic && [dic isKindOfClass:[NSDictionary class]]) {
            dynamicProps = (NSDictionary *)[dic copy];
        }
    }

    NSMutableDictionary *properties = self.internalProps.mutableCopy;
    // dynamic general properties > general properties
    if (dynamicProps) {
        [properties addEntriesFromDictionary:dynamicProps];
    }
    return [properties copy];
}

- (void)setGeneralProps:(NSDictionary<NSString *, id> *)props {
    if ([GrowingArgumentChecker isIllegalAttributes:props]) {
        return;
    }
    [GrowingDispatchManager dispatchInGrowingThread:^{
        [self.internalProps addEntriesFromDictionary:props];
    }];
}

- (void)removeGeneralProps:(NSArray<NSString *> *)keys {
    if ([GrowingArgumentChecker isIllegalKeys:keys]) {
        return;
    }
    [GrowingDispatchManager dispatchInGrowingThread:^{
        [self.internalProps removeObjectsForKeys:keys];
    }];
}

- (void)clearGeneralProps {
    [GrowingDispatchManager dispatchInGrowingThread:^{
        [self.internalProps removeAllObjects];
    }];
}

- (void)setDynamicGeneralPropsGenerator:(NSDictionary<NSString *, id> * (^_Nullable)(void))generator {
    [GrowingDispatchManager dispatchInGrowingThread:^{
        self.dynamicPropsGenerator = generator;
    }];
}

#pragma mark - Setter && Getter

- (NSMutableDictionary<NSString *, id> *)internalProps {
    if (!_internalProps) {
        _internalProps = [NSMutableDictionary dictionary];
    }
    return _internalProps;
}

@end
