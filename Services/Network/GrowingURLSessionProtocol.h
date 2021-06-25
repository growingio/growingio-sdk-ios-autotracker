//
//  GrowingURLSessionProtocol.h
//  GrowingTracker
//
//  Created by GrowingIO on 2020/6/18.
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
#import "GrowingURLSessionDataTaskProtocol.h"
//#import "NSURLSession+GrowingURLSessionHelper.h"

@protocol GrowingURLSessionProtocol <NSObject>

@required

- (id <GrowingURLSessionDataTaskProtocol>_Nullable)dataTaskWithRequest:(NSURLRequest *_Nonnull)request
                                                            completion:(void (^_Nonnull)(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error))completion;

@end
