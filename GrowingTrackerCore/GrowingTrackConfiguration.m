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

NSString *const kGrowingDefaultDataCollectionServerHost = @"https://napi.growingio.com";
NSString *const kGrowingDefaultDeepLinkHost = @"https://link.growingio.com";
NSString *const kGrowingDefaultABTestingServerHost = @"https://ab.growingio.com";

@interface GrowingTrackConfiguration ()

// Ads
@property (nonatomic, assign) BOOL ASAEnabled;
@property (nonatomic, copy) NSString *deepLinkHost;
@property (nonatomic, copy) id deepLinkCallback;
@property (nonatomic, assign) BOOL readClipboardEnabled;

// APM
@property (nonatomic, copy) NSObject *APMConfig;

// ABTesting
@property (nonatomic, copy) NSString *abTestingServerHost;
@property (nonatomic, assign) NSUInteger abTestingRequestInterval;

@end

@implementation GrowingTrackConfiguration

- (instancetype)initWithAccountId:(NSString *)accountId {
    self = [super init];
    if (self) {
        _accountId = [accountId copy];
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
        _compressEnabled = NO;
        _networkConfig = nil;
        _useProtobuf = YES;
        _dataValidityPeriod = 7;
        _customEventWithPath = NO;

        // Ads
        _ASAEnabled = NO;
        _deepLinkHost = kGrowingDefaultDeepLinkHost;
        _deepLinkCallback = nil;
        _readClipboardEnabled = YES;

        // APM
        _APMConfig = nil;

        // ABTesting
        _abTestingServerHost = kGrowingDefaultABTestingServerHost;
        _abTestingRequestInterval = 5;
    }

    return self;
}

+ (instancetype)configurationWithAccountId:(NSString *)accountId {
    return [[self alloc] initWithAccountId:accountId];
}

+ (instancetype)configurationWithProjectId:(NSString *)accountId {
    return [self configurationWithAccountId:accountId];
}

- (id)copyWithZone:(NSZone *)zone {
    GrowingTrackConfiguration *configuration = [[[self class] allocWithZone:zone] init];
    configuration->_accountId = [_accountId copy];
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
    configuration->_compressEnabled = _compressEnabled;
    configuration->_networkConfig = [_networkConfig copy];
    configuration->_useProtobuf = _useProtobuf;
    configuration->_dataValidityPeriod = _dataValidityPeriod;
    configuration->_customEventWithPath = _customEventWithPath;

    // Ads
    configuration->_ASAEnabled = _ASAEnabled;
    configuration->_deepLinkHost = [_deepLinkHost copy];
    configuration->_deepLinkCallback = [_deepLinkCallback copy];
    configuration->_readClipboardEnabled = _readClipboardEnabled;

    // APM
    configuration->_APMConfig = [_APMConfig copy];

    // ABTesting
    configuration->_abTestingServerHost = [_abTestingServerHost copy];
    configuration->_abTestingRequestInterval = _abTestingRequestInterval;

    return configuration;
}

#pragma mark - Setter & Getter

- (void)setDataUploadInterval:(NSTimeInterval)dataUploadInterval {
    if (dataUploadInterval <= 0) {
        return;
    }
    _dataUploadInterval = dataUploadInterval;
}

- (void)setSessionInterval:(NSTimeInterval)sessionInterval {
    if (sessionInterval <= 0) {
        return;
    }
    _sessionInterval = sessionInterval;
}

- (void)setDataValidityPeriod:(NSUInteger)dataValidityPeriod {
    // period range is [3, 30]
    if (dataValidityPeriod < 3) {
        dataValidityPeriod = 3;
    } else if (dataValidityPeriod > 30) {
        dataValidityPeriod = 30;
    }
    _dataValidityPeriod = dataValidityPeriod;
}

@end
