/*
 Copyright (C) 2016 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 Basic demonstration of how to use the SystemConfiguration Reachablity APIs.
 */

/*
 GrowingIO comment:
 1. This file (and .h file) is downloaded from https://developer.apple.com/library/ios/samplecode/Reachability/Introduction/Intro.html
 2. This implementation fully supports IPv6. See https://developer.apple.com/library/ios/samplecode/Reachability/Listings/ReadMe_md.html
 3. Prefix: Reachability -> GrowingReachability
 4. Prefix: NetworkStatus -> GrowingNetworkStatus
 5. remove: kReachabilityChangedNotification, PrintReachabilityFlags and others codes that unused in this project.
 6. add: watchOS/tvOS/visionOS support.
 */

#import "GrowingTrackerCore/Thirdparty/Reachability/GrowingReachability.h"
#import <netinet/in.h>

#if !TARGET_OS_WATCH
static void ReachabilityCallback(SCNetworkReachabilityRef target,
                                 SCNetworkReachabilityFlags flags,
                                 void *info);
#endif

@interface GrowingReachability ()

@property (nonatomic, assign, readwrite) GrowingNetworkStatus networkStatus;
#if !TARGET_OS_WATCH
@property (nonatomic, assign) SCNetworkReachabilityRef reachabilityRef;
#endif

@end

@implementation GrowingReachability

- (instancetype)initWithAddress:(const struct sockaddr *)hostAddress {
    if (self = [super init]) {
        _networkStatus = GrowingReachabilityUnknown;
#if !TARGET_OS_WATCH
        SCNetworkReachabilityRef reachability = SCNetworkReachabilityCreateWithAddress(kCFAllocatorDefault,
                                                                                       hostAddress);
        _reachabilityRef = reachability;
#endif
    }
    return self;
}

+ (instancetype)reachabilityForInternetConnection {
	struct sockaddr_in zeroAddress;
	bzero(&zeroAddress, sizeof(zeroAddress));
	zeroAddress.sin_len = sizeof(zeroAddress);
	zeroAddress.sin_family = AF_INET;
    
    return [[self alloc] initWithAddress:(const struct sockaddr *)&zeroAddress];
}

#pragma mark - Start and stop notifier

- (BOOL)startNotifier {
#if TARGET_OS_WATCH
  return NO;
#else
	BOOL returnValue = NO;
	SCNetworkReachabilityContext context = {0, (__bridge void *)(self), NULL, NULL, NULL};
	if (SCNetworkReachabilitySetCallback(_reachabilityRef,
                                         ReachabilityCallback,
                                         &context)) {
		if (SCNetworkReachabilityScheduleWithRunLoop(_reachabilityRef,
                                                     CFRunLoopGetCurrent(),
                                                     kCFRunLoopDefaultMode)) {
			returnValue = YES;
		}
	}
	return returnValue;
#endif
}

- (void)stopNotifier {
#if !TARGET_OS_WATCH
	if (_reachabilityRef != NULL) {
		SCNetworkReachabilityUnscheduleFromRunLoop(_reachabilityRef,
                                                   CFRunLoopGetCurrent(),
                                                   kCFRunLoopDefaultMode);
	}
    _networkStatus = GrowingReachabilityUnknown;
#endif
}

- (void)dealloc {
	[self stopNotifier];
	if (_reachabilityRef != NULL) {
		CFRelease(_reachabilityRef);
        _reachabilityRef = nil;
	}
}

#pragma mark - Network Flag Handling

#if !TARGET_OS_WATCH
- (GrowingNetworkStatus)networkStatusForFlags:(SCNetworkReachabilityFlags)flags {
	if ((flags & kSCNetworkReachabilityFlagsReachable) == 0) {
		// The target host is not reachable.
        return GrowingReachabilityNotReachable;
	}

    GrowingNetworkStatus returnValue = GrowingReachabilityNotReachable;
	if ((flags & kSCNetworkReachabilityFlagsConnectionRequired) == 0) {
		// If the target host is reachable and no connection is required then we'll assume (for now) that you're on Wi-Fi...
		returnValue = GrowingReachabilityViaWiFi;
	}

	if ((((flags & kSCNetworkReachabilityFlagsConnectionOnDemand ) != 0) ||
        (flags & kSCNetworkReachabilityFlagsConnectionOnTraffic) != 0)) {
        //and the connection is on-demand (or on-traffic) if the calling application is using the CFSocketStream or higher APIs...
        if ((flags & kSCNetworkReachabilityFlagsInterventionRequired) == 0) {
            // and no [user] intervention is needed...
            returnValue = GrowingReachabilityViaWiFi;
        }
    }

#if TARGET_OS_IOS || TARGET_OS_TV || (defined(TARGET_OS_VISION) && TARGET_OS_VISION)
    if (returnValue == GrowingReachabilityViaWiFi) {
        // is reachable...
        if ((flags & kSCNetworkReachabilityFlagsIsWWAN) != 0) {
            // but WWAN connections are OK if the calling application is using the CFNetwork APIs.
            returnValue = GrowingReachabilityViaWWAN;
        }
    }
#endif
    
	return returnValue;
}

- (void)reachabilityFlagsChanged:(SCNetworkReachabilityFlags)flags {
    GrowingNetworkStatus status = [self networkStatusForFlags:flags];
    if (_networkStatus != status) {
        _networkStatus = status;
    }
}
#endif

@end

#if !TARGET_OS_WATCH
static void ReachabilityCallback(SCNetworkReachabilityRef target,
                                 SCNetworkReachabilityFlags flags,
                                 void *info) {
    GrowingReachability *reachability = (__bridge GrowingReachability *)info;
    [reachability reachabilityFlagsChanged:flags];
}
#endif
