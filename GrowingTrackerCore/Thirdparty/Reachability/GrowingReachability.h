/*
 Copyright (C) 2016 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 Basic demonstration of how to use the SystemConfiguration Reachablity APIs.
 */

#import <Foundation/Foundation.h>
#if !TARGET_OS_WATCH
#import <SystemConfiguration/SystemConfiguration.h>
#endif

typedef enum : NSInteger {
    GrowingReachabilityUnknown = 0,
	GrowingReachabilityNotReachable,
	GrowingReachabilityViaWiFi,
	GrowingReachabilityViaWWAN,
} GrowingNetworkStatus;

@interface GrowingReachability : NSObject

@property (nonatomic, assign, readonly) GrowingNetworkStatus networkStatus;

/*!
 * Checks whether the default route is available. Should be used by applications that do not connect to a particular host.
 */
+ (instancetype)reachabilityForInternetConnection;

/*!
 * Start listening for reachability notifications on the current run loop.
 */
- (BOOL)startNotifier;
- (void)stopNotifier;

@end


