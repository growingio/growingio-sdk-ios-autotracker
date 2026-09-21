//
//  GrowingViewImpression.m
//  GrowingAnalytics
//
//  Created by YoloMao on 2026/9/21.
//  Copyright (C) 2026 Beijing Yishu Technology Co., Ltd.
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

#import "Modules/ViewImpression/Public/GrowingViewImpression.h"
#import "GrowingTrackerCore/Manager/GrowingConfigurationManager.h"
#import "GrowingULApplication.h"
#import "Modules/ViewImpression/GrowingViewImpression+Private.h"

GrowingMod(GrowingViewImpression)

@interface GrowingViewImpression ()

@property (nonatomic, strong) NSHashTable<UIView *> *sourceTable;

@end

@implementation GrowingViewImpression

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
    if ([GrowingULApplication isAppExtension]) {
        return;
    }
}

- (instancetype)init {
    if (self = [super init]) {
        _sourceTable = [[NSHashTable alloc]
            initWithOptions:NSPointerFunctionsWeakMemory | NSPointerFunctionsObjectPointerPersonality
                   capacity:100];
    }
    return self;
}

#pragma mark - Private Method

- (void)addImpressionView:(UIView *)view {
    [self.sourceTable addObject:view];
}

- (void)removeImpressionView:(UIView *)view {
    [self.sourceTable removeObject:view];
}

+ (GrowingViewImpressionConfig *)effectiveConfig:(GrowingViewImpressionConfig *)config {
    if (config) {
        return [config copy];
    }

    GrowingViewImpressionConfig *global =
        GrowingConfigurationManager.sharedInstance.trackConfiguration.viewImpressionConfig;
    return global ? [global copy] : [[GrowingViewImpressionConfig alloc] init];
}

@end
