//
//  GrowingGA3Injector.m
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

#import "Modules/GA3Adapter/GrowingGA3Injector.h"
#import "Modules/GA3Adapter/GrowingGA3Adapter+Internal.h"
#import "GrowingTrackerCore/Manager/GrowingConfigurationManager.h"
#import "GrowingTrackerCore/Swizzle/GrowingSwizzle.h"
#import "GrowingTrackerCore/Swizzle/GrowingSwizzler.h"
#import <objc/runtime.h>
#import <objc/message.h>

@implementation GrowingGA3Injector

+ (instancetype)sharedInstance {
    static GrowingGA3Injector *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[self alloc] init];
    });

    return _sharedInstance;
}

- (void)addAdapterSwizzles {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class class = NSClassFromString(@"GAI");
        if (!class) {
            @throw [NSException exceptionWithName:@"GoogleAnalytics未集成"
                                           reason:@"请集成GoogleAnalytics，再进行Growing GA3 Adapter适配"
                                         userInfo:nil];
        }
        
        {
            SEL selector = NSSelectorFromString(@"sharedInstance");
            if ([class respondsToSelector:selector]) {
                id sharedInstance = ((id (*)(id, SEL))objc_msgSend)(class, selector);
                selector = NSSelectorFromString(@"defaultTracker");
                if ([sharedInstance respondsToSelector:selector]) {
                    id defaultTracker = ((id (*)(id, SEL))objc_msgSend)(sharedInstance, selector);
                    if (defaultTracker) {
                        @throw [NSException exceptionWithName:@"GoogleAnalytics已初始化"
                                                       reason:@"GoogleAnalytics初始化必须在GrowingAnalytics之后"
                                                     userInfo:nil];
                    }
                }
            }
        }
        
        // 初始化先赋值dataCollectionEnabled
        GrowingConfigurationManager.sharedInstance.trackConfiguration.dataCollectionEnabled = !self.optOut;

        {
            // -[GAI trackerWithName:trackingId:]内部有_cmd判断，需要保证swizzle之后_cmd不变
            SEL selector = NSSelectorFromString(@"trackerWithName:trackingId:");
            Method method = class_getInstanceMethod(class, selector);
            originTrackerInitImp = method_getImplementation(method);
            method_setImplementation(method, (IMP)growingga3_trackerInit);
        }
        
        {
            SEL selector = NSSelectorFromString(@"removeTrackerByName:");
            void (^removeTrackerBlock)(id, SEL, NSString *) = ^(id gai, SEL selector, NSString *name) {
                [GrowingGA3Adapter.sharedInstance removeTrackerByName:name];
            };
            [GrowingSwizzler growing_swizzleSelector:selector
                                             onClass:class
                                           withBlock:removeTrackerBlock
                                               named:@"growing_ga3_adapter_removeTracker"];
        }
        
        {
            // -[GAI setOptOut:]内部有_cmd判断，需要保证swizzle之后_cmd不变
            SEL selector = NSSelectorFromString(@"setOptOut:");
            Method method = class_getInstanceMethod(class, selector);
            originSetOptOutImp = method_getImplementation(method);
            method_setImplementation(method, (IMP)growingga3_setOptOut);
        }
    });
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
- (BOOL)optOut {
    Class class = NSClassFromString(@"GAI");
    SEL selector = NSSelectorFromString(@"sharedInstance");
    if (class && [class respondsToSelector:selector]) {
        id sharedInstance = [class performSelector:selector];
        selector = NSSelectorFromString(@"optOut");
        if (sharedInstance && [sharedInstance respondsToSelector:selector]) {
            return ((BOOL (*)(id, SEL))objc_msgSend)(sharedInstance, selector);
        }
    }
    return NO;
}

static IMP originTrackerInitImp = nil;
static id growingga3_trackerInit(id gai, SEL selector, NSString *name, NSString *trackingId) {
    id tracker = ((id(*)(id, SEL, NSString *, NSString *))originTrackerInitImp)(gai, selector, name, trackingId);
    growingga3_adapter_trackerInit(tracker, name, trackingId);
    return tracker;
}

static IMP originSetOptOutImp = nil;
static void growingga3_setOptOut(id gai, SEL selector, BOOL optOut) {
    ((void(*)(id, SEL, BOOL))originSetOptOutImp)(gai, selector, optOut);
    [GrowingGA3Adapter.sharedInstance setDataCollectionEnabled:!optOut];
}

static void growingga3_adapter_trackerInit(id tracker, NSString *name, NSString *trackingId) {
    [GrowingGA3Adapter.sharedInstance trackerInit:tracker name:name trackingId:trackingId];
    
    {
        SEL selector = @selector(set:value:);
        Class class = [GrowingSwizzler realDelegateClassFromSelector:selector proxy:tracker];
        if ([GrowingSwizzler realDelegateClass:class respondsToSelector:selector]) {
            void (^setValueBlock)(id, SEL, NSString *, NSString *) = ^(id tracker, SEL selector, NSString *parameterName, NSString *value) {
                [GrowingGA3Adapter.sharedInstance tracker:tracker set:parameterName value:value];
            };
            [GrowingSwizzler growing_swizzleSelector:selector
                                             onClass:class
                                           withBlock:setValueBlock
                                               named:@"growing_ga3_adapter_setValue"];
        }
    }

    {
        SEL selector = @selector(send:);
        Class class = [GrowingSwizzler realDelegateClassFromSelector:selector proxy:tracker];
        if ([GrowingSwizzler realDelegateClass:class respondsToSelector:selector]) {
            void (^sendBlock)(id, SEL, NSDictionary *) = ^(id tracker, SEL selector, NSDictionary *parameters) {
                [GrowingGA3Adapter.sharedInstance tracker:tracker send:parameters];
            };
            [GrowingSwizzler growing_swizzleSelector:selector
                                             onClass:class
                                           withBlock:sendBlock
                                               named:@"growing_ga3_adapter_send"];
        }
    }
}
#pragma clang diagnostic pop

@end
