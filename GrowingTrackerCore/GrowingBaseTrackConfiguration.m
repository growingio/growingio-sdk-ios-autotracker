//
// Created by xiangyang on 2020/11/6.
//

#import "GrowingBaseTrackConfiguration.h"

@interface GrowingBaseTrackConfiguration ()
@property(nonatomic, copy, readwrite) NSString *projectId;
@end

@implementation GrowingBaseTrackConfiguration
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
        _dataCollectionServerHost = @"https://api.growingio.com";
    }

    return self;
}

+ (instancetype)configurationWithProjectId:(NSString *)projectId {
    return [[self alloc] initWithProjectId:projectId];
}

- (id)copyWithZone:(NSZone *)zone {
    GrowingBaseTrackConfiguration *configuration = [[[self class] alloc] init];
    configuration.projectId = [_projectId copy];
    configuration.debugEnabled = _debugEnabled;
    configuration.cellularDataLimit = _cellularDataLimit;
    configuration.dataUploadInterval = _dataUploadInterval;
    configuration.sessionInterval = _sessionInterval;
    configuration.dataCollectionEnabled = _dataCollectionEnabled;
    configuration.uploadExceptionEnable = _uploadExceptionEnable;
    configuration.dataCollectionServerHost = [_dataCollectionServerHost copy];
    return configuration;
}


@end