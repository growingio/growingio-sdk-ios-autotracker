//
//  GAI.m
//  GrowingAnalytics
//
//  Created by YoloMao on 2022/5/19.
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

#import "GAI.h"
#import "Dummy-GAITrackerImpl.h"

NSString *const kGAIProduct = @"Dummy Google Analytics";

NSString *const kGAIVersion = @"0.0.0";

NSString *const kGAIErrorDomain = @"com.growingio.GoogleAnalytics";

@interface GAI ()

@property (nonatomic, strong) NSMutableDictionary *trackers;

@end

@implementation GAI

+ (GAI *)sharedInstance {
    static GAI *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[self alloc] init];
        _sharedInstance.trackers = NSMutableDictionary.dictionary;
    });

    return _sharedInstance;
}

- (id<GAITracker>)trackerWithName:(NSString *)name
                       trackingId:(NSString *)trackingId {
    if (!name || name.length == 0) {
        return nil;
    }
    
    if (self.trackers[name]) {
        return self.trackers[name];
    }
    
    Dummy_GAITrackerImpl *tracker = [[Dummy_GAITrackerImpl alloc] initWithName:name
                                                                    trackingId:trackingId];
    [self.trackers setObject:tracker forKey:name];
    
    if (!self.defaultTracker) {
        self.defaultTracker = tracker;
    }
    
    return tracker;
    
}

- (id<GAITracker>)trackerWithTrackingId:(NSString *)trackingId {
    return [self trackerWithName:trackingId trackingId:trackingId];
}

- (void)removeTrackerByName:(NSString *)name {
    [self.trackers removeObjectForKey:name];
}

- (void)dispatch {
    
}

- (void)dispatchWithCompletionHandler:(void (^)(GAIDispatchResult result))completionHandler {
    
}

@end
