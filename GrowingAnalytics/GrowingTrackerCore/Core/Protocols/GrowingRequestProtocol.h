//
//  GrowingRequestProtocol.h
//  GrowingAnalytics
//
//  Created by GrowingIO on 2020/6/17.
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


#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, GrowingHTTPMethod) {
    GrowingHTTPMethodGET,
    GrowingHTTPMethodPOST,
    GrowingHTTPMethodPUT,
    GrowingHTTPMethodDELETE,
};

@protocol GrowingRequestAdapter <NSObject>

- (NSMutableURLRequest *)adaptedRequest:(NSMutableURLRequest *)request;

@end

#pragma mark GrowingRequestProtocol

@protocol GrowingRequestProtocol <NSObject>

@required

@property (nonatomic, assign, readonly) GrowingHTTPMethod method;
@property (nonatomic, strong, readonly) NSURL *absoluteURL;
@property (nonatomic, copy, readonly) NSString *path;
@property (nonatomic, strong, readonly) NSArray <id <GrowingRequestAdapter>> *adapters;



@optional
///event property
@property (nonatomic, copy) NSData *events;
@property (nonatomic, assign, readwrite) unsigned long long outsize;
@property (nonatomic, assign) unsigned long long stm;
@property (nonatomic, assign, readonly) NSTimeInterval timeoutInSeconds;
@property (nonatomic, strong, readonly) NSDictionary *query;
@end
