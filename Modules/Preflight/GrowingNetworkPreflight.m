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

#import "GrowingTrackerCore/Event/GrowingEventManager.h"
#import "GrowingTrackerCore/Manager/GrowingConfigurationManager.h"
#import "GrowingTrackerCore/Network/Request/Adapter/GrowingEventRequestAdapters.h"
#import "GrowingTrackerCore/Public/GrowingEventNetworkService.h"
#import "GrowingTrackerCore/Thirdparty/Logger/GrowingLogger.h"
#import "GrowingTrackerCore/Thread/GrowingDispatchManager.h"
#import "Modules/Preflight/GrowingNetworkPreflight+Private.h"
#import "Modules/Preflight/Request/GrowingPFEventRequestAdapter.h"
#import "Modules/Preflight/Request/GrowingPFRequest.h"

GrowingMod(GrowingNetworkPreflight)

typedef NS_ENUM(NSUInteger, GrowingNetworkPreflightStatus) {
    GrowingNWPreflightStatusNotDetermined,       // 待预检
    GrowingNWPreflightStatusWaitingForResponse,  // 预检中
    GrowingNWPreflightStatusAuthorized,          // 预检成功
    GrowingNWPreflightStatusDenied,              // 预检失败
    GrowingNWPreflightStatusClosed,              // 预检关闭
};

static NSTimeInterval const kGrowingPreflightMaxTime = 300;

@interface GrowingNetworkPreflight () <GrowingEventInterceptor>

@property (nonatomic, assign) GrowingNetworkPreflightStatus status;
@property (nonatomic, assign) NSTimeInterval nextPreflightTime;

@property (nonatomic, assign) NSTimeInterval minPreflightTime;
@property (nonatomic, copy) NSString *dataCollectionServerHost;

@end

@implementation GrowingNetworkPreflight

#pragma mark - GrowingModuleProtocol

+ (BOOL)singleton {
    return YES;
}

+ (instancetype)sharedInstance {
    static id instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (void)growingModInit:(GrowingContext *)context {
    [[GrowingEventManager sharedInstance] addInterceptor:self];

    [GrowingEventRequestAdapters.sharedInstance addAdapter:GrowingPFEventRequestAdapter.class];

    GrowingTrackConfiguration *trackConfiguration = GrowingConfigurationManager.sharedInstance.trackConfiguration;
    NSString *dataCollectionServerHost = trackConfiguration.dataCollectionServerHost;
    self.dataCollectionServerHost = dataCollectionServerHost;
    if (![dataCollectionServerHost isEqualToString:kGrowingDefaultDataCollectionServerHost]) {
        // 私有部署
        BOOL requestPreflight = trackConfiguration.requestPreflight;
        if (!requestPreflight) {
            // 预检功能关闭
            self.status = GrowingNWPreflightStatusClosed;
        }
    }

    NSTimeInterval dataUploadInterval = trackConfiguration.dataUploadInterval;
    dataUploadInterval = MAX(dataUploadInterval, 5);
    self.minPreflightTime = dataUploadInterval;
    self.nextPreflightTime = dataUploadInterval;

    [GrowingNetworkPreflight sendPreflight];
}

- (void)growingModRefreshSession:(GrowingContext *)context {
    [GrowingNetworkPreflight sendPreflight];
}

- (void)growingModSetDataCollectionEnabled:(GrowingContext *)context {
    [GrowingNetworkPreflight sendPreflightIfNeeded];
}

#pragma mark - GrowingEventInterceptor

- (BOOL)growingEventManagerEventShouldBeginSending:(GrowingEventChannel *)channel {
    return [GrowingNetworkPreflight isSucceed];
}

- (void)growingEventManagerEventsSendingCompletion:(NSArray<id<GrowingEventPersistenceProtocol>> *)events
                                           request:(id<GrowingRequestProtocol>)request
                                           channel:(GrowingEventChannel *)channel
                                      httpResponse:(NSHTTPURLResponse *)httpResponse
                                             error:(NSError *)error {
    if (httpResponse.statusCode == 403) {
        [GrowingNetworkPreflight sendPreflight];
    }
}

#pragma mark - Public Methods

+ (NSString *)dataCollectionServerHost {
    // call when preflight isSucceed
    GrowingNetworkPreflight *preflight = [GrowingNetworkPreflight sharedInstance];
    return preflight.dataCollectionServerHost;
}

#pragma mark - Private Methods

+ (BOOL)isSucceed {
    GrowingNetworkPreflight *preflight = [GrowingNetworkPreflight sharedInstance];
    return preflight.status > GrowingNWPreflightStatusWaitingForResponse;
}

+ (void)sendPreflight {
    [GrowingDispatchManager dispatchInGrowingThread:^{
        GrowingTrackConfiguration *trackConfiguration = GrowingConfigurationManager.sharedInstance.trackConfiguration;
        GrowingNetworkPreflight *preflight = [GrowingNetworkPreflight sharedInstance];
        preflight.nextPreflightTime = preflight.minPreflightTime;
        preflight.dataCollectionServerHost = trackConfiguration.dataCollectionServerHost;
        if (preflight.status == GrowingNWPreflightStatusNotDetermined ||
            preflight.status == GrowingNWPreflightStatusAuthorized ||
            preflight.status == GrowingNWPreflightStatusDenied) {
            if (!trackConfiguration.dataCollectionEnabled) {
                preflight.status = GrowingNWPreflightStatusNotDetermined;
                return;
            }
            [preflight sendPreflight];
        }
    }];
}

+ (void)sendPreflightIfNeeded {
    GrowingNetworkPreflight *preflight = [GrowingNetworkPreflight sharedInstance];
    [preflight sendPreflightIfNeeded];
}

- (void)sendPreflight {
    self.status = GrowingNWPreflightStatusWaitingForResponse;

    id<GrowingEventNetworkService> service =
        [[GrowingServiceManager sharedInstance] createService:@protocol(GrowingEventNetworkService)];
    if (!service) {
        return;
    }

    NSObject<GrowingRequestProtocol> *preflight = [[GrowingPFRequest alloc] init];
    [service
        sendRequest:preflight
         completion:^(NSHTTPURLResponse *_Nonnull httpResponse, NSData *_Nonnull data, NSError *_Nonnull error) {
             [GrowingDispatchManager dispatchInGrowingThread:^{
                 if (httpResponse.statusCode >= 200 && httpResponse.statusCode < 400) {
                     self.status = GrowingNWPreflightStatusAuthorized;
                 } else if (httpResponse.statusCode == 403) {
                     self.status = GrowingNWPreflightStatusDenied;
                     GrowingTrackConfiguration *trackConfiguration =
                         GrowingConfigurationManager.sharedInstance.trackConfiguration;
                     self.dataCollectionServerHost = trackConfiguration.alternateDataCollectionServerHost;
                 } else {
                     self.status = GrowingNWPreflightStatusNotDetermined;
                     dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.nextPreflightTime * NSEC_PER_SEC)),
                                    dispatch_get_main_queue(),
                                    ^{
                                        [GrowingDispatchManager dispatchInGrowingThread:^{
                                            [self sendPreflightIfNeeded];
                                        }];
                                    });

                     self.nextPreflightTime = MIN(self.nextPreflightTime * 2, kGrowingPreflightMaxTime);
                 }
             }];
         }];
}

- (void)sendPreflightIfNeeded {
    if (self.status == GrowingNWPreflightStatusNotDetermined) {
        [self sendPreflight];
    }
}

@end
