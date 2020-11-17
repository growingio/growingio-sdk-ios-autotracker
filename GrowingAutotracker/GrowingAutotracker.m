//
// Created by xiangyang on 2020/11/6.
//

#import "GrowingAutotracker.h"

static GrowingAutotracker *sharedInstance = nil;

@interface GrowingAutotracker ()
@property(nonatomic, strong, readonly) GrowingRealAutotracker *realAutotracker;
@end

@implementation GrowingAutotracker
- (instancetype)initWithRealAutotracker:(GrowingRealAutotracker *)realAutotracker {
    self = [super init];
    if (self) {
        _realAutotracker = realAutotracker;
    }

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
        GrowingRealAutotracker *autotracker = [GrowingRealAutotracker trackerWithConfiguration:configuration launchOptions:launchOptions];
        sharedInstance = [[self alloc] initWithRealAutotracker:autotracker];
    });
}

+ (instancetype)sharedInstance {
    if (!sharedInstance) {
        @throw [NSException exceptionWithName:@"GrowingAutotracker未初始化" reason:@"请在applicationDidFinishLaunching中调用startWithConfiguration函数,并且确保在主线程中" userInfo:nil];
    }
    return sharedInstance;
}

- (void)trackCustomEvent:(NSString *)eventName {
    [_realAutotracker trackCustomEvent:eventName];
}

- (void)trackCustomEvent:(NSString *)eventName withAttributes:(NSDictionary<NSString *, NSString *> *)attributes {
    [_realAutotracker trackCustomEvent:eventName withAttributes:attributes];
}

- (void)setLoginUserAttributes:(NSDictionary<NSString *, NSString *> *)attributes {
    [_realAutotracker setLoginUserAttributes:attributes];
}

- (void)setVisitorAttributes:(NSDictionary<NSString *, NSString *> *)attributes {
    [_realAutotracker setVisitorAttributes:attributes];
}

- (void)setConversionVariables:(NSDictionary<NSString *, NSString *> *)variables {
    [_realAutotracker setConversionVariables:variables];
}

- (void)setLoginUserId:(NSString *)userId {
    [_realAutotracker setLoginUserId:userId];
}

- (void)cleanLoginUserId {
    [_realAutotracker cleanLoginUserId];
}

- (void)setDataCollectionEnabled:(BOOL)enabled {
    [_realAutotracker setDataCollectionEnabled:enabled];
}

- (NSString *)getDeviceId {
    return [_realAutotracker getDeviceId];
}


@end
