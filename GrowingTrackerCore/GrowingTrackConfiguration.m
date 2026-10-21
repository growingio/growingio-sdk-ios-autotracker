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
#import "GrowingTrackerCore/GrowingTrackConfiguration+Private.h"
#import "GrowingTrackerCore/Manager/GrowingSession.h"
#import "GrowingTrackerCore/Utils/GrowingInternalMacros.h"

NSString *const kGrowingDefaultDataCollectionServerHost = @"https://napi.growingio.com";
NSString *const kGrowingDefaultDeepLinkHost = @"https://link.growingio.com";
NSString *const kGrowingDefaultABTestingServerHost = @"https://ab.growingio.com";

@interface GrowingTrackConfiguration () {
    // 保护 accountId、dataSourceId、dataCollectionServerHost、dataSourceRoutes：
    // 运行时切换项目和数据源会在事件线程修改它们，而 Hybrid、ABTesting、广告等模块可能在其他线程同时读取。
    // 对象创建时实例变量已置零，与 OS_UNFAIR_LOCK_INIT 相同，copy 出的新对象无需单独初始化。
    GROWING_LOCK_DECLARE(_routingLock);
}

// Ads
@property (nonatomic, assign) BOOL ASAEnabled;
@property (nonatomic, copy) NSString *deepLinkHost;
@property (nonatomic, copy) id deepLinkCallback;
@property (nonatomic, assign) BOOL readClipboardEnabled;
@property (nonatomic, copy) id CAIDFetchBlock;

// APM
@property (nonatomic, copy) NSObject *APMConfig;

// ABTesting
@property (nonatomic, copy) NSString *abTestingServerHost;
@property (nonatomic, assign) NSUInteger abTestingRequestInterval;

// ViewImpression
@property (nonatomic, copy) NSObject *viewImpressionConfig;
@property (nonatomic, assign) BOOL viewImpressionEnabled;
@property (nonatomic, assign) NSTimeInterval viewImpressionCheckInterval;

@end

@implementation GrowingTrackConfiguration

// 下面几个属性自定义了存取方法，需要显式合成实例变量
@synthesize accountId = _accountId;
@synthesize dataSourceId = _dataSourceId;
@synthesize dataCollectionServerHost = _dataCollectionServerHost;
@synthesize dataSourceRoutes = _dataSourceRoutes;

- (instancetype)initWithAccountId:(NSString *)accountId {
    self = [super init];
    if (self) {
        GROWING_LOCK_INIT(_routingLock);
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
        _sceneDelegateClass = nil;

        // Ads
        _ASAEnabled = NO;
        _deepLinkHost = kGrowingDefaultDeepLinkHost;
        _deepLinkCallback = nil;
        _readClipboardEnabled = YES;
        _CAIDFetchBlock = nil;

        // APM
        _APMConfig = nil;

        // ABTesting
        _abTestingServerHost = kGrowingDefaultABTestingServerHost;
        _abTestingRequestInterval = 5;

        // ViewImpression
        _viewImpressionConfig = nil;
        _viewImpressionEnabled = YES;
        _viewImpressionCheckInterval = 0.5;
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
    GROWING_LOCK(_routingLock);
    configuration->_accountId = [_accountId copy];
    configuration->_dataSourceId = [_dataSourceId copy];
    configuration->_dataCollectionServerHost = [_dataCollectionServerHost copy];
    configuration->_dataSourceRoutes = [_dataSourceRoutes copy];
    GROWING_UNLOCK(_routingLock);
    configuration->_debugEnabled = _debugEnabled;
    configuration->_cellularDataLimit = _cellularDataLimit;
    configuration->_dataUploadInterval = _dataUploadInterval;
    configuration->_sessionInterval = _sessionInterval;
    configuration->_dataCollectionEnabled = _dataCollectionEnabled;
    configuration->_uploadExceptionEnable = _uploadExceptionEnable;
    configuration->_excludeEvent = _excludeEvent;
    configuration->_ignoreField = _ignoreField;
    configuration->_idMappingEnabled = _idMappingEnabled;
    configuration->_urlScheme = [_urlScheme copy];
    configuration->_encryptEnabled = _encryptEnabled;
    configuration->_compressEnabled = _compressEnabled;
    configuration->_networkConfig = [_networkConfig copy];
    configuration->_useProtobuf = _useProtobuf;
    configuration->_dataValidityPeriod = _dataValidityPeriod;
    configuration->_customEventWithPath = _customEventWithPath;
    configuration->_sceneDelegateClass = _sceneDelegateClass;

    // Ads
    configuration->_ASAEnabled = _ASAEnabled;
    configuration->_deepLinkHost = [_deepLinkHost copy];
    configuration->_deepLinkCallback = [_deepLinkCallback copy];
    configuration->_readClipboardEnabled = _readClipboardEnabled;
    configuration->_CAIDFetchBlock = [_CAIDFetchBlock copy];

    // APM
    configuration->_APMConfig = [_APMConfig copy];

    // ABTesting
    configuration->_abTestingServerHost = [_abTestingServerHost copy];
    configuration->_abTestingRequestInterval = _abTestingRequestInterval;

    // ViewImpression
    configuration->_viewImpressionConfig = [_viewImpressionConfig copy];
    configuration->_viewImpressionEnabled = _viewImpressionEnabled;
    configuration->_viewImpressionCheckInterval = _viewImpressionCheckInterval;

    return configuration;
}

#pragma mark - Setter & Getter

// 旧值先转存到局部变量，ARC 会在作用域结束（已解锁）时才释放它，避免在锁内触发对象析构

- (NSString *)accountId {
    GROWING_LOCK(_routingLock);
    NSString *value = _accountId;
    GROWING_UNLOCK(_routingLock);
    return value;
}

- (NSString *)dataSourceId {
    GROWING_LOCK(_routingLock);
    NSString *value = _dataSourceId;
    GROWING_UNLOCK(_routingLock);
    return value;
}

- (void)setDataSourceId:(NSString *)dataSourceId {
    NSString *value = [dataSourceId copy];
    GROWING_LOCK(_routingLock);
    NSString *oldValue = _dataSourceId;
    _dataSourceId = value;
    GROWING_UNLOCK(_routingLock);
    (void)oldValue;
}

- (NSString *)dataCollectionServerHost {
    GROWING_LOCK(_routingLock);
    NSString *value = _dataCollectionServerHost;
    GROWING_UNLOCK(_routingLock);
    return value;
}

- (void)setDataCollectionServerHost:(NSString *)dataCollectionServerHost {
    NSString *value = [dataCollectionServerHost copy];
    GROWING_LOCK(_routingLock);
    NSString *oldValue = _dataCollectionServerHost;
    _dataCollectionServerHost = value;
    GROWING_UNLOCK(_routingLock);
    (void)oldValue;
}

- (NSArray<GrowingDataSourceRoute *> *)dataSourceRoutes {
    GROWING_LOCK(_routingLock);
    NSArray<GrowingDataSourceRoute *> *value = _dataSourceRoutes;
    GROWING_UNLOCK(_routingLock);
    return value;
}

- (void)setDataSourceRoutes:(NSArray<GrowingDataSourceRoute *> *)dataSourceRoutes {
    NSArray<GrowingDataSourceRoute *> *value = [dataSourceRoutes copy];
    GROWING_LOCK(_routingLock);
    NSArray<GrowingDataSourceRoute *> *oldValue = _dataSourceRoutes;
    _dataSourceRoutes = value;
    GROWING_UNLOCK(_routingLock);
    (void)oldValue;
}

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

- (void)setViewImpressionCheckInterval:(NSTimeInterval)viewImpressionCheckInterval {
    if (viewImpressionCheckInterval < 0) {
        return;
    }
    _viewImpressionCheckInterval = viewImpressionCheckInterval;
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

@implementation GrowingTrackConfiguration (Private)

- (GrowingDataSourceRoute *)routeForDataSourceId:(NSString *)dataSourceId {
    if (dataSourceId.length == 0) {
        return nil;
    }
    GrowingDataSourceRoute *found = nil;
    GROWING_LOCK(_routingLock);
    // 路由数量很少，线性查找即可，且只维护一份路由数据
    for (GrowingDataSourceRoute *route in _dataSourceRoutes) {
        if ([route.dataSourceId isEqualToString:dataSourceId]) {
            found = route;
            break;
        }
    }
    GROWING_UNLOCK(_routingLock);
    return found;
}

- (void)activateRoute:(GrowingDataSourceRoute *)route withRoutes:(NSArray<GrowingDataSourceRoute *> *)routes {
    NSArray<GrowingDataSourceRoute *> *newRoutes = [routes copy];
    NSString *accountId = [route.accountId copy];
    NSString *dataSourceId = [route.dataSourceId copy];
    NSString *serverHost = [route.dataCollectionServerHost copy];
    GROWING_LOCK(_routingLock);
    NSArray<GrowingDataSourceRoute *> *oldRoutes = _dataSourceRoutes;
    NSString *oldAccountId = _accountId;
    NSString *oldDataSourceId = _dataSourceId;
    NSString *oldServerHost = _dataCollectionServerHost;
    _dataSourceRoutes = newRoutes;
    _accountId = accountId;
    _dataSourceId = dataSourceId;
    _dataCollectionServerHost = serverHost;
    GROWING_UNLOCK(_routingLock);
    (void)oldRoutes;
    (void)oldAccountId;
    (void)oldDataSourceId;
    (void)oldServerHost;
}

@end
