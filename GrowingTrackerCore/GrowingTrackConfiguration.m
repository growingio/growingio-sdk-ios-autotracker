//
// Created by xiangyang on 2020/11/6.
//

#import "GrowingTrackConfiguration.h"

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
        _dataCollectionServerHost = @"https://run.mocky.io/v3/3afa0819-d7b9-4ff7-8d36-65d6653803c8";
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
    return configuration;
}


@end
