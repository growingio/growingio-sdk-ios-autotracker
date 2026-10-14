//
// GrowingUniAppPlugin.h
// GrowingAnalytics
//
//  Created by YoloMao on 2024/12/2.
//  Copyright (C) 2024 Beijing Yishu Technology Co., Ltd.
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

#import "Modules/UniApp/Public/GrowingUniAppPlugin.h"
#import "GrowingTrackerCore/Core/GrowingContext.h"
#import "GrowingTrackerCore/Event/Autotrack/GrowingPageEvent.h"
#import "GrowingTrackerCore/Event/GrowingEventManager.h"
#import "GrowingTrackerCore/Manager/GrowingConfigurationManager.h"
#import "GrowingTrackerCore/Manager/GrowingSession.h"
#import "GrowingTrackerCore/Public/GrowingAttributesBuilder.h"
#import "GrowingTrackerCore/Thirdparty/Logger/GrowingLogger.h"
#import "GrowingTrackerCore/Thread/GrowingDispatchManager.h"

GrowingMod(GrowingUniAppPlugin)

@interface GrowingUniAppPlugin ()
@property (atomic, copy, readwrite) NSDictionary *routingContext;

@end

@implementation GrowingUniAppPlugin

#pragma mark - GrowingModuleProtocol

- (void)growingModInit:(GrowingContext *)context {
    self.routingContext = GrowingConfigurationManager.sharedInstance.committedContext;
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(sessionDidRefresh:)
                                                 name:GrowingSessionDidRefreshNotification
                                               object:nil];
}

- (void)sessionDidRefresh:(NSNotification *)notification {
    if (!self.onDataSourceChanged && [notification.userInfo[@"context"][@"sequence"] unsignedIntegerValue] == 0) return;
    [self publishRoutingContext:notification.userInfo[@"context"]];
}

- (void)growingModDataSourceChanged:(GrowingContext *)context {
    [self publishRoutingContext:context.customParam[@"newContext"]];
}

- (void)publishRoutingContext:(NSDictionary *)context {
    NSDictionary *snapshot = [context dictionaryWithValuesForKeys:@[@"dataSourceId", @"sessionId", @"sequence"]];
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.onDataSourceChanged) {
            self.onDataSourceChanged(snapshot);
        } else {
            GIOLogError(@"Cross-platform plugin has no routing synchronization handler");
        }
    });
}

- (void)confirmRoutingContext:(NSDictionary *)context {
    NSDictionary *snapshot = context.copy;
    [GrowingDispatchManager enqueueInGrowingThread:^{
        NSDictionary *current = GrowingConfigurationManager.sharedInstance.eventContext;
        if ([snapshot[@"sequence"] isEqual:current[@"sequence"]] &&
            [snapshot[@"sessionId"] isEqual:current[@"sessionId"]] &&
            [snapshot[@"dataSourceId"] isEqual:current[@"dataSourceId"]]) {
            self.routingContext = snapshot;
        }
    }];
}

+ (BOOL)singleton {
    return YES;
}

+ (instancetype)sharedInstance {
    static id plugin = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        plugin = [[GrowingUniAppPlugin alloc] init];
    });
    return plugin;
}

#pragma mark - Autotrack Event

- (void)trackPageEvent:(NSString *)pageName attributes:(NSDictionary<NSString *, NSString *> *_Nullable)attributes {
    [self trackPageEvent:pageName attributes:attributes routingContext:nil];
}

- (void)trackPageEvent:(NSString *)pageName
            attributes:(NSDictionary<NSString *, NSString *> *)attributes
        routingContext:(NSDictionary *)routingContext {
    if (!pageName || ![pageName isKindOfClass:[NSString class]] || pageName.length == 0) {
        return;
    }
    GrowingPageBuilder *builder = GrowingPageEvent.builder.setPath(pageName);
    if (attributes) {
        builder = builder.setAttributes(attributes);
    }
    if ([routingContext[@"dataSourceId"] isKindOfClass:NSString.class] &&
        [routingContext[@"sessionId"] isKindOfClass:NSString.class])
        builder.eventContext = routingContext;
    [self trackAutotrackEventWithBuilder:builder];
}

- (void)trackAutotrackEventWithBuilder:(GrowingBaseBuilder *)builder {
    [GrowingDispatchManager dispatchInGrowingThread:^{
        if (!builder.eventContext) {
            NSDictionary *current = GrowingConfigurationManager.sharedInstance.eventContext;
            NSDictionary *applied = self.routingContext;
            if ([current[@"sequence"] unsignedIntegerValue] > 0 && applied &&
                (![applied[@"sequence"] isEqual:current[@"sequence"]] ||
                 ![applied[@"sessionId"] isEqual:current[@"sessionId"]]))
                builder.eventContext = applied;
        }
        if (!builder.eventContext && [GrowingSession currentSession].state != GrowingSessionStateActive) {
            return;
        }
        GrowingBaseBuilder *b = builder.setScene(GrowingEventSceneUniApp);
        [[GrowingEventManager sharedInstance] postEventBuilder:b];
    }];
}

@end
