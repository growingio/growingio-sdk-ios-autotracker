//
//  GrowingABTRequest.m
//  GrowingAnalytics
//
//  Created by YoloMao on 2023/10/10.
//  Copyright (C) 2023 Beijing Yishu Technology Co., Ltd.
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

#import "Modules/ABTesting/Request/GrowingABTRequest.h"
#import "Modules/ABTesting/Public/GrowingABTesting.h"
#import "Modules/ABTesting/Request/GrowingABTRequestAdapter.h"

#import "GrowingTrackerCore/Helpers/GrowingHelpers.h"
#import "GrowingTrackerCore/Manager/GrowingConfigurationManager.h"
#import "GrowingTrackerCore/Manager/GrowingSession.h"
#import "GrowingTrackerCore/Network/Request/Adapter/GrowingRequestAdapter.h"
#import "GrowingTrackerCore/Utils/GrowingDeviceInfo.h"
#import "GrowingULTimeUtil.h"

@interface GrowingABTRequest ()

@property (nonatomic, copy, nullable) NSString *loginUserId;
@property (nonatomic, copy, nullable) NSString *loginUserKey;
@property (nonatomic, copy, readwrite) NSString *userIdentity;

@end

@implementation GrowingABTRequest

@synthesize stm;

- (instancetype)init {
    if (self = [super init]) {
        self.stm = [GrowingULTimeUtil currentTimeMillis];

        GrowingSession *session = [GrowingSession currentSession];
        self.loginUserId = session.loginUserId;
        self.loginUserKey = session.loginUserKey;
        self.userIdentity = [GrowingABTRequest identityWithDeviceId:[GrowingDeviceInfo currentDeviceInfo].deviceIDString
                                                             userId:self.loginUserId
                                                            userKey:self.loginUserKey];
    }
    return self;
}

+ (NSString *)currentIdentity {
    GrowingSession *session = [GrowingSession currentSession];
    return [self identityWithDeviceId:[GrowingDeviceInfo currentDeviceInfo].deviceIDString
                               userId:session.loginUserId
                              userKey:session.loginUserKey];
}

+ (NSString *)identityWithDeviceId:(NSString *_Nullable)deviceId
                            userId:(NSString *_Nullable)userId
                           userKey:(NSString *_Nullable)userKey {
    NSString *raw = [NSString stringWithFormat:@"%@\n%@\n%@",
                                               (deviceId ?: @"").growingHelper_sha1,
                                               (userId ?: @"").growingHelper_sha1,
                                               (userKey ?: @"").growingHelper_sha1];
    return raw.growingHelper_sha1;
}

- (GrowingHTTPMethod)method {
    return GrowingHTTPMethodPOST;
}

- (NSURL *)absoluteURL {
    NSString *baseUrl = GrowingConfigurationManager.sharedInstance.trackConfiguration.abTestingServerHost;
    if (!baseUrl.length) {
        return nil;
    }

    NSString *absoluteURLString = [baseUrl growingHelper_absoluteURLStringWithPath:self.path andQuery:self.query];
    return [NSURL URLWithString:absoluteURLString];
}

- (NSDictionary *)query {
    return @{@"stm": [NSString stringWithFormat:@"%llu", self.stm]};
}

- (NSString *)path {
    return @"diversion/specified-layer-variables";
}

- (NSArray<id<GrowingRequestAdapter>> *)adapters {
    GrowingABTRequestAdapter *bodyAdapter = [GrowingABTRequestAdapter adapterWithRequest:self];
    GrowingTrackConfiguration *config = GrowingConfigurationManager.sharedInstance.trackConfiguration;
    NSString *accountId = config.accountId;
    NSString *datasourceId = config.dataSourceId;
    NSString *distinctId = [GrowingDeviceInfo currentDeviceInfo].deviceIDString;

    NSMutableDictionary *parameters = @{
        @"accountId": accountId,
        @"datasourceId": datasourceId,
        @"distinctId": distinctId,
        @"layerId": self.layerId.copy
    }
                                          .mutableCopy;

    BOOL newDevice = [GrowingDeviceInfo currentDeviceInfo].isNewDeviceInFirstSession;
    if (newDevice) {
        parameters[@"newDevice"] = @(newDevice);
    }

    unsigned char factor = (unsigned char)(self.stm & 0xFF);
    if (self.loginUserId.length > 0) {
        parameters[@"userId"] = [[self.loginUserId.growingHelper_uft8Data growingHelper_xorEncryptWithHint:factor]
            growingHelper_base64String];
    }
    if (self.loginUserKey.length > 0) {
        parameters[@"userKey"] = [[self.loginUserKey.growingHelper_uft8Data growingHelper_xorEncryptWithHint:factor]
            growingHelper_base64String];
    }

    bodyAdapter.parameters = parameters.copy;
    GrowingRequestMethodAdapter *methodAdapter = [GrowingRequestMethodAdapter adapterWithRequest:self];
    NSMutableArray *adapters = [NSMutableArray arrayWithObjects:bodyAdapter, methodAdapter, nil];
    return adapters;
}

- (NSTimeInterval)timeoutInSeconds {
    GrowingNetworkConfig *networkConfig = GrowingConfigurationManager.sharedInstance.trackConfiguration.networkConfig;
    if (networkConfig && networkConfig.abTestingRequestTimeout > 0) {
        return networkConfig.abTestingRequestTimeout;
    }
    return 5.0f;
}

@end
