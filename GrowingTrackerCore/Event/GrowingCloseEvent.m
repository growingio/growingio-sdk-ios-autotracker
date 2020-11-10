//
//  GrowingCloseEvent.m
//  GrowingTracker
//
//  Created by GrowingIO on 2020/5/18.
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


#import "GrowingCloseEvent.h"
#import "GrowingEventManager.h"
#import "GrowingNetworkInterfaceManager.h"

@interface GrowingCloseEvent ()

@property (nonatomic, copy, readwrite) NSString * _Nonnull pageName;

@end

@implementation GrowingCloseEvent

- (NSString *)eventTypeKey {
    return kEventTypeKeyClose;
}

- (instancetype)initWithLastPage:(NSString *)pageName {
    if (self = [super init]) {
        self.pageName = pageName;
    }
    return self;
}

+ (void)sendWithLastPage:(NSString *)pageName {
    GrowingCloseEvent *clsEvent = [[GrowingCloseEvent alloc] initWithLastPage:pageName];
    
    [[GrowingEventManager shareInstance] addEvent:clsEvent
                                         thisNode:nil
                                      triggerNode:nil
                                      withContext:nil];
}

#pragma mark GrowingEventTransformable

- (NSDictionary *)toDictionary {
    NSMutableDictionary *dataDictM = [NSMutableDictionary dictionaryWithDictionary:[super toDictionary]];
    dataDictM[@"pageName"] = self.pageName ?: @"";
    dataDictM[@"networkState"] = [[GrowingNetworkInterfaceManager sharedInstance] networkType];
    return dataDictM;;
}

@end
