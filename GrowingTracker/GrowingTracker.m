//
// Created by xiangyang on 2020/11/6.
//

#import "GrowingTracker.h"
#import "GrowingTrackConfiguration.h"
#import "GrowingTrackConfiguration.h"
#import "GrowingRealTracker.h"
#import "GrowingLogMacros.h"
#import "GrowingCocoaLumberjack.h"

static GrowingTracker *sharedInstance = nil;

@interface GrowingTracker ()
@property(nonatomic, strong, readonly) GrowingRealTracker *realTracker;
@end

@implementation GrowingTracker
- (instancetype)initWithRealTracker:(GrowingRealTracker *)realTracker {
    self = [super init];
    if (self) {
        _realTracker = realTracker;
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

//- (void)trackCustomEvent:(NSString *)eventName {
//    [_realTracker trackCustomEvent:eventName];
//}
//
//- (void)trackCustomEvent:(NSString *)eventName withAttributes:(NSDictionary<NSString *, NSString *> *)attributes {
//    [_realTracker trackCustomEvent:eventName withAttributes:attributes];
//}
//
//- (void)setLoginUserAttributes:(NSDictionary<NSString *, NSString *> *)attributes {
//    [_realTracker setLoginUserAttributes:attributes];
//}
//
//- (void)setVisitorAttributes:(NSDictionary<NSString *, NSString *> *)attributes {
//    [_realTracker setVisitorAttributes:attributes];
//}
//
//- (void)setConversionVariables:(NSDictionary<NSString *, NSString *> *)variables {
//    [_realTracker setConversionVariables:variables];
//}
//
//- (void)setLoginUserId:(NSString *)userId {
//    [_realTracker setLoginUserId:userId];
//}
//
//- (void)cleanLoginUserId {
//    [_realTracker cleanLoginUserId];
//}
//
//- (void)setDataCollectionEnabled:(BOOL)enabled {
//    [_realTracker setDataCollectionEnabled:enabled];
//}
//
//- (NSString *)getDeviceId {
//    return [_realTracker getDeviceId];
//}
//
///// 设置经纬度坐标
///// @param latitude 纬度
///// @param longitude 经度
//- (void)setLocation:(double)latitude longitude:(double)longitude {
//    [_realTracker setLocation:latitude longitude:longitude];
//}
//
///// 清除地理位置
//- (void)cleanLocation {
//    [_realTracker cleanLocation];
//}

#pragma mark - proxy protocol

- (id)forwardingTargetForSelector:(SEL)selector {
    return _realTracker;
}

- (void)forwardInvocation:(NSInvocation *)invocation {
    if (![_realTracker respondsToSelector:[invocation selector]]) {
        GIOLogError(@"GrowingTracker can't find method name %@",NSStringFromSelector([invocation selector]));
    }
    void *null = NULL;
    [invocation setReturnValue:&null];
}

@end
