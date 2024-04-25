//
//  GrowingNetworkPreflight.m
//  GrowingAnalytics
//
//  Created by YoloMao on 2024/4/24.
//  Copyright (C) 2024 Beijing Yishu Technology Co., Ltd.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.

#import "GrowingTrackerCore/Network/GrowingNetworkPreflight.h"
#import "GrowingTrackerCore/Manager/GrowingConfigurationManager.h"
#import "GrowingTrackerCore/Network/Request/GrowingPreflightRequest.h"
#import "GrowingTrackerCore/Public/GrowingEventNetworkService.h"
#import "GrowingTrackerCore/Thirdparty/Logger/GrowingLogger.h"
#import "GrowingTrackerCore/Thread/GrowingDispatchManager.h"

typedef NS_ENUM(NSUInteger, GrowingNetworkPreflightStatus) {
    GrowingNWPreflightStatusNotDetermined,
    GrowingNWPreflightStatusAuthorized,
    GrowingNWPreflightStatusDenied,
    GrowingNWPreflightStatusWaitingForResponse,
};

static NSTimeInterval const kGrowingPreflightMaxTime = 300;

@interface GrowingNetworkPreflight ()

@property (nonatomic, assign) GrowingNetworkPreflightStatus status;
@property (nonatomic, assign) NSTimeInterval nextPreflightTime;

@end

@implementation GrowingNetworkPreflight

#pragma mark - Initialize

+ (instancetype)sharedInstance {
    static id instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

#pragma mark - Public Methods

+ (BOOL)isSucceed {
    BOOL requestPreflight = GrowingConfigurationManager.sharedInstance.trackConfiguration.requestPreflight;
    if (!requestPreflight) {
        return YES;
    }
    GrowingNetworkPreflight *preflight = [GrowingNetworkPreflight sharedInstance];
    return preflight.status == GrowingNWPreflightStatusAuthorized;
}

+ (void)sendPreflight {
    [GrowingDispatchManager dispatchInGrowingThread:^{
        GrowingTrackConfiguration *trackConfiguration = GrowingConfigurationManager.sharedInstance.trackConfiguration;
        BOOL requestPreflight = trackConfiguration.requestPreflight;
        if (!requestPreflight) {
            return;
        }

        NSTimeInterval dataUploadInterval = trackConfiguration.dataUploadInterval;
        dataUploadInterval = MAX(dataUploadInterval, 5);

        GrowingNetworkPreflight *preflight = [GrowingNetworkPreflight sharedInstance];
        preflight.nextPreflightTime = dataUploadInterval;
        if (preflight.status != GrowingNWPreflightStatusWaitingForResponse) {
            [preflight sendPreflight];
        }
    }];
}

#pragma mark - Private Methods

- (void)sendPreflight {
    self.status = GrowingNWPreflightStatusWaitingForResponse;

    id<GrowingEventNetworkService> service =
        [[GrowingServiceManager sharedInstance] createService:@protocol(GrowingEventNetworkService)];
    if (!service) {
        return;
    }

    NSObject<GrowingRequestProtocol> *preflight = [[GrowingPreflightRequest alloc] init];
    [service
        sendRequest:preflight
         completion:^(NSHTTPURLResponse *_Nonnull httpResponse, NSData *_Nonnull data, NSError *_Nonnull error) {
             [GrowingDispatchManager dispatchInGrowingThread:^{
                 if (httpResponse.statusCode >= 200 && httpResponse.statusCode < 400) {
                     self.status = GrowingNWPreflightStatusAuthorized;
                 } else {
                     self.status = GrowingNWPreflightStatusDenied;

                     dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.nextPreflightTime * NSEC_PER_SEC)),
                                    dispatch_get_main_queue(),
                                    ^{
                                        [GrowingDispatchManager dispatchInGrowingThread:^{
                                            [self sendPreflight];
                                        }];
                                    });

                     self.nextPreflightTime = MIN(self.nextPreflightTime * 2, kGrowingPreflightMaxTime);
                 }
             }];
         }];
}

@end
