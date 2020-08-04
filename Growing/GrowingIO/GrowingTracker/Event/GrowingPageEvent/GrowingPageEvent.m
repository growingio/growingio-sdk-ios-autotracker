//
//  GrowingPageEvent.m
//  GrowingAutoTracker
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


#import "GrowingPageEvent.h"
#import "GrowingEventManager.h"
#import "GrowingNetworkInterfaceManager.h"
#import "GrowingDeviceInfo.h"

@interface GrowingPageEvent ()

@property (nonatomic, copy, readwrite) NSString * _Nullable orientation;
@property (nonatomic, copy, readwrite) NSString * _Nullable pageTitle;
@property (nonatomic, copy, readwrite) NSString * _Nullable referalPage;
@property (nonatomic, copy, readwrite) NSString * _Nullable pageName;

@property (nonatomic, copy, readwrite) NSString * _Nullable networkState;

@property (nonatomic, copy) NSString * _Nullable hybridDomain;
@property (nonatomic, copy) NSString * _Nullable protocolType;
@property (nonatomic, copy) NSString * _Nullable query;

@end

@implementation GrowingPageEvent


- (instancetype)initWithTitle:(NSString *)title pageName:(NSString *)pageName referalPage:(NSString *)referalPage {
    if (self = [super initWithTimestamp:nil]) {
        self.pageTitle = title;
        self.pageName = pageName;
        self.referalPage = referalPage;
        self.networkState = [[GrowingNetworkInterfaceManager sharedInstance] networkType];
        self.orientation = [GrowingDeviceInfo deviceOrientation];
    }
    return self;
}

+ (instancetype)pageEventWithTitle:(NSString *)title pageName:(NSString *)pageName referalPage:(NSString *)referalPage {
    return [[self alloc] initWithTitle:title pageName:pageName referalPage:referalPage];
}

+ (instancetype)hybridPageEventWithDataDict:(NSDictionary *)dataDict {

    NSString *referalPage = dataDict[@"rp"];
    NSString *title = dataDict[@"tl"];
    NSString *pageName = dataDict[@"p"];
    NSString *query = dataDict[@"q"];
    NSNumber *timestamp = dataDict[@"tm"];
    
    GrowingPageEvent *page = [[self alloc] initWithTitle:title
                                                        pageName:pageName
                                                     referalPage:referalPage];
    page.timestamp = timestamp;
    page.query = query;
    
    return page;;
}

+ (instancetype)pageEventWithTitle:(NSString *)title pageName:(NSString *)pageName timestamp:(NSNumber *)timestamp {
    GrowingPageEvent *page = [[self alloc] initWithTitle:title pageName:pageName referalPage:nil];
    page.timestamp = timestamp;
    return page;
}

- (NSString*)eventTypeKey {
    return kEventTypeKeyPage;
}

#pragma mark GrowingEventTransformable

- (NSDictionary *)toDictionary {
    NSMutableDictionary *dataDictM = [NSMutableDictionary dictionaryWithDictionary:[super toDictionary]];
    dataDictM[@"r"] = [[GrowingNetworkInterfaceManager sharedInstance] networkType];
    dataDictM[@"d"] = self.hybridDomain ?: self.domain;
    dataDictM[@"p"] = self.pageName;
    dataDictM[@"rp"] = self.referalPage;
    dataDictM[@"q"] = self.query;
    dataDictM[@"o"] = self.orientation;
    dataDictM[@"tl"] = self.pageTitle;
    return dataDictM;;
}

@end
