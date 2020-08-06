//
//  GrowingCustomField.m
//  GrowingTracker
//
//  Created by GrowingIO on 15/11/19.
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


#import "GrowingCustomField.h"
#import "NSDictionary+GrowingHelper.h"
#import "GrowingEventManager.h"
#import "GrowingManualTrackEvent.h"
#import "GrowingMobileDebugger.h"
#import "GrowingGlobal.h"
#import "GrowingDispatchManager.h"
#import "GrowingFileStorage.h"
#import "GrowingCocoaLumberjack.h"
#import "GrowingPageEvent.h"

static NSString *const kGrowingUserIdKey = @"userId";
static NSString *const kGrowingCustomField = @"customField";

@interface GrowingCustomField ()

@property (nonatomic, strong) NSMutableDictionary *customFieldDict;
@property (nonatomic, assign) BOOL userCanAccess;
@property (nonatomic, strong) GrowingFileStorage *configStorage;

@end

@implementation GrowingCustomField

+ (instancetype)shareInstance {
    static id obj = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        obj = [[self alloc] init];
    });
    return obj;
}

- (instancetype)init {
    if (self = [super init]) {
                
        self.configStorage = [[GrowingFileStorage alloc] initWithName:@"config"];
        
        NSDictionary *diskField = [self.configStorage dictionaryForKey:kGrowingCustomField];
        if (diskField) {
            self.customFieldDict = [NSMutableDictionary dictionaryWithDictionary:diskField];
        } else {
            self.customFieldDict = [[NSMutableDictionary alloc] init];
        }
        [self configUserId];
    }
    return self;
}

- (void)setUserId:(NSString *)userId {
    _userId = [userId copy];
    if (self.userCanAccess) {
        [self persistenceCustomField];
    }
}

- (void)configUserId {
    self.userCanAccess = NO;
    self.userId = [self.customFieldDict valueForKey:kGrowingUserIdKey];
    self.userCanAccess = YES;
}

- (void)persistenceCustomField {
    
    [self.customFieldDict setValue:self.userId forKey:kGrowingUserIdKey];
    NSMutableDictionary *dataDict = [self.customFieldDict mutableCopy];
    [GrowingDispatchManager dispatchInLowThread:^{
        [self.configStorage setDictionary:dataDict forKey:kGrowingCustomField];
    }];
}

// 埋点相关

- (void)sendEvarEvent:(NSDictionary<NSString *, NSObject *> *)evar {
    [[GrowingMobileDebugger shareDebugger] cacheValue:evar ofType:@"evar"];
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:evar];
    if (![dict isValidDicVar]) {
        return ;
    }
    if (dict.count > 100 ) {
        GIOLogError(parameterValueErrorLog);
        return ;
    }
    [GrowingEvarEvent sendEvarEvent:dict];
}

- (void)sendPeopleEvent:(NSDictionary<NSString *, NSObject *> *)peopleVar {
    //为GrowingMobileDebugger缓存用户设置 - ppl
    [[GrowingMobileDebugger shareDebugger] cacheValue:peopleVar ofType:@"ppl"];
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:peopleVar];
    if (![dict isValidDicVar]) {
        return ;
    }
    if (dict.count > 100 ) {
        GIOLogError(parameterValueErrorLog);
        return ;
    }
    [GrowingPeopleVarEvent sendEventWithVariable:dict];
}

- (void)sendCustomTrackEventWithName:(NSString *)eventName andVariable:(NSDictionary<NSString *, NSObject *> *)variable {
    if ([self isOnlyCoreKit]) {
        [self sendGIOFakePageEvent];
    }
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:variable];
    [GrowingCustomTrackEvent sendEventWithName:eventName andVariable:dict];
}

- (BOOL)isOnlyCoreKit {
    return !NSClassFromString(@"GrowingNodeManager");
}

- (void)sendGIOFakePageEvent {
    if ([self isOnlyCoreKit]) {
        GrowingPageEvent *eventPage = [[GrowingPageEvent alloc] initWithTitle:@""
                                                                     pageName:@"GIOFakePage"
                                                                  referalPage:nil];
        
        [GrowingEventManager shareInstance].lastPageEvent = eventPage;
        
        [[GrowingEventManager shareInstance] addEvent:eventPage
                                             thisNode:nil
                                          triggerNode:nil
                                          withContext:nil];
    }
}

- (void)sendVisitorEvent:(NSDictionary<NSString *, NSObject *> *)variable {
    if ([variable isKindOfClass:[NSDictionary class]]) {
        if (![variable isValidDicVar]) {
            return ;
        }
        if (variable.count > 100 ) {
            GIOLogError(parameterValueErrorLog);
            return ;
        }
    }
    //缓存variable
    self.growingVistorVar = [variable mutableCopy];
    [GrowingVisitorEvent sendVisitorEventWithVariable:variable];
}

@end
