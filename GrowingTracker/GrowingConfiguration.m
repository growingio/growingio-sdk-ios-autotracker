//
// Created by xiangyang on 2020/11/6.
//

#import "GrowingConfiguration.h"


@implementation GrowingConfiguration
- (instancetype)initWithProjectId:(NSString *)projectId launchOptions:(NSDictionary *)launchOptions {
    self = [super initWithProjectId:projectId launchOptions:launchOptions];
    if (self) {

    }

    return self;
}

+ (instancetype)configurationWithProjectId:(NSString *)projectId launchOptions:(NSDictionary *)launchOptions {
    return [self configurationWithProjectId:projectId launchOptions:launchOptions];
}


@end