//
// Created by xiangyang on 2020/11/6.
//

#import "GrowingTracker.h"
#import "GrowingTrackConfiguration.h"
#import "GrowingTrackConfiguration.h"
#import "GrowingRealTracker.h"
#import "GrowingLogMacros.h"
#import "GrowingLogger.h"

static GrowingTracker *sharedInstance = nil;

@implementation GrowingTracker
- (instancetype)initWithRealTracker:(GrowingRealTracker *)realTracker {
    self = [super initWithTarget:realTracker];
    return self;
}

+ (void)startWithConfiguration:(GrowingTrackConfiguration *)configuration launchOptions:(NSDictionary *)launchOptions {
    if (![NSThread isMainThread]) {
        @throw [NSException exceptionWithName:@"初始化异常" reason:@"请在applicationDidFinishLaunching中调用startWithConfiguration函数,并且确保在主线程中" userInfo:nil];
    }

    if (!configuration.projectId.length) {
        @throw [NSException exceptionWithName:@"初始化异常" reason:@"ProjectId不能为空" userInfo:nil];
    }

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        GrowingRealTracker *realTracker = [GrowingRealTracker trackerWithConfiguration:configuration launchOptions:launchOptions];
        sharedInstance = [[self alloc] initWithRealTracker:realTracker];
    });
}

+ (instancetype)sharedInstance {
    if (!sharedInstance) {
        @throw [NSException exceptionWithName:@"GrowingTracker未初始化" reason:@"请在applicationDidFinishLaunching中调用startWithConfiguration函数,并且确保在主线程中" userInfo:nil];
    }
    return sharedInstance;
}

@end
