//
//  GrowingInstance.m
//  GrowingTracker
//
//  Created by GrowingIO on 6/3/15.
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


#import <Foundation/Foundation.h>
#import "GrowingInstance.h"
#import "NSString+GrowingHelper.h"
#import "NSData+GrowingHelper.h"
#import "GrowingAppLifecycle.h"

static BOOL growingCheckUUIDwithSampling(NSUUID *uuid, CGFloat sampling) {
    // 理论上 idfv是一定有的  但是万一没有就发吧
    if (!uuid) { return YES; }
    if (sampling <= 0) { return NO; }
    if (sampling >= 0.9999) { return YES; }
    
    unsigned char md5[16];
    [[[uuid UUIDString] growingHelper_uft8Data] growingHelper_md5value:md5];
    
    unsigned long bar = 100000;
    unsigned long rightValue = (sampling + 1.0f / bar) * bar;
    unsigned long value = 1;
    
    for (int i = 15; i >= 0 ; i --) {
        unsigned char n = md5[i];
        value = ((value * 256) + n ) % bar;
    }
    
    return (value < rightValue);
}

@interface GrowingInstance ()

@property (nonatomic, strong) GrowingAppLifecycle *appLifecycle;

@end

@implementation GrowingInstance

static GrowingInstance *instance = nil;

+ (instancetype)sharedInstance {
    return instance;
}

+ (void)startWithConfiguration:(GrowingConfiguration *)configuration {
    if (instance) { return; }
    instance = [[self alloc] initWithConfiguration:configuration];
}

- (instancetype)initWithConfiguration:(GrowingConfiguration * _Nonnull)configuration {
    if (self = [self init]) {
        
        _configuration = [configuration copy];
        _projectID = [configuration.projectId copy];
        
        [self updateSampling:[_configuration samplingRate]];
        [self.appLifecycle setupAppStateNotification];
        
        self.gpsLocation = nil;
    }
    return self;
}

- (GrowingAppLifecycle *)appLifecycle {
    if (!_appLifecycle) {
        _appLifecycle = [[GrowingAppLifecycle alloc] init];
    }
    return _appLifecycle;
}

+ (void)updateSampling:(CGFloat)sampling {
    [[self sharedInstance] updateSampling:sampling];
}

- (void)updateSampling:(CGFloat)sampling {
    if (GrowingSDKDoNotTrack()) { return; }
    NSUUID *idfv = [[UIDevice currentDevice] identifierForVendor];
    [Growing setDataTrackEnabled:growingCheckUUIDwithSampling(idfv, sampling)];
}

@end

