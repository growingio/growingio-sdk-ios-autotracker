//
// Created by xiangyang on 2020/11/6.
//

#import "GrowingTrackConfiguration.h"

NSString * const kGrowingDefaultDataCollectionServerHost = @"https://api.growingio.com";

@interface GrowingTrackConfiguration ()
@property(nonatomic, copy, readwrite) NSString *projectId;
@end

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
        _filterEventMask = 0;
        _ignoreFieldsMask = 0;
    }

    return self;
}

+ (instancetype)configurationWithProjectId:(NSString *)projectId {
    return [[self alloc] initWithProjectId:projectId];
}

- (id)copyWithZone:(NSZone *)zone {
    GrowingTrackConfiguration *configuration = [[[self class] alloc] init];
    configuration.projectId = [_projectId copy];
    configuration.debugEnabled = _debugEnabled;
    configuration.cellularDataLimit = _cellularDataLimit;
    configuration.dataUploadInterval = _dataUploadInterval;
    configuration.sessionInterval = _sessionInterval;
    configuration.dataCollectionEnabled = _dataCollectionEnabled;
    configuration.uploadExceptionEnable = _uploadExceptionEnable;
    configuration.dataCollectionServerHost = [_dataCollectionServerHost copy];
    configuration.filterEventMask = _filterEventMask;
    configuration.ignoreFieldsMask = _ignoreFieldsMask;
    return configuration;
}


@end
