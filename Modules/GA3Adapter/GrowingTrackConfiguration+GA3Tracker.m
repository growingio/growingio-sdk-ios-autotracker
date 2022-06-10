//
//  GrowingTrackConfiguration+GA3Tracker.m
//  GrowingAnalytics
//
//  Created by YoloMao on 2022/5/31.
//  Copyright (C) 2022 Beijing Yishu Technology Co., Ltd.
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

#import "Modules/GA3Adapter/Public/GrowingTrackConfiguration+GA3Tracker.h"
#import <objc/runtime.h>

@implementation GrowingTrackConfiguration (GA3Tracker)

+ (void)load {
    SEL originSelector = @selector(copyWithZone:);
    SEL swizzleSelector = @selector(growing_ga3_copyWithZone:);
    
    Method originMethod = class_getInstanceMethod(self, originSelector);
    if (!originMethod) {
        return;
    }
    Method swizzleMethod = class_getInstanceMethod(self, swizzleSelector);
    if (!swizzleMethod) {
        return;
    }
    class_addMethod(self,
                    originSelector,
                    class_getMethodImplementation(self, originSelector),
                    method_getTypeEncoding(originMethod));
    class_addMethod(self,
                    swizzleSelector,
                    class_getMethodImplementation(self, swizzleSelector),
                    method_getTypeEncoding(swizzleMethod));
    
    method_exchangeImplementations(class_getInstanceMethod(self, originSelector), class_getInstanceMethod(self, swizzleSelector));
}

- (id)growing_ga3_copyWithZone:(NSZone *)zone {
    GrowingTrackConfiguration *configuration = [self growing_ga3_copyWithZone:zone];
    configuration.dataSourceIds = self.dataSourceIds.copy;
    return configuration;
}

- (NSDictionary<NSString *, NSString *> *)dataSourceIds {
    return objc_getAssociatedObject(self, @selector(dataSourceIds));
}

- (void)setDataSourceIds:(NSDictionary<NSString *, NSString *> *)datasourceIds {
    objc_setAssociatedObject(self,
                             @selector(dataSourceIds),
                             datasourceIds,
                             OBJC_ASSOCIATION_COPY);
}

@end
