//
// Created by xiangyang on 2020/11/10.
//

#import <Foundation/Foundation.h>

@class GrowingTrackConfiguration;

FOUNDATION_EXPORT NSString *const GrowingTrackerVersionName;
FOUNDATION_EXPORT const int GrowingTrackerVersionCode;

@interface GrowingRealTracker : NSObject
- (instancetype)initWithConfiguration:(GrowingTrackConfiguration *)configuration launchOptions:(NSDictionary *)launchOptions;

+ (instancetype)trackerWithConfiguration:(GrowingTrackConfiguration *)configuration launchOptions:(NSDictionary *)launchOptions;

- (void)trackCustomEvent:(NSString *)eventName;

- (void)trackCustomEvent:(NSString *)eventName withAttributes:(NSDictionary <NSString *, NSString *> *)attributes;

- (void)setLoginUserAttributes:(NSDictionary<NSString *, NSString *> *)attributes;

- (void)setVisitorAttributes:(NSDictionary<NSString *, NSString *> *)attributes;

- (void)setConversionVariables:(NSDictionary <NSString *, NSString *> *)variables;

- (void)setLoginUserId:(NSString *)userId;

- (void)cleanLoginUserId;

- (void)setDataCollectionEnabled:(BOOL)enabled;

- (NSString *)getDeviceId;

@end