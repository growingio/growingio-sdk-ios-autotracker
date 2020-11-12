//
// Created by xiangyang on 2020/11/6.
//

#import "GrowingTrackConfiguration.h"


@implementation GrowingTrackConfiguration
- (instancetype)initWithProjectId:(NSString *)projectId {
    self = [super initWithProjectId:projectId];
    if (self) {

    }

    return self;
}

+ (instancetype)configurationWithProjectId:(NSString *)projectId {
    return [[self alloc] initWithProjectId:projectId];
}


@end