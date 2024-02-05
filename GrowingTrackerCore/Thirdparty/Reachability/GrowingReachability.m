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

#if !Growing_OS_WATCH
static void ReachabilityCallback(SCNetworkReachabilityRef target,
                                 SCNetworkReachabilityFlags flags,
                                 void *info);
#endif

@interface GrowingReachability ()

@property (nonatomic, assign, readwrite) GrowingNetworkReachabilityStatus reachabilityStatus;
#if !Growing_OS_WATCH
@property (nonatomic, assign) SCNetworkReachabilityRef reachabilityRef;
#endif

@end

@implementation GrowingReachability

- (instancetype)initWithAddress:(const struct sockaddr *)hostAddress {
    if (self = [super init]) {
        _reachabilityStatus = GrowingNetworkReachabilityUndetermined;
#if !Growing_OS_WATCH
        SCNetworkReachabilityRef reachability = SCNetworkReachabilityCreateWithAddress(kCFAllocatorDefault,
                                                                                       hostAddress);
        if (reachability) {
            _reachabilityRef = reachability;
            SCNetworkReachabilityFlags flags = 0;
            if (SCNetworkReachabilityGetFlags(reachability, &flags)) {
                _reachabilityStatus = [self reachabilityStatusForFlags:flags];
            }
        }
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
#if Growing_OS_WATCH
    return NO;
#else
    if (!_reachabilityRef) {
        return NO;
    }
 	SCNetworkReachabilityContext context = {
        0,
        (__bridge void *)(self),
        NULL,
        NULL,
        NULL};
	if (!SCNetworkReachabilitySetCallback(_reachabilityRef,
                                         ReachabilityCallback,
                                         &context)) {
        return NO;
	}
    if (!SCNetworkReachabilityScheduleWithRunLoop(_reachabilityRef,
                                                 CFRunLoopGetCurrent(),
                                                 kCFRunLoopDefaultMode)) {
        return NO;
    }
	return YES;
#endif
}

- (void)stopNotifier {
#if !Growing_OS_WATCH
    if (!_reachabilityRef) {
        return;
    }
    SCNetworkReachabilityUnscheduleFromRunLoop(_reachabilityRef,
                                               CFRunLoopGetCurrent(),
                                               kCFRunLoopDefaultMode);
    _reachabilityStatus = GrowingNetworkReachabilityUndetermined;
#endif
}

- (void)dealloc {
#if !Growing_OS_WATCH
	[self stopNotifier];
	if (_reachabilityRef) {
		CFRelease(_reachabilityRef);
        _reachabilityRef = nil;
	}
#endif
}

#pragma mark - Network Flag Handling

#if !Growing_OS_WATCH
- (GrowingNetworkReachabilityStatus)reachabilityStatusForFlags:(SCNetworkReachabilityFlags)flags {
	if ((flags & kSCNetworkReachabilityFlagsReachable) == 0) {
		// The target host is not reachable.
        return GrowingNetworkReachabilityNotReachable;
	}

    GrowingNetworkReachabilityStatus returnValue = GrowingNetworkReachabilityNotReachable;
	if ((flags & kSCNetworkReachabilityFlagsConnectionRequired) == 0) {
		// If the target host is reachable and no connection is required then we'll assume (for now) that you're on Wi-Fi...
		returnValue = GrowingNetworkReachabilityReachableViaWiFi;
	}

	if ((((flags & kSCNetworkReachabilityFlagsConnectionOnDemand ) != 0) ||
        (flags & kSCNetworkReachabilityFlagsConnectionOnTraffic) != 0)) {
        //and the connection is on-demand (or on-traffic) if the calling application is using the CFSocketStream or higher APIs...
        if ((flags & kSCNetworkReachabilityFlagsInterventionRequired) == 0) {
            // and no [user] intervention is needed...
            returnValue = GrowingNetworkReachabilityReachableViaWiFi;
        }
    }

#if Growing_OS_IOS || Growing_OS_TV
    if (returnValue == GrowingNetworkReachabilityReachableViaWiFi) {
        // is reachable...
        if ((flags & kSCNetworkReachabilityFlagsIsWWAN) != 0) {
            // but WWAN connections are OK if the calling application is using the CFNetwork APIs.
            returnValue = GrowingNetworkReachabilityReachableViaWWAN;
        }
    }
#endif
    
	return returnValue;
}

- (void)reachabilityFlagsChanged:(SCNetworkReachabilityFlags)flags {
    GrowingNetworkReachabilityStatus status = [self reachabilityStatusForFlags:flags];
    if (_reachabilityStatus != status) {
        _reachabilityStatus = status;
    }
}
#endif

@end

#if !Growing_OS_WATCH
static void ReachabilityCallback(SCNetworkReachabilityRef target,
                                 SCNetworkReachabilityFlags flags,
                                 void *info) {
    GrowingReachability *reachability = (__bridge GrowingReachability *)info;
    [reachability reachabilityFlagsChanged:flags];
}
#endif
