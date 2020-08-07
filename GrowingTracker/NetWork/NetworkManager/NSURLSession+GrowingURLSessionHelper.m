//
//  NSURLSession+GrowingURLSessionHelper.m
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


#import "NSURLSession+GrowingURLSessionHelper.h"
#import "NSURLSessionDataTask+GrowingURLSessionDataTaskHelper.h"
#import "GrowingURLSessionProtocol.h"

@implementation NSURLSession (GrowingURLSessionHelper)

- (id<GrowingURLSessionDataTaskProtocol>)dataTaskWithRequest:(NSURLRequest * _Nonnull)request
                                           completion:(void (^ _Nonnull)(NSData * _Nullable, NSURLResponse * _Nullable, NSError * _Nullable))completion {
    
    NSURLSessionTask *task = [self dataTaskWithRequest:request
                                     completionHandler:completion];
    
    if ([task isKindOfClass:NSURLSessionDataTask.class]) {
        return (NSURLSessionDataTask *)task;
    }
    
    return nil;
}

@end
