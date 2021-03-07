//
// GrowingExtensionHandler.m
// GrowingAnalytics-edc4f91e
//
//  Created by sheng on 2021/3/6.
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


#import "GrowingExtensionHandler.h"
#import "GrowingAppLifecycle.h"
#import "GrowingConfigurationManager.h"
#import "GrowingAppExtensionManager.h"
#import "GrowingConversionVariableEvent.h"
#import "GrowingDispatchManager.h"
#import "GrowingEventManager.h"
#import "GrowingLoginUserAttributesEvent.h"
#import "GrowingCustomEvent.h"
#import "GrowingEventGenerator.h"

@interface GrowingExtensionHandler () <GrowingAppLifecycleDelegate>

@property (nonatomic, strong) NSArray *groups;

@end

@implementation GrowingExtensionHandler

static GrowingExtensionHandler *mhandler = nil;
+ (void)start {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSArray* extensionAppIdentifiers = GrowingConfigurationManager.sharedInstance.trackConfiguration.extensionAppIdentifiers;
        mhandler = [[self alloc] initWithGroups:extensionAppIdentifiers];
        [mhandler applicationDidBecomeActive];
    });
    [GrowingAppLifecycle.sharedInstance addAppLifecycleDelegate:mhandler];
}

- (instancetype)initWithGroups:(NSArray *)groups {
    if (self = [super init]) {
        self.groups = groups;
    }
    return self;
}

- (void)applicationDidBecomeActive {
    [GrowingDispatchManager dispatchInGrowingThread:^{
        for (NSString *groupId in self.groups) {
            [self trackExensionWithGroupIdentifier:groupId completion:nil];
        }
    }];
}

- (void)trackExensionWithGroupIdentifier:(NSString *)groupIdentifier completion:(void (^)(NSString *groupIdentifier, NSDictionary *eventDic)) completion {
    @try {
        if (groupIdentifier == nil || [groupIdentifier isEqualToString:@""]) {
            return;
        }
        NSDictionary *eventDic = [[GrowingAppExtensionManager sharedInstance] readAllEventsWithGroupIdentifier:groupIdentifier];
        if (!eventDic || eventDic.count <= 0) {
            return;
        }
        NSArray *trackEvents = eventDic[kGrowingExtensionCustomEvent];
        if (trackEvents) {
            for (NSDictionary *dict in trackEvents) {
                NSString *eventName = dict[kGrowingExtension_event];
                if (!eventName) {
                    break;
                }
                NSDictionary *attributes = dict[kGrowingExtension_attributes];
                NSNumber* timestampNum = dict[kGrowingExtension_timestamp];
                
                GrowingBaseBuilder *builder = GrowingCustomEvent.builder.setEventName(eventName).setAttributes(attributes);
                if (timestampNum) {
                    builder.setTimestamp(timestampNum.longLongValue);
                }
                [[GrowingEventManager shareInstance] postEventBuidler:builder];
            }
        }
        
        NSArray *conversionEvents = eventDic[kGrowingExtensionConversionVariables];
        if (conversionEvents) {
            for (NSDictionary *dict in conversionEvents) {
                //TODO: add track
                [GrowingEventGenerator generateConversionAttributesEvent:dict[kGrowingExtension_attributes]];
            }
        }
        
        NSArray *visitorEvents = eventDic[kGrowingExtensionLoginUserAttributes];
        if (visitorEvents) {
            for (NSDictionary *dict in visitorEvents) {
                //TODO: add track
                [GrowingEventGenerator generateLoginUserAttributesEvent:dict[kGrowingExtension_attributes]];
            }
        }
        
        [[GrowingAppExtensionManager sharedInstance] deleteEventsWithGroupIdentifier:groupIdentifier];
        if (completion) {
            completion(groupIdentifier, eventDic);
        }
    } @catch (NSException *exception) {
        NSLog(@"%@ error: %@", self, exception);
    }
}

@end
