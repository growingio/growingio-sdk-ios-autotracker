//
//  GrowingInstance.h
//  GrowingTracker
//
//  Created by GrowingIO on 5/4/15.
//  Copyright (C) 2020 Beijing Yishu Technology Co., Ltd.
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

#import "GrowingTracker.h"

NS_ASSUME_NONNULL_BEGIN

@interface GrowingInstance: NSObject

@property (nonatomic, strong) GrowingConfiguration *configuration;

+ (void)updateSampling:(CGFloat)sampling;

+ (instancetype)sharedInstance;
+ (void)startWithConfiguration:(GrowingConfiguration * _Nonnull)configuration;
+ (BOOL)doDeeplinkByUrl:(NSURL *)url callback:(void(^)(NSDictionary *params, NSTimeInterval processTime, NSError *error))callback;

+ (void)reportGIODeeplink:(NSURL *)linkURL;
+ (void)reportShortChainDeeplink:(NSURL *)linkURL;

typedef void (^GrowingDeeplinkHandler) (NSDictionary * _Nullable params, NSTimeInterval processTime, NSError *error);
+ (void)setDeeplinkHandler:(GrowingDeeplinkHandler)handler;
+ (GrowingDeeplinkHandler)deeplinkHandler;

@property (nonatomic, copy, readonly) NSString * _Nonnull projectID;
@property (nonatomic, copy) CLLocation * _Nullable gpsLocation;

@end

NS_INLINE NSNumber *GROWGetTimestampFromTimeInterval(NSTimeInterval timeInterval) {
    return [NSNumber numberWithUnsignedLongLong:timeInterval * 1000.0];
}

NS_INLINE NSNumber *GROWGetTimestamp() {
    return GROWGetTimestampFromTimeInterval([[NSDate date] timeIntervalSince1970]);
}

NS_ASSUME_NONNULL_END


#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)	([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)

#define IOS8_PLUS SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")
#define IOS10_PLUS SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"10.0")
