//
//  GrowingTrackConfiguration.m
//  GrowingAnalytics
//
//  Created by xiangyang on 2020/11/6.
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

#import "GrowingTrackerCore/Public/GrowingTrackConfiguration.h"
#import "GrowingTrackerCore/Manager/GrowingSession.h"

NSString * const kGrowingDefaultDataCollectionServerHost = @"https://api.growingio.com";

@interface GrowingTrackConfiguration ()

// Advert
@property (nonatomic, assign) BOOL ASAEnabled;
@property (nonatomic, copy) NSString *deepLinkHost;
@property (nonatomic, copy) id deepLinkCallback;
@property (nonatomic, assign) BOOL readClipboardEnabled;

// APM
@property (nonatomic, copy) NSObject *APMConfig;

@end

@implementation GrowingTrackConfiguration

- (instancetype)initWithProjectId:(NSString *)projectId {
    self = [super init];
    if (self) {
        _projectId = [projectId copy];
        _dataSourceId = nil;
        
        _debugEnabled = NO;
        _cellularDataLimit = 10;
        _dataUploadInterval = 15;
        _sessionInterval = 30;
        _dataCollectionEnabled = YES;
        _uploadExceptionEnable = YES;
        _dataCollectionServerHost = kGrowingDefaultDataCollectionServerHost;
        _excludeEvent = 0;
        _ignoreField = 0;
        _idMappingEnabled = NO;
        _urlScheme = nil;
        _encryptEnabled = NO;
        
        // Advert
        _ASAEnabled = NO;
        _deepLinkHost = nil;
        _deepLinkCallback = nil;
        _readClipboardEnabled = YES;
        
        // APM
        _APMConfig = nil;
    }

    return self;
}

+ (instancetype)configurationWithProjectId:(NSString *)projectId {
    return [[self alloc] initWithProjectId:projectId];
}

- (id)copyWithZone:(NSZone *)zone {
    GrowingTrackConfiguration *configuration = [[[self class] allocWithZone:zone] init];
    configuration->_projectId = [_projectId copy];
    configuration->_dataSourceId = [_dataSourceId copy];
    configuration->_debugEnabled = _debugEnabled;
    configuration->_cellularDataLimit = _cellularDataLimit;
    configuration->_dataUploadInterval = _dataUploadInterval;
    configuration->_sessionInterval = _sessionInterval;
    configuration->_dataCollectionEnabled = _dataCollectionEnabled;
    configuration->_uploadExceptionEnable = _uploadExceptionEnable;
    configuration->_dataCollectionServerHost = [_dataCollectionServerHost copy];
    configuration->_excludeEvent = _excludeEvent;
    configuration->_ignoreField = _ignoreField;
    configuration->_idMappingEnabled = _idMappingEnabled;
    configuration->_urlScheme = _urlScheme;
    configuration->_encryptEnabled = _encryptEnabled;
    
    // Advert
    configuration->_ASAEnabled = _ASAEnabled;
    configuration->_deepLinkHost = [_deepLinkHost copy];
    configuration->_deepLinkCallback = [_deepLinkCallback copy];
    configuration->_readClipboardEnabled = _readClipboardEnabled;
    
    // APM
    configuration->_APMConfig = [_APMConfig copy];
    return configuration;
}

@end
