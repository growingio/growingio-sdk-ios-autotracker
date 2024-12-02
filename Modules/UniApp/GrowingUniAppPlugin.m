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
#import "GrowingTrackerCore/Event/Autotrack/GrowingPageEvent.h"
#import "GrowingTrackerCore/Event/GrowingEventManager.h"
#import "GrowingTrackerCore/Manager/GrowingSession.h"
#import "GrowingTrackerCore/Public/GrowingAttributesBuilder.h"
#import "GrowingTrackerCore/Thread/GrowingDispatchManager.h"

GrowingMod(GrowingUniAppPlugin)

@interface GrowingUniAppPlugin ()

@end

@implementation GrowingUniAppPlugin

#pragma mark - GrowingModuleProtocol

- (void)growingModInit:(GrowingContext *)context {
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

- (void)trackPageEvent:(NSString *)pageName
            attributes:(NSDictionary<NSString *, NSString *> *_Nullable)attributes {
    if (!pageName || ![pageName isKindOfClass:[NSString class]] || pageName.length == 0) {
        return;
    }
    GrowingPageBuilder *builder = GrowingPageEvent.builder.setPath(pageName);
    if (attributes) {
        builder = builder.setAttributes(attributes);
    }
    [self trackAutotrackEventWithBuilder:builder];
}

- (void)trackAutotrackEventWithBuilder:(GrowingBaseBuilder *)builder {
    [GrowingDispatchManager dispatchInGrowingThread:^{
        if ([GrowingSession currentSession].state != GrowingSessionStateActive) {
            return;
        }
        GrowingBaseBuilder *b = builder.setScene(GrowingEventSceneUniApp);
        [[GrowingEventManager sharedInstance] postEventBuilder:b];
    }];
}

@end
