//
//  GrowingManualTrackEvent.m
//  GrowingTracker
//
//  Created by GrowingIO on 2018/4/28.
//  Copyright (C) 2018 Beijing Yishu Technology Co., Ltd.
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


#import "GrowingManualTrackEvent.h"
#import "GrowingInstance.h"
#import "GrowingEventManager.h"
#import "GrowingGlobal.h"
#import "GrowingDeviceInfo.h"
#import "NSString+GrowingHelper.h"
#import "NSDictionary+GrowingHelper.h"
#import "GrowingCocoaLumberjack.h"
#import "GrowingPageEvent.h"
#import "GrowingBroadcaster.h"

// 埋点相关

@implementation GrowingEvarEvent

- (NSString*)eventTypeKey {
    return kEventTypeKeyConversionVariable;
}

+ (void)sendEvarEvent:(NSDictionary<NSString *, NSObject *> * _Nonnull)evar {
    if ([GrowingInstance sharedInstance] == nil) {
        return;
    }
    
    GrowingEvarEvent * event = [[GrowingEvarEvent alloc] init];
    event.attributes = evar;
    [[GrowingEventManager shareInstance] addEvent:event thisNode:nil triggerNode:nil withContext:nil];
}

+ (instancetype)hybridEvarEventWithDataDict:(NSDictionary *)dataDict {
    GrowingEvarEvent *evarEvent = [[self alloc] initWithTimestamp:nil];
    evarEvent.attributes = dataDict[@"var"];
    return evarEvent;
}

@end

@interface GrowingCustomTrackEvent ()

@property (nonatomic, copy, readwrite) NSString * _Nonnull eventName;
@property (nonatomic, copy, readwrite) NSString * _Nullable pageName;
@property (nonatomic, strong, readwrite) NSNumber * _Nullable pageTimestamp;

@property (nonatomic, copy) NSString * _Nullable hybridDomain;
@property (nonatomic, copy, readwrite) NSString * _Nullable query;

@end

@implementation GrowingCustomTrackEvent

- (instancetype)initWithEventName:(NSString *)eventName
                     withVariable:(NSDictionary<NSString *, NSObject *> *)variable {
    if (eventName == nil || ![eventName isKindOfClass:[NSString class]]) {
        GIOLogError(parameterKeyErrorLog);
        return nil;
    }
    //eventName 有效性判断
    if (![eventName isValidKey]) {
        GIOLogError(@"event name is invalid!");
        return nil; // invalid eventName is not acceptable
    }
    
    if ([GrowingInstance sharedInstance] == nil) {
        return nil;
    }
    
    GrowingCustomTrackEvent *customEvent = [[GrowingCustomTrackEvent alloc] init];
    customEvent.eventName = eventName;
    if (variable.count != 0) {
        customEvent.attributes = variable;
    }
    
    return customEvent;
}

- (NSString *)eventTypeKey {
    return kEventTypeKeyCustom;
}

+ (void)sendEventWithName:(NSString * _Nonnull)eventName
              andVariable:(NSDictionary<NSString *, NSObject *> * _Nonnull)variable {
    
    GrowingCustomTrackEvent *customEvent = [[GrowingCustomTrackEvent alloc] initWithEventName:eventName
                                                                                 withVariable:variable];
    
    [self sendCustomTrackEvent:customEvent];
}

+ (void)sendCustomTrackEvent:(GrowingCustomTrackEvent *)customEvent {
    
    if (!customEvent) {
        return;
    }
    
    [[GrowingBroadcaster sharedInstance] notifyEvent:@protocol(GrowingManualTrackMessage)
                                          usingBlock:^(id<GrowingManualTrackMessage>  _Nonnull obj) {
        if ([obj respondsToSelector:@selector(manualEventDidTrackWithUserInfo:manualTrackEventType:)]) {
            [obj manualEventDidTrackWithUserInfo:customEvent.toDictionary manualTrackEventType:GrowingManualTrackCustomEventType];
        }
    }];
    
    if ([GrowingEventManager shareInstance].lastPageEvent) {
        customEvent.pageName = [GrowingEventManager shareInstance].lastPageEvent.pageName;
        customEvent.pageTimestamp = [GrowingEventManager shareInstance].lastPageEvent.timestamp;
    }
    
    [[GrowingEventManager shareInstance] addEvent:customEvent thisNode:nil triggerNode:nil withContext:nil];
}

+ (instancetype)hybridCustomEventWithDataDict:(NSDictionary *)dataDict {
    NSNumber *timestamp = dataDict[@"ptm"];

    GrowingCustomTrackEvent *customEvent = [[self alloc] initWithTimestamp:timestamp];
    customEvent.hybridDomain = dataDict[@"d"];
    customEvent.query = dataDict[@"q"];
    customEvent.pageName = dataDict[@"p"];
    customEvent.eventName = dataDict[@"n"];
    customEvent.attributes = dataDict[@"var"];
    
    return customEvent;
}

#pragma mark GrowingEventTransformable

- (NSDictionary *)toDictionary {
    NSMutableDictionary *dataDictM = [NSMutableDictionary dictionaryWithDictionary:[super toDictionary]];
    dataDictM[@"n"] = self.eventName;
    dataDictM[@"p"] = self.pageName;
    dataDictM[@"ptm"] = self.pageTimestamp;
    dataDictM[@"q"] = self.query;
    dataDictM[@"d"] = self.hybridDomain ?: self.domain;
    
    return dataDictM;;
}

@end

@implementation GrowingPeopleVarEvent

- (NSString *)eventTypeKey {
    return kEventTypeKeyPeopleVariable;
}

+ (void)sendEventWithVariable:(NSDictionary<NSString *, NSObject *> * _Nonnull)variable {
    if ([GrowingInstance sharedInstance] == nil ) {
        return;
    }
    
    [[GrowingBroadcaster sharedInstance] notifyEvent:@protocol(GrowingManualTrackMessage)
                                          usingBlock:^(id<GrowingManualTrackMessage>  _Nonnull obj) {
        if ([obj respondsToSelector:@selector(manualEventDidTrackWithUserInfo:manualTrackEventType:)]) {
            [obj manualEventDidTrackWithUserInfo:variable manualTrackEventType:GrowingManualTrackPeopleVarEventType];
        }
    }];
    
    GrowingPeopleVarEvent * event = [[GrowingPeopleVarEvent alloc] init];
    event.attributes = variable;
    [[GrowingEventManager shareInstance] addEvent:event thisNode:nil triggerNode:nil withContext:nil];
}

+ (instancetype)hybridPeopleVarEventWithDataDict:(NSDictionary *)dataDict {
    GrowingPeopleVarEvent *pplEvent = [[self alloc] initWithTimestamp:nil];
    pplEvent.attributes = dataDict[@"var"];
    return pplEvent;
}

@end


@implementation GrowingVisitorEvent

- (instancetype)initWithVisitorVariable:(NSDictionary<NSString *, NSObject *> *)variable
{
    if ([variable isKindOfClass:[NSDictionary class]]) {
        if (![variable isValidDicVar]) {
            return nil;
        }
        if (variable.count > 100 ) {
            GIOLogError(parameterValueErrorLog);
            return nil;
        }
    }
    if ([GrowingInstance sharedInstance] == nil ) {
        return nil;
    }
    GrowingVisitorEvent *visitorEvent = [[GrowingVisitorEvent alloc] init];
    visitorEvent.attributes = variable;
    return visitorEvent;
}

- (NSString*)eventTypeKey {
    return kEventTypeKeyVisitor;
}

+ (void)sendVisitorEventWithVariable:(NSDictionary<NSString *,NSObject *> *)variable {
    if ([GrowingInstance sharedInstance] == nil ) {
        return;
    }
    GrowingVisitorEvent *event = [[GrowingVisitorEvent alloc] init];
    event.attributes = variable;
    
    [self sendVisitorEvent:event];
}

+ (void)sendVisitorEvent:(GrowingVisitorEvent *)event {
    [[GrowingEventManager shareInstance] addEvent:event
                                         thisNode:nil
                                      triggerNode:nil
                                      withContext:nil];
}

+ (instancetype)hybridVisitorEventWithDataDict:(NSDictionary *)dataDict {
    GrowingVisitorEvent *vstrEvent = [[self alloc] initWithTimestamp:nil];
    vstrEvent.attributes = dataDict[@"var"];
    return vstrEvent;
}

@end





