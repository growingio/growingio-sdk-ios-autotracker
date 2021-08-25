//
// Created by xiangyang on 2020/11/6.
//

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
    return configuration;
}

- (void)setDataCollectionEnabled:(BOOL)dataCollectionEnabled {
    if (dataCollectionEnabled == _dataCollectionEnabled) {
        return;
    }
    _dataCollectionEnabled = dataCollectionEnabled;
    if (dataCollectionEnabled) {
        [[GrowingSession currentSession] forceReissueVisit];
    }
}

@end
