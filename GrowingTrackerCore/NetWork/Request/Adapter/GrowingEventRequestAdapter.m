//
//  GrowingEventRequestAdapter.m
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


#import "GrowingEventRequestAdapter.h"
#import "GrowingEventRequest.h"
#import "NSData+GrowingHelper.h"

@implementation GrowingEventRequestHeaderAdapter

- (NSMutableURLRequest *)adaptedRequest:(NSMutableURLRequest *)request {
    
    NSMutableURLRequest *needAdaptReq = request;
    [needAdaptReq setValue:@"3" forHTTPHeaderField:@"X-Compress-Code"];
    [needAdaptReq setValue:@"1" forHTTPHeaderField:@"X-Crypt-Codec"];
    [needAdaptReq setValue:@"application/octet-stream" forHTTPHeaderField:@"Content-Type"];

    return needAdaptReq;
}

@end

#pragma mark GrowingEventRequestJsonBodyAdpter

@interface GrowingEventRequestJsonBodyAdpter ()

@property (nonatomic, strong) NSArray <NSString *> *events;
@property (nonatomic, assign, readwrite) unsigned long long timestamp;
@property (nonatomic, copy) void(^outsizeBlock)(unsigned long long) ;

@end

@implementation GrowingEventRequestJsonBodyAdpter

+ (instancetype)eventJsonBodyAdpter:(NSArray<NSString *> *)events
                          timestamp:(unsigned long long)timestamp
                       outsizeBlock:(nonnull void (^)(unsigned long long))outsizeBlock {
    GrowingEventRequestJsonBodyAdpter *bodyAdapter = [[GrowingEventRequestJsonBodyAdpter alloc] init];
    bodyAdapter.events = events;
    bodyAdapter.timestamp = timestamp;
    bodyAdapter.outsizeBlock = outsizeBlock;
    return bodyAdapter;
}

- (NSMutableURLRequest *)adaptedRequest:(NSMutableURLRequest *)request {
    if (!self.events.count) {
        return nil;
    }
    
    NSString *jsonString = [self buildJSONStringWithEvents:self.events];
    NSData *JSONData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    
    [JSONData growingHelper_LZ4String];
    JSONData = [JSONData growingHelper_xorEncryptWithHint:(self.timestamp & 0xFF)];
    
    if (self.outsizeBlock) {
        self.outsizeBlock(JSONData.length);
    }
    
    NSMutableURLRequest *needAdaptReq = request;
    needAdaptReq.HTTPBody = JSONData;
    
    return needAdaptReq;
}

- (NSString *)buildJSONStringWithEvents:(NSArray<NSString *> *)events {
    return [NSString stringWithFormat:@"[%@]", [events componentsJoinedByString:@","]];
}

@end
