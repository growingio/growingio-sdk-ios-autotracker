//
// GrowingTrackConfiguration+CdpTracker.m
// GrowingAnalytics-cdp
//
//  Created by sheng on 2020/11/24.
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

#import "GrowingTrackerCore-cdp/Public/GrowingTrackConfiguration+CdpTracker.h"
#import <objc/runtime.h>

@implementation GrowingTrackConfiguration (CdpTracker)

+ (void)load {
    SEL originSelector = @selector(copyWithZone:);
    SEL swizzleSelector = @selector(growing_cdp_copyWithZone:);
    
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

- (id)growing_cdp_copyWithZone:(NSZone *)zone {
    GrowingTrackConfiguration *configuration = [self growing_cdp_copyWithZone:zone];
    configuration.dataSourceId = self.dataSourceId.copy;
    return configuration;
}

- (NSString *)dataSourceId {
    return objc_getAssociatedObject(self, @selector(dataSourceId));
}

- (void)setDataSourceId:(NSString *)datasourceId {
    objc_setAssociatedObject(self,
                             @selector(dataSourceId),
                             datasourceId,
                             OBJC_ASSOCIATION_COPY);
}

@end
