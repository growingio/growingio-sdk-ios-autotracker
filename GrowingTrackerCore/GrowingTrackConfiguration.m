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

#import "GrowingTrackConfiguration.h"
#import "GrowingSession.h"

NSString * const kGrowingDefaultDataCollectionServerHost = @"https://api.growingio.com";

@implementation GrowingTrackConfiguration

- (instancetype)initWithProjectId:(NSString *)projectId {
    self = [super init];
    if (self) {
        _projectId = [projectId copy];
        
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
    }

    return self;
}

+ (instancetype)configurationWithProjectId:(NSString *)projectId {
    return [[self alloc] initWithProjectId:projectId];
}

- (id)copyWithZone:(NSZone *)zone {
    GrowingTrackConfiguration *configuration = [[[self class] allocWithZone:zone] init];
    configuration->_projectId = [_projectId copy];
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
    return configuration;
}

- (void)setDataCollectionEnabled:(BOOL)dataCollectionEnabled {
    if (dataCollectionEnabled == _dataCollectionEnabled) {
        return;
    }
    _dataCollectionEnabled = dataCollectionEnabled;
    if (dataCollectionEnabled) {
        [[GrowingSession currentSession] generateVisit];
    }
}

@end
