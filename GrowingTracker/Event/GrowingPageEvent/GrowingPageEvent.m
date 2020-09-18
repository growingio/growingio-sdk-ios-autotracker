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
#import "GrowingDeviceInfo.h"

@interface GrowingPageEvent ()

@property (nonatomic, copy, readwrite) NSString * _Nullable orientation;
@property (nonatomic, copy, readwrite) NSString * _Nullable pageTitle;
@property (nonatomic, copy, readwrite) NSString * _Nullable referralPage;
@property (nonatomic, copy, readwrite) NSString * _Nullable pageName;


@property (nonatomic, copy) NSString * _Nullable hybridDomain;
@property (nonatomic, copy) NSString * _Nullable protocolType;
@property (nonatomic, copy) NSString * _Nullable query;

@end

@implementation GrowingPageEvent


- (instancetype)initWithTitle:(NSString *)title pageName:(NSString *)pageName referralPage:(NSString *)referralPage {
    if (self = [super initWithTimestamp:nil]) {
        self.pageTitle = title;
        self.pageName = pageName;
        self.referralPage = referralPage;
        self.orientation = [GrowingDeviceInfo deviceOrientation];
    }
    return self;
}

+ (instancetype)pageEventWithTitle:(NSString *)title pageName:(NSString *)pageName referralPage:(NSString *)referralPage {
    return [[self alloc] initWithTitle:title pageName:pageName referralPage:referralPage];
}

+ (instancetype)hybridPageEventWithDataDict:(NSDictionary *)dataDict {

    NSString *referralPage = dataDict[@"referralPage"];
    NSString *title = dataDict[@"title"];
    NSString *pageName = dataDict[@"pageName"];
    NSString *query = dataDict[@"queryParameters"];
    NSNumber *timestamp = dataDict[@"timestamp"];
    
    GrowingPageEvent *page = [[self alloc] initWithTitle:title
                                                        pageName:pageName
                                                     referralPage:referralPage];
    page.timestamp = timestamp;
    page.query = query;
    
    return page;;
}

+ (instancetype)pageEventWithTitle:(NSString *)title pageName:(NSString *)pageName timestamp:(NSNumber *)timestamp {
    GrowingPageEvent *page = [[self alloc] initWithTitle:title pageName:pageName referralPage:nil];
    page.timestamp = timestamp;
    return page;
}

- (NSString*)eventTypeKey {
    return kEventTypeKeyPage;
}

#pragma mark GrowingEventTransformable

- (NSDictionary *)toDictionary {
    NSMutableDictionary *dataDictM = [NSMutableDictionary dictionaryWithDictionary:[super toDictionary]];
//    dataDictM[@"networkState"] = [[GrowingNetworkInterfaceManager sharedInstance] networkType];
    dataDictM[@"domain"] = self.hybridDomain ?: self.domain;
    dataDictM[@"pageName"] = self.pageName;
    dataDictM[@"referralPage"] = self.referralPage;
    dataDictM[@"queryParameters"] = self.query;
    dataDictM[@"orientation"] = self.orientation;
    dataDictM[@"title"] = self.pageTitle;
    return dataDictM;;
}

@end
