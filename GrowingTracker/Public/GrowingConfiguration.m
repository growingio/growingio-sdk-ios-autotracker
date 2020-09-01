//
//  GrowingConfiguration.m
//  GrowingTracker
//
//  Created by GrowingIO on 2020/5/13.
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


#import "GrowingTracker.h"
#import "GrowingNetworkConfig.h"
#import "GrowingGlobal.h"
#import "GrowingDeviceInfo.h"
#import "GrowingConfiguration.h"

@interface GrowingConfiguration () <NSCopying>

/// 项目 id
@property (nonatomic, copy, readwrite) NSString * projectId;
/// App 启动的 launchOptions
@property (nonatomic, copy, readwrite) NSDictionary *launchOptions;

@end

@implementation GrowingConfiguration

- (instancetype)initWithProjectId:(NSString *)projectId launchOptions:(NSDictionary *)launchOptions {
    if (self = [super init]) {
        self.projectId = projectId;
        self.launchOptions = launchOptions;
        
        self.logEnabled = NO;
        self.dataUploadInterval = 15;
        self.sessionInterval = 30;
        self.cellularDataLimit = 10; // default 10MB
        self.uploadExceptionEnable = YES;
        self.samplingRate = 1.0;
    }
    return self;
}

- (void)setDataTrackHost:(NSString *)host {
    [GrowingNetworkConfig.sharedInstance setCustomTrackerHost:host];
}

- (void)setWebCircleHost:(NSString *)host {
    [GrowingNetworkConfig.sharedInstance setCustomDataHost:host];
}

- (void)setWebSocketHost:(NSString *)host {
    [GrowingNetworkConfig.sharedInstance setCustomWsHost:host];
}

- (void)setUrlScheme:(NSString *)urlScheme {
    _urlScheme = urlScheme;
    [GrowingDeviceInfo configUrlScheme:urlScheme];
}

#pragma mark - GrowingSettingProtocol

- (void)setDataTrackEnabled:(BOOL)dataTrackEnabled {
    [Growing setDataTrackEnabled:dataTrackEnabled];
}

- (void)setDataUploadEnabled:(BOOL)dataUploadEnabled {
    [Growing setDataUploadEnabled:dataUploadEnabled];
}

- (BOOL)dataTrackEnabled {
    return !GrowingSDKDoNotTrack();
}

- (BOOL)dataUploadEnabled {
    return !GrowingSDKDoNotUpload();
}

#pragma mark NSCopying

- (id)copyWithZone:(NSZone *)zone {
    GrowingConfiguration *config = [[[self class] allocWithZone:zone] init];
    config.projectId = self.projectId;
    config.launchOptions = self.launchOptions;
    
    config.logEnabled = self.logEnabled;
    config.dataUploadInterval = self.dataUploadInterval;
    config.sessionInterval = self.sessionInterval;
    config.cellularDataLimit = self.cellularDataLimit;
    config.uploadExceptionEnable = self.uploadExceptionEnable;
    config.samplingRate = self.samplingRate;
        
    return config;
}

@end
