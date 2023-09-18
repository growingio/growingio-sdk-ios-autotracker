//
// GrowingModuleManager.m
// GrowingAnalytics
//
//  Created by sheng on 2021/6/17.
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

#import "GrowingTrackerCore/Public/GrowingModuleManager.h"
#import <objc/message.h>
#import <objc/runtime.h>
#import "GrowingTrackerCore/Core/GrowingContext.h"
#import "GrowingTrackerCore/Public/GrowingAnnotationCore.h"
#import "GrowingTrackerCore/Public/GrowingModuleProtocol.h"
#import "GrowingTrackerCore/Thirdparty/Logger/GrowingLogger.h"

static NSString *kInitSelector = @"growingModInit:";
static NSString *kSetDataCollectionEnabledSelector = @"growingModSetDataCollectionEnabled:";

@interface GrowingModuleManager ()

@property (nonatomic, strong) NSMutableArray *modules;
@property (nonatomic, strong) NSMutableDictionary<NSNumber *, NSArray *> *modulesByEvent;
@property (nonatomic, strong) NSDictionary<NSNumber *, NSString *> *selectorByEvent;

@end

@implementation GrowingModuleManager

+ (instancetype)sharedInstance {
    static id _sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[self alloc] init];
    });
    return _sharedInstance;
}

#pragma mark - Public

- (void)registedAllModules {
    [self.modules removeAllObjects];
    NSArray *modules = [self loadLocalModules];
    for (Class moduleClass in modules) {
        id<GrowingModuleProtocol> moduleInstance = [self getModuleInstanceByClass:moduleClass];
        [self.modules addObject:moduleInstance];
        [self registerEventsByModuleInstance:moduleInstance];
    }
}

- (void)triggerEvent:(NSInteger)eventType {
    [self triggerEvent:eventType withCustomParam:nil];
}

- (void)triggerEvent:(NSInteger)eventType withCustomParam:(NSDictionary *)customParam {
    [self handleModuleEvent:eventType withCustomParam:customParam];
}

#pragma mark - Private

// 获取所有通过注解方式注册的moduleClass
- (NSMutableArray *)loadLocalModules {
    // add form section data
    growing_section section = growingSectionDataModule();
    NSMutableArray *array = [NSMutableArray array];
    for (int i = 0; i < section.count; i++) {
        char *string = (char *)section.charAddress[i];
        NSString *str = [NSString stringWithUTF8String:string];
        if (!str) continue;
        GIOLogDebug(@"[GrowingModuleManager] load %@", str);
        if (str) {
            Class class = NSClassFromString(str);
            if (class && [class conformsToProtocol:@protocol(GrowingModuleProtocol)]) {
                [array addObject:class];
            }
        }
    }
    return array;
}

- (id<GrowingModuleProtocol>)getModuleInstanceByClass:(Class)moduleClass {
    if ([[moduleClass class] respondsToSelector:@selector(singleton)]) {
        BOOL (*sigletonImp)(id, SEL) = (BOOL(*)(id, SEL))objc_msgSend;
        BOOL isSingleton = sigletonImp([moduleClass class], @selector(singleton));
        if (isSingleton) {
            if ([[moduleClass class] respondsToSelector:@selector(sharedInstance)]) {
                return [[moduleClass class] performSelector:@selector(sharedInstance)];
            }
        }
    }
    return [[moduleClass alloc] init];
}

- (void)registerEventsByModuleInstance:(id<GrowingModuleProtocol>)moduleInstance {
    for (NSNumber *event in self.selectorByEvent.allKeys) {
        NSString *selString = self.selectorByEvent[event];
        SEL selector = NSSelectorFromString(selString);
        if (!selector || ![moduleInstance respondsToSelector:selector]) {
            continue;
        }
        if (!self.modulesByEvent[event]) {
            [self.modulesByEvent setObject:@[].mutableCopy forKey:event];
        }
        NSArray *eventModules = [self.modulesByEvent objectForKey:event];
        if (![eventModules containsObject:moduleInstance]) {
            [(NSMutableArray *)eventModules addObject:moduleInstance];
        }
    }
}

#pragma mark - Handle event

- (void)handleModuleEvent:(NSInteger)eventType withCustomParam:(NSDictionary *)customParam {
    switch (eventType) {
        case GrowingMInitEvent:
            // special
            [self handleModulesInitEvent:customParam];
            break;
        default: {
            [self handleModuleEvent:eventType customParam:customParam];
        } break;
    }
}

- (void)handleModulesInitEvent:(NSDictionary *)customParam {
    GrowingContext *context = [GrowingContext sharedInstance].copy;
    context.customEvent = GrowingMInitEvent;
    context.customParam = customParam ?: @{};

    NSArray *moduleInstances = [self.modulesByEvent objectForKey:@(GrowingMInitEvent)];
    for (id<GrowingModuleProtocol> module in moduleInstances) {
        if ([module respondsToSelector:@selector(growingModInit:)]) {
            [module growingModInit:context];
        }
    }
}

- (void)handleModuleEvent:(NSInteger)eventType customParam:(NSDictionary *)customParam {
    NSString *selString = [self.selectorByEvent objectForKey:@(eventType)];
    if (!selString.length) {
        return;
    }

    SEL seletor = NSSelectorFromString(selString);
    if (!seletor) {
        return;
    }

    GrowingContext *context = [GrowingContext sharedInstance].copy;
    context.customEvent = eventType;
    context.customParam = customParam ?: @{};

    NSArray *moduleInstances = [self.modulesByEvent objectForKey:@(eventType)];
    for (id<GrowingModuleProtocol> module in moduleInstances) {
        if ([module respondsToSelector:seletor]) {
            void (*imp)(id, SEL, id) = (void (*)(id, SEL, id))objc_msgSend;
            imp(module, seletor, context);
        }
    }
}

#pragma mark - Setter & Getter

- (NSMutableArray *)modules {
    if (!_modules) {
        _modules = [NSMutableArray array];
    }
    return _modules;
}

- (NSMutableDictionary<NSNumber *, NSArray *> *)modulesByEvent {
    if (!_modulesByEvent) {
        _modulesByEvent = @{}.mutableCopy;
    }
    return _modulesByEvent;
}

- (NSDictionary<NSNumber *, NSString *> *)selectorByEvent {
    if (!_selectorByEvent) {
        _selectorByEvent = @{
            @(GrowingMInitEvent): kInitSelector,
            @(GrowingMSetDataCollectionEnabledEvent): kSetDataCollectionEnabledSelector,
        };
    }
    return _selectorByEvent;
}

@end
