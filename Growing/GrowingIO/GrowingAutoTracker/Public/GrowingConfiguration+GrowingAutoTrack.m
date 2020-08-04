//
//  GrowingConfiguration+GrowingAutoTrack.m
//  GrowingAutoTracker
//
//  Created by GrowingIO on 2020/7/30.
//  Copyright (C) 2020 Beijing Yishu Technology Co., Ltd.
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


#import "GrowingConfiguration+GrowingAutoTrack.h"
#import "GrowingNetworkConfig.h"
#import "GrowingGlobal.h"
#import <objc/runtime.h>

@implementation GrowingConfiguration (GrowingAutoTrack)

static NSString * _Nonnull const kGrowingGlobalImpScale = @"growingGlobalImpScale";

- (void)setGrowingGlobalImpScale:(double)scale {
    objc_setAssociatedObject(self, &kGrowingGlobalImpScale, [NSNumber numberWithDouble:scale], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (double)growingGlobalImpScale {
    NSNumber *number = objc_getAssociatedObject(self, &kGrowingGlobalImpScale);
    if (number) {
        return [number doubleValue];
    } else {
        return 0.0;
    }
}

@end
