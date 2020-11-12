//
// Created by xiangyang on 2020/11/6.
//

#import <Foundation/Foundation.h>

@class GrowingTrackConfiguration;
@class GrowingRealTracker;


@interface GrowingTracker : NSObject
+ (void)startWithConfiguration:(GrowingTrackConfiguration *)configuration launchOptions:(NSDictionary *)launchOptions;

+ (instancetype)sharedInstance;

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