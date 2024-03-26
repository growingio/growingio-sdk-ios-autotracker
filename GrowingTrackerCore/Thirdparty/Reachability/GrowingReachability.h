/*
 Copyright (C) 2016 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 Basic demonstration of how to use the SystemConfiguration Reachablity APIs.
 */

#import "GrowingTargetConditionals.h"
#import "GrowingTrackerCore/Network/GrowingNetworkInterfaceManager.h"
#if !Growing_OS_WATCH
#import <SystemConfiguration/SystemConfiguration.h>
#endif

@interface GrowingReachability : NSObject

@property (nonatomic, assign, readonly) GrowingNetworkReachabilityStatus reachabilityStatus;

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


