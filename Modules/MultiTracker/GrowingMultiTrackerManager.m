//
//  GrowingMultiTrackerManager.m
//  GrowingAnalytics
//
//  Created by YoloMao on 2024/1/29.
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

#import "Modules/MultiTracker/Public/GrowingMultiTrackerManager.h"
#import "GrowingTrackerCore/Core/GrowingContext.h"

GrowingMod(GrowingMultiTrackerManager)

@implementation GrowingMultiTrackerManager

#pragma mark - GrowingModuleProtocol

+ (BOOL)singleton {
    return YES;
}

+ (instancetype)sharedInstance {
    static id _sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[self alloc] init];
    });
    return _sharedInstance;
}

- (void)growingModInit:(GrowingContext *)context {
    
}

- (void)growingModSetDataCollectionEnabled:(GrowingContext *)context {
    NSDictionary *customParam = context.customParam;
    BOOL dataCollectionEnabled = ((NSNumber *)customParam[@"dataCollectionEnabled"]).boolValue;
    if (dataCollectionEnabled) {
        
    } else {
        
    }
}

- (void)growingModSetUserId:(GrowingContext *)context {
    NSDictionary *customParam = context.customParam;
    NSString *userId = customParam[@"userId"];
    NSString *userKey = customParam[@"userKey"];
}

- (void)growingModSessionChanged:(GrowingContext *)context {
    NSDictionary *customParam = context.customParam;
    NSString *sessionId = customParam[@"sessionId"];
}

@end
