//
//  GrowingHubFrameworkAdapter.m
//  GrowingAnalytics
//
//  Created by YoloMao on 2023/2/6.
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

#import "Modules/HubFrameworkAdapter/GrowingHubFrameworkAdapter.h"
#import "GrowingAutotrackerCore/GrowingNode/GrowingViewClickProvider.h"
#import "GrowingTrackerCore/Thirdparty/Logger/GrowingLogger.h"
#import "GrowingULSwizzle.h"
#import <objc/runtime.h>
#import <objc/message.h>

GrowingMod(GrowingHubFrameworkAdapter)

@implementation GrowingHubFrameworkAdapter

- (void)growingModInit:(GrowingContext *)context {
    [self adapter];
}

- (void)adapter {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSError *error = NULL;
        
        __block NSInvocation *invocation = nil;
        Class hubComponentWrapperClass = NSClassFromString(@"HUBComponentWrapper");
        if (!hubComponentWrapperClass) {
            GIOLogError(@"Failed to swizzle HUBComponentWrapper. Details: HUBComponentWrapper Class Not Found");
            return;
        }
        invocation = [hubComponentWrapperClass growingul_swizzleMethod:NSSelectorFromString(@"handleGestureRecognizer:")
                                                             withBlock:^(id wrapper, UIGestureRecognizer *gestureRecognizer) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            if (gestureRecognizer.state == UIGestureRecognizerStateEnded) {
                id view = gestureRecognizer.view;
                
                // 兼容特殊布局场景，如：HUBCollectionView嵌套布局
                id model = [wrapper performSelector:NSSelectorFromString(@"model")];
                NSUInteger index = ((NSUInteger(*)(id, SEL))objc_msgSend)(model, NSSelectorFromString(@"index"));
                if (index >= 0) {
                    id parent = [wrapper performSelector:NSSelectorFromString(@"parent")];
                    if (parent) {
                        NSDictionary *visibleChildViewsByIndex = [parent performSelector:NSSelectorFromString(@"visibleChildViewsByIndex")];
                        if (visibleChildViewsByIndex) {
                            id visibleChildView = visibleChildViewsByIndex[@(index)];
                            SEL selector = NSSelectorFromString(@"component");
                            if ([visibleChildView respondsToSelector:selector]) {
                                id wrapper2 = [visibleChildView performSelector:selector];
                                if (wrapper2 == wrapper) {
                                    view = visibleChildView;
                                }
                            }
                        }
                    }
                }
                
                [GrowingViewClickProvider viewOnClick:view];
            }
            
            [invocation setArgument:&gestureRecognizer atIndex:2];
            [invocation invokeWithTarget:wrapper];
#pragma clang diagnostic pop
        } error:&error];
        
        if (error) {
            GIOLogError(@"Failed to swizzle HUBComponentWrapper handleGestureRecognizer:. Details: %@", error);
            error = NULL;
        }
    });
}

@end
