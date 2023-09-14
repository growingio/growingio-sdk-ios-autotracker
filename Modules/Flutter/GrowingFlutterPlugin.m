//
// GrowingFlutterPlugin.m
// GrowingAnalytics
//
//  Created by sheng on 2021/8/13.
//  Copyright (C) 2023 Beijing Yishu Technology Co., Ltd.
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

#import "Modules/Flutter/GrowingFlutterPlugin.h"
#import "GrowingTrackerCore/Event/Autotrack/GrowingPageEvent.h"
#import "GrowingTrackerCore/Event/Autotrack/GrowingViewElementEvent.h"
#import "GrowingTrackerCore/Event/GrowingEventManager.h"
#import "GrowingTrackerCore/include/GrowingAttributesBuilder.h"
#import "GrowingTrackerCore/Thread/GrowingDispatchManager.h"
#import "GrowingULAppLifecycle.h"

GrowingMod(GrowingFlutterPlugin)

@interface GrowingFlutterPlugin () <GrowingULAppLifecycleDelegate>

@end

@implementation GrowingFlutterPlugin

#pragma mark - GrowingModuleProtocol

- (void)growingModInit:(GrowingContext *)context {
    [GrowingULAppLifecycle.sharedInstance addAppLifecycleDelegate:self];
}

+ (BOOL)singleton {
    return YES;
}

+ (instancetype)sharedInstance {
    static id plugin = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        plugin = [[GrowingFlutterPlugin alloc] init];
    });
    return plugin;
}

#pragma mark - Autotrack Event

- (void)trackPageEvent:(NSDictionary *)arguments
            attributes:(NSDictionary<NSString *, NSString *> *_Nullable)attributes {
    NSString *path = arguments[@"path"];
    if (!path || ![path isKindOfClass:[NSString class]] || path.length == 0) {
        return;
    }
    NSNumber *ptm = arguments[@"timestamp"];
    if (!ptm || ![ptm isKindOfClass:[NSNumber class]]) {
        return;
    }

    GrowingPageBuilder *builder = GrowingPageEvent.builder.setPath(path).setTimestamp(ptm.longLongValue);
    NSString *title = arguments[@"title"];
    if (title && [title isKindOfClass:[NSString class]] && title.length > 0) {
        builder = builder.setTitle(title);
    }
    if (attributes) {
        builder = builder.setAttributes(attributes);
    }
    [[GrowingEventManager sharedInstance] postEventBuilder:builder];
}

- (void)trackViewElementEvent:(NSDictionary *)arguments {
    NSString *eventType = arguments[@"eventType"];
    if (!eventType || ![eventType isKindOfClass:[NSString class]] || eventType.length == 0) {
        return;
    }
    NSString *xpath = arguments[@"xpath"];
    if (!xpath || ![xpath isKindOfClass:[NSString class]] || xpath.length == 0) {
        return;
    }
    NSString *path = arguments[@"path"];
    if (!path || ![path isKindOfClass:[NSString class]] || path.length == 0) {
        return;
    }

    GrowingViewElementBuilder *builder =
        GrowingViewElementEvent.builder.setEventType(eventType).setXpath(xpath).setPath(path);
    NSString *viewContent = arguments[@"textValue"];
    if (viewContent && [viewContent isKindOfClass:[NSString class]] && viewContent.length > 0) {
        builder = builder.setTextValue(viewContent);
    }
    NSNumber *index = arguments[@"index"];
    if (index && [index isKindOfClass:[NSNumber class]]) {
        builder = builder.setIndex(index.intValue);
    }
    [[GrowingEventManager sharedInstance] postEventBuilder:builder];
}

#pragma mark - GrowingULAppLifecycleDelegate

- (void)applicationDidBecomeActive {
    [GrowingDispatchManager dispatchInGrowingThread:^{
        if (self.onAppDidBecomeActive) {
            self.onAppDidBecomeActive();
        }
    }];
}

- (void)applicationDidEnterBackground {
    [GrowingDispatchManager dispatchInGrowingThread:^{
        if (self.onAppDidEnterBackground) {
            self.onAppDidEnterBackground();
        }
    }];
}

@end
