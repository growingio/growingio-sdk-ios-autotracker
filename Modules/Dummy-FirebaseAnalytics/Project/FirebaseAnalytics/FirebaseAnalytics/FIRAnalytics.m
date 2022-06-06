//
//  FIRAnalytics.m
//  GrowingAnalytics
//
//  Created by YoloMao on 2022/5/23.
//  Copyright (C) 2022 Beijing Yishu Technology Co., Ltd.
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

#import "FIRAnalytics.h"
#import "FIRAnalytics+AppDelegate.h"
#import "FIRAnalytics+Consent.h"
#import "FIRAnalytics+OnDevice.h"

@implementation FIRAnalytics

+ (void)logEventWithName:(NSString *)name
              parameters:(nullable NSDictionary<NSString *, id> *)parameters
NS_SWIFT_NAME(logEvent(_:parameters:)) {
    
}

+ (void)setUserPropertyString:(nullable NSString *)value forName:(NSString *)name
NS_SWIFT_NAME(setUserProperty(_:forName:)) {
    
}

+ (void)setUserID:(nullable NSString *)userID {
    
}

+ (void)setAnalyticsCollectionEnabled:(BOOL)analyticsCollectionEnabled {
    
}

+ (void)setSessionTimeoutInterval:(NSTimeInterval)sessionTimeoutInterval {
    
}

+ (nullable NSString *)appInstanceID {
    return nil;
}

+ (void)resetAnalyticsData {
    
}

+ (void)setDefaultEventParameters:(nullable NSDictionary<NSString *, id> *)parameters {
    
}

@end

@implementation FIRAnalytics (AppDelegate)

+ (void)handleEventsForBackgroundURLSession:(NSString *)identifier
                          completionHandler:(nullable void (^)(void))completionHandler {
    
}

+ (void)handleOpenURL:(NSURL *)url {
    
}

+ (void)handleUserActivity:(id)userActivity {
    
}

@end

FIRConsentType const FIRConsentTypeAdStorage = @"ad_storage";
FIRConsentType const FIRConsentTypeAnalyticsStorage = @"analytics_storage";

FIRConsentStatus const FIRConsentStatusDenied = @"denied";
FIRConsentStatus const FIRConsentStatusGranted = @"granted";

@implementation FIRAnalytics (Consent)

+ (void)setConsent:(NSDictionary<FIRConsentType, FIRConsentStatus> *)consentSettings {
    
}

@end

@implementation FIRAnalytics (OnDevice)

+ (void)initiateOnDeviceConversionMeasurementWithEmailAddress:(NSString *)emailAddress
NS_SWIFT_NAME(initiateOnDeviceConversionMeasurement(emailAddress:)) {
    
}

@end
