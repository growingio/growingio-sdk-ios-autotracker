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


#import "GrowingModuleManager.h"
#import "GrowingModuleProtocol.h"
#import "GrowingContext.h"
#import <objc/runtime.h>
#import <objc/message.h>

#define kModuleArrayKey     @"moduleClasses"
#define kModuleInfoNameKey  @"moduleClass"
#define kModuleInfoLevelKey @"moduleLevel"
#define kModuleInfoPriorityKey @"modulePriority"
#define kModuleInfoHasInstantiatedKey @"moduleHasInstantiated"

static  NSString *kSetupSelector = @"growingModSetUp:";
static  NSString *kInitSelector = @"growingModInit:";
static  NSString *kSplashSeletor = @"growingModSplash:";
static  NSString *kTearDownSelector = @"growingModTearDown:";
static  NSString *kWillResignActiveSelector = @"growingModWillResignActive:";
static  NSString *kDidEnterBackgroundSelector = @"growingModDidEnterBackground:";
static  NSString *kWillEnterForegroundSelector = @"growingModWillEnterForeground:";
static  NSString *kDidBecomeActiveSelector = @"growingModDidBecomeActive:";
static  NSString *kWillTerminateSelector = @"growingModWillTerminate:";
static  NSString *kUnmountEventSelector = @"growingModUnmount:";
static  NSString *kQuickActionSelector = @"growingModQuickAction:";
static  NSString *kOpenURLSelector = @"growingModOpenURL:";
static  NSString *kDidReceiveMemoryWarningSelector = @"growingModDidReceiveMemoryWaring:";
static  NSString *kFailToRegisterForRemoteNotificationsSelector = @"growingModDidFailToRegisterForRemoteNotifications:";
static  NSString *kDidRegisterForRemoteNotificationsSelector = @"growingModDidRegisterForRemoteNotifications:";
static  NSString *kDidReceiveRemoteNotificationsSelector = @"growingModDidReceiveRemoteNotification:";
static  NSString *kDidReceiveLocalNotificationsSelector = @"growingModDidReceiveLocalNotification:";
static  NSString *kWillPresentNotificationSelector = @"growingModWillPresentNotification:";
static  NSString *kDidReceiveNotificationResponseSelector = @"growingModDidReceiveNotificationResponse:";
static  NSString *kWillContinueUserActivitySelector = @"growingModWillContinueUserActivity:";
static  NSString *kContinueUserActivitySelector = @"growingModContinueUserActivity:";
static  NSString *kDidUpdateContinueUserActivitySelector = @"growingModDidUpdateContinueUserActivity:";
static  NSString *kFailToContinueUserActivitySelector = @"growingModDidFailToContinueUserActivity:";
static  NSString *kHandleWatchKitExtensionRequestSelector = @"growingModHandleWatchKitExtensionRequest:";
static  NSString *kAppCustomSelector = @"growingModDidCustomEvent:";


@interface GrowingModuleManager()

@property(nonatomic, strong) NSMutableArray     *GrowingModuleDynamicClasses;

@property(nonatomic, strong) NSMutableArray<NSDictionary *>     *GrowingModuleInfos;
@property(nonatomic, strong) NSMutableArray     *GrowingModules;

@property(nonatomic, strong) NSMutableDictionary<NSNumber *, NSMutableArray<id<GrowingModuleProtocol>> *> *GrowingModulesByEvent;
@property(nonatomic, strong) NSMutableDictionary<NSNumber *, NSString *> *GrowingSelectorByEvent;

@end


@implementation GrowingModuleManager

+ (instancetype)sharedInstance
{
    static id sharedManager = nil;
    static dispatch_once_t onceToken = 0;
    dispatch_once(&onceToken, ^{
        sharedManager = [[GrowingModuleManager alloc] init];
    });
    return sharedManager;
}


- (void)registerDynamicModule:(Class)moduleClass
{
    [self addModuleFromObject:moduleClass];
}


- (void)unRegisterDynamicModule:(Class)moduleClass {
    if (!moduleClass) {
        return;
    }
    [self.GrowingModuleInfos filterUsingPredicate:[NSPredicate predicateWithFormat:@"%@!=%@", kModuleInfoNameKey, NSStringFromClass(moduleClass)]];
    __block NSInteger index = -1;
    [self.GrowingModules enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:moduleClass]) {
            index = idx;
            *stop = YES;
        }
    }];
    if (index >= 0) {
        [self.GrowingModules removeObjectAtIndex:index];
    }
    [self.GrowingModulesByEvent enumerateKeysAndObjectsUsingBlock:^(NSNumber * _Nonnull key, NSMutableArray<id<GrowingModuleProtocol>> * _Nonnull obj, BOOL * _Nonnull stop) {
        __block NSInteger index = -1;
        [obj enumerateObjectsUsingBlock:^(id<GrowingModuleProtocol>  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj isKindOfClass:moduleClass]) {
                index = idx;
                *stop = YES;
            }
        }];
        if (index >= 0) {
            [obj removeObjectAtIndex:index];
        }
    }];
}

- (void)registedAllModules
{

    [self.GrowingModuleInfos sortUsingComparator:^NSComparisonResult(NSDictionary *module1, NSDictionary *module2) {
        NSNumber *module1Level = (NSNumber *)[module1 objectForKey:kModuleInfoLevelKey];
        NSNumber *module2Level =  (NSNumber *)[module2 objectForKey:kModuleInfoLevelKey];
        if (module1Level.integerValue != module2Level.integerValue) {
            return module1Level.integerValue > module2Level.integerValue;
        } else {
            NSNumber *module1Priority = (NSNumber *)[module1 objectForKey:kModuleInfoPriorityKey];
            NSNumber *module2Priority = (NSNumber *)[module2 objectForKey:kModuleInfoPriorityKey];
            return module1Priority.integerValue < module2Priority.integerValue;
        }
    }];
    
    NSMutableArray *tmpArray = [NSMutableArray array];
    
    //module init
    [self.GrowingModuleInfos enumerateObjectsUsingBlock:^(NSDictionary *module, NSUInteger idx, BOOL * _Nonnull stop) {
        
        NSString *classStr = [module objectForKey:kModuleInfoNameKey];
        
        Class moduleClass = NSClassFromString(classStr);
        BOOL hasInstantiated = ((NSNumber *)[module objectForKey:kModuleInfoHasInstantiatedKey]).boolValue;
        if (NSStringFromClass(moduleClass) && !hasInstantiated) {
            id<GrowingModuleProtocol> moduleInstance = [self getModuleInstanceByClass:moduleClass];
            [self registerEventsByModuleInstance:moduleInstance];
            [tmpArray addObject:moduleInstance];
        }
        
    }];
    
    [self.GrowingModules removeAllObjects];

    [self.GrowingModules addObjectsFromArray:tmpArray];
    
    [self registerAllSystemEvents];
}

- (id <GrowingModuleProtocol>)getModuleInstanceByClass:(Class) moduleClass{
    id<GrowingModuleProtocol> moduleInstance = nil;
    if ([[moduleClass class] respondsToSelector:@selector(singleton)]) {
        BOOL (*sigletonImp)(id,SEL) = (BOOL(*)(id, SEL))objc_msgSend;
        BOOL isSingleton = sigletonImp([moduleClass class], @selector(singleton));
        if (isSingleton) {
            if ([[moduleClass class] respondsToSelector:@selector(sharedInstance)])
                moduleInstance = [[moduleClass class] performSelector:@selector(sharedInstance)];
            else
                moduleInstance = [[moduleClass alloc] init];
        }
    }else {
        moduleInstance = [[moduleClass alloc] init];
    }
    return moduleInstance;
}

- (void)registerCustomEvent:(NSInteger)eventType
   withModuleInstance:(id)moduleInstance
       andSelectorStr:(NSString *)selectorStr {
    if (eventType < 1000) {
        return;
    }
    [self registerEvent:eventType withModuleInstance:moduleInstance andSelectorStr:selectorStr];
}

- (void)triggerEvent:(NSInteger)eventType
{
    [self triggerEvent:eventType withCustomParam:nil];
    
}

- (void)triggerEvent:(NSInteger)eventType
     withCustomParam:(NSDictionary *)customParam {
    [self handleModuleEvent:eventType forTarget:nil withCustomParam:customParam];
}

#pragma mark - life loop

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.GrowingModuleDynamicClasses = [NSMutableArray array];
    }
    return self;
}


#pragma mark - private

- (GrowingModuleLevel)checkModuleLevel:(NSUInteger)level
{
    switch (level) {
        case 0:
            return GrowingModuleBasic;
            break;
        case 1:
            return GrowingModuleNormal;
            break;
        default:
            break;
    }
    //default normal
    return GrowingModuleNormal;
}


- (void)addModuleFromObject:(id)object
{
    Class class;
    NSString *moduleName = nil;
    
    if (object) {
        class = object;
        moduleName = NSStringFromClass(class);
    } else {
        return ;
    }
    
    __block BOOL flag = YES;
    [self.GrowingModules enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:class]) {
            flag = NO;
            *stop = YES;
        }
    }];
    if (!flag) {
        return;
    }
    
    if ([class conformsToProtocol:@protocol(GrowingModuleProtocol)]) {
        NSMutableDictionary *moduleInfo = [NSMutableDictionary dictionary];
        
        BOOL responseBasicLevel = [class instancesRespondToSelector:@selector(basicModuleLevel)];

        int levelInt = 1;
        
        if (responseBasicLevel) {
            levelInt = 0;
        }
        
        [moduleInfo setObject:@(levelInt) forKey:kModuleInfoLevelKey];
        if (moduleName) {
            [moduleInfo setObject:moduleName forKey:kModuleInfoNameKey];
        }

        [self.GrowingModuleInfos addObject:moduleInfo];
    
        [moduleInfo setObject:@(NO) forKey:kModuleInfoHasInstantiatedKey];
        [self.GrowingModules sortUsingComparator:^NSComparisonResult(id<GrowingModuleProtocol> moduleInstance1, id<GrowingModuleProtocol> moduleInstance2) {
            NSNumber *module1Level = @(GrowingModuleNormal);
            NSNumber *module2Level = @(GrowingModuleNormal);
            if ([moduleInstance1 respondsToSelector:@selector(basicModuleLevel)]) {
                module1Level = @(GrowingModuleBasic);
            }
            if ([moduleInstance2 respondsToSelector:@selector(basicModuleLevel)]) {
                module2Level = @(GrowingModuleBasic);
            }
            if (module1Level.integerValue != module2Level.integerValue) {
                return module1Level.integerValue > module2Level.integerValue;
            } else {
                NSInteger module1Priority = 0;
                NSInteger module2Priority = 0;
                if ([moduleInstance1 respondsToSelector:@selector(modulePriority)]) {
                    module1Priority = [moduleInstance1 modulePriority];
                }
                if ([moduleInstance2 respondsToSelector:@selector(modulePriority)]) {
                    module2Priority = [moduleInstance2 modulePriority];
                }
                return module1Priority < module2Priority;
            }
        }];
    }
}

- (void)registerAllSystemEvents
{
    [self.GrowingModules enumerateObjectsUsingBlock:^(id<GrowingModuleProtocol> moduleInstance, NSUInteger idx, BOOL * _Nonnull stop) {
        [self registerEventsByModuleInstance:moduleInstance];
    }];
}

- (void)registerEventsByModuleInstance:(id<GrowingModuleProtocol>)moduleInstance
{
    NSArray<NSNumber *> *events = self.GrowingSelectorByEvent.allKeys;
    [events enumerateObjectsUsingBlock:^(NSNumber * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [self registerEvent:obj.integerValue withModuleInstance:moduleInstance andSelectorStr:self.GrowingSelectorByEvent[obj]];
    }];
}

- (void)registerEvent:(NSInteger)eventType
         withModuleInstance:(id)moduleInstance
             andSelectorStr:(NSString *)selectorStr {
    SEL selector = NSSelectorFromString(selectorStr);
    if (!selector || ![moduleInstance respondsToSelector:selector]) {
        return;
    }
    NSNumber *eventTypeNumber = @(eventType);
    if (!self.GrowingSelectorByEvent[eventTypeNumber]) {
        [self.GrowingSelectorByEvent setObject:selectorStr forKey:eventTypeNumber];
    }
    if (!self.GrowingModulesByEvent[eventTypeNumber]) {
        [self.GrowingModulesByEvent setObject:@[].mutableCopy forKey:eventTypeNumber];
    }
    NSMutableArray *eventModules = [self.GrowingModulesByEvent objectForKey:eventTypeNumber];
    if (![eventModules containsObject:moduleInstance]) {
        [eventModules addObject:moduleInstance];
        [eventModules sortUsingComparator:^NSComparisonResult(id<GrowingModuleProtocol> moduleInstance1, id<GrowingModuleProtocol> moduleInstance2) {
            NSNumber *module1Level = @(GrowingModuleNormal);
            NSNumber *module2Level = @(GrowingModuleNormal);
            if ([moduleInstance1 respondsToSelector:@selector(basicModuleLevel)]) {
                module1Level = @(GrowingModuleBasic);
            }
            if ([moduleInstance2 respondsToSelector:@selector(basicModuleLevel)]) {
                module2Level = @(GrowingModuleBasic);
            }
            if (module1Level.integerValue != module2Level.integerValue) {
                return module1Level.integerValue > module2Level.integerValue;
            } else {
                NSInteger module1Priority = 0;
                NSInteger module2Priority = 0;
                if ([moduleInstance1 respondsToSelector:@selector(modulePriority)]) {
                    module1Priority = [moduleInstance1 modulePriority];
                }
                if ([moduleInstance2 respondsToSelector:@selector(modulePriority)]) {
                    module2Priority = [moduleInstance2 modulePriority];
                }
                return module1Priority < module2Priority;
            }
        }];
    }
}

#pragma mark - property setter or getter
- (NSMutableArray<NSDictionary *> *)GrowingModuleInfos {
    if (!_GrowingModuleInfos) {
        _GrowingModuleInfos = @[].mutableCopy;
    }
    return _GrowingModuleInfos;
}

- (NSMutableArray *)GrowingModules
{
    if (!_GrowingModules) {
        _GrowingModules = [NSMutableArray array];
    }
    return _GrowingModules;
}

- (NSMutableDictionary<NSNumber *, NSMutableArray<id<GrowingModuleProtocol>> *> *)GrowingModulesByEvent
{
    if (!_GrowingModulesByEvent) {
        _GrowingModulesByEvent = @{}.mutableCopy;
    }
    return _GrowingModulesByEvent;
}

- (NSMutableDictionary<NSNumber *, NSString *> *)GrowingSelectorByEvent
{
    if (!_GrowingSelectorByEvent) {
        _GrowingSelectorByEvent = @{
                               @(GrowingMSetupEvent):kSetupSelector,
                               @(GrowingMInitEvent):kInitSelector,
                               @(GrowingMTearDownEvent):kTearDownSelector,
                               @(GrowingMSplashEvent):kSplashSeletor,
                               @(GrowingMWillResignActiveEvent):kWillResignActiveSelector,
                               @(GrowingMDidEnterBackgroundEvent):kDidEnterBackgroundSelector,
                               @(GrowingMWillEnterForegroundEvent):kWillEnterForegroundSelector,
                               @(GrowingMDidBecomeActiveEvent):kDidBecomeActiveSelector,
                               @(GrowingMWillTerminateEvent):kWillTerminateSelector,
                               @(GrowingMUnmountEvent):kUnmountEventSelector,
                               @(GrowingMOpenURLEvent):kOpenURLSelector,
                               @(GrowingMDidReceiveMemoryWarningEvent):kDidReceiveMemoryWarningSelector,
                               
                               @(GrowingMDidReceiveRemoteNotificationEvent):kDidReceiveRemoteNotificationsSelector,
                               @(GrowingMWillPresentNotificationEvent):kWillPresentNotificationSelector,
                               @(GrowingMDidReceiveNotificationResponseEvent):kDidReceiveNotificationResponseSelector,
                               
                               @(GrowingMDidFailToRegisterForRemoteNotificationsEvent):kFailToRegisterForRemoteNotificationsSelector,
                               @(GrowingMDidRegisterForRemoteNotificationsEvent):kDidRegisterForRemoteNotificationsSelector,
                               
                               @(GrowingMDidReceiveLocalNotificationEvent):kDidReceiveLocalNotificationsSelector,
                               
                               @(GrowingMWillContinueUserActivityEvent):kWillContinueUserActivitySelector,
                               
                               @(GrowingMContinueUserActivityEvent):kContinueUserActivitySelector,
                               
                               @(GrowingMDidFailToContinueUserActivityEvent):kFailToContinueUserActivitySelector,
                               
                               @(GrowingMDidUpdateUserActivityEvent):kDidUpdateContinueUserActivitySelector,
                               
                               @(GrowingMQuickActionEvent):kQuickActionSelector,
                               @(GrowingMHandleWatchKitExtensionRequestEvent):kHandleWatchKitExtensionRequestSelector,
                               @(GrowingMDidCustomEvent):kAppCustomSelector,
                               }.mutableCopy;
    }
    return _GrowingSelectorByEvent;
}

#pragma mark - module protocol
- (void)handleModuleEvent:(NSInteger)eventType
                forTarget:(id<GrowingModuleProtocol>)target
          withCustomParam:(NSDictionary *)customParam
{
    switch (eventType) {
        case GrowingMInitEvent:
            //special
            [self handleModulesInitEventForTarget:nil withCustomParam :customParam];
            break;
        case GrowingMTearDownEvent:
            //special
            [self handleModulesTearDownEventForTarget:nil withCustomParam:customParam];
            break;
        default: {
            NSString *selectorStr = [self.GrowingSelectorByEvent objectForKey:@(eventType)];
            [self handleModuleEvent:eventType forTarget:nil withSeletorStr:selectorStr andCustomParam:customParam];
        }
            break;
    }
    
}

- (void)handleModulesInitEventForTarget:(id<GrowingModuleProtocol>)target
                        withCustomParam:(NSDictionary *)customParam
{
    GrowingContext *context = [GrowingContext sharedInstance].copy;
    context.customParam = customParam;
    context.customEvent = GrowingMInitEvent;
    
    NSArray<id<GrowingModuleProtocol>> *moduleInstances;
    if (target) {
        moduleInstances = @[target];
    } else {
        moduleInstances = [self.GrowingModulesByEvent objectForKey:@(GrowingMInitEvent)];
    }
    
    [moduleInstances enumerateObjectsUsingBlock:^(id<GrowingModuleProtocol> moduleInstance, NSUInteger idx, BOOL * _Nonnull stop) {
        __weak typeof(&*self) wself = self;
        void ( ^ bk )(void);
        bk = ^(){
            __strong typeof(&*self) sself = wself;
            if (sself) {
                if ([moduleInstance respondsToSelector:@selector(growingModInit:)]) {
                    [moduleInstance growingModInit:context];
                }
            }
        };

        if ([moduleInstance respondsToSelector:@selector(async)]) {
            BOOL async = [moduleInstance async];
            
            if (async) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    bk();
                });
                
            } else {
                bk();
            }
        } else {
            bk();
        }
    }];
}

- (void)handleModulesTearDownEventForTarget:(id<GrowingModuleProtocol>)target
                            withCustomParam:(NSDictionary *)customParam
{
    GrowingContext *context = [GrowingContext sharedInstance].copy;
    context.customParam = customParam;
    context.customEvent = GrowingMTearDownEvent;
    
    NSArray<id<GrowingModuleProtocol>> *moduleInstances;
    if (target) {
        moduleInstances = @[target];
    } else {
        moduleInstances = [self.GrowingModulesByEvent objectForKey:@(GrowingMTearDownEvent)];
    }

    //Reverse Order to unload
    for (int i = (int)moduleInstances.count - 1; i >= 0; i--) {
        id<GrowingModuleProtocol> moduleInstance = [moduleInstances objectAtIndex:i];
        if (moduleInstance && [moduleInstance respondsToSelector:@selector(growingModTearDown:)]) {
            [moduleInstance growingModTearDown:context];
        }
    }
}

- (void)handleModuleEvent:(NSInteger)eventType
                forTarget:(id<GrowingModuleProtocol>)target
           withSeletorStr:(NSString *)selectorStr
           andCustomParam:(NSDictionary *)customParam
{
    if (!selectorStr.length) {
        selectorStr = [self.GrowingSelectorByEvent objectForKey:@(eventType)];
    }
    SEL seletor = NSSelectorFromString(selectorStr);
    if (!seletor) {
        selectorStr = [self.GrowingSelectorByEvent objectForKey:@(eventType)];
        seletor = NSSelectorFromString(selectorStr);
    }
    NSArray<id<GrowingModuleProtocol>> *moduleInstances;
    if (target) {
        moduleInstances = @[target];
    } else {
        moduleInstances = [self.GrowingModulesByEvent objectForKey:@(eventType)];
    }
    [moduleInstances enumerateObjectsUsingBlock:^(id<GrowingModuleProtocol> moduleInstance, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([moduleInstance respondsToSelector:seletor]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            [moduleInstance performSelector:seletor withObject:nil];
#pragma clang diagnostic pop
        
            
        }
    }];
}


@end
