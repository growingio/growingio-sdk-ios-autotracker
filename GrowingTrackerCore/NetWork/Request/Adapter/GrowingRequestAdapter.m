//
//  GrowingRequestAdapter.m
//  GrowingTracker
//
//  Created by GrowingIO on 2020/6/22.
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


#import "GrowingRequestAdapter.h"
#import "GrowingEventRequest.h"
#import "NSData+GrowingHelper.h"
#import "NSDictionary+GrowingHelper.h"


@interface GrowingRequestHeaderAdapter ()

@property (nonatomic, strong) NSDictionary *header;

@end

@implementation GrowingRequestHeaderAdapter

+ (instancetype)headerAdapterWithHeader:(NSDictionary *)header {
    GrowingRequestHeaderAdapter *headerAdapter = [[GrowingRequestHeaderAdapter alloc] init];
    headerAdapter.header = header;
    return headerAdapter;
}

- (NSMutableURLRequest *)adaptedRequest:(NSMutableURLRequest *)request {
    NSMutableURLRequest *needAdaptReq = request;
    [needAdaptReq setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    
    if (!self.header.count) {
        return needAdaptReq;
    }
    
    for (NSString *key in self.header) {
        [needAdaptReq setValue:self.header[key] forHTTPHeaderField:key];
    }
    return needAdaptReq;
}

@end

#pragma mark GrowingRequestMethodAdapter

@interface GrowingRequestMethodAdapter ()

@property (nonatomic, assign) GrowingHTTPMethod method;

@end

@implementation GrowingRequestMethodAdapter

+ (instancetype)methodAdpterWithMethod:(GrowingHTTPMethod)method {
    GrowingRequestMethodAdapter *methodAdapter = [[GrowingRequestMethodAdapter alloc] init];
    methodAdapter.method = method;
    return methodAdapter;
}

- (NSMutableURLRequest *)adaptedRequest:(NSMutableURLRequest *)request {
        
    NSMutableURLRequest *needAdaptReq = request;
    NSString *httpMethod = @"POST";
    
    switch (self.method) {
        case GrowingHTTPMethodPOST:
            httpMethod = @"POST";
            break;
        case GrowingHTTPMethodGET:
            httpMethod = @"GET";
            break;
            
        case GrowingHTTPMethodPUT:
            httpMethod = @"PUT";
            break;
            
        case GrowingHTTPMethodDELETE:
            httpMethod = @"DELETE";
            break;
            
        default:
            break;
    }

    needAdaptReq.HTTPMethod = httpMethod;
    
    return needAdaptReq;
}

@end

#pragma mark GrowingRequestJsonBodyAdapter

@interface GrowingRequestJsonBodyAdapter ()

@property (nonatomic, strong) NSDictionary *parameter;

@end

@implementation GrowingRequestJsonBodyAdapter

+ (instancetype)jsonBodyWithParameter:(NSDictionary *)parameter {
    GrowingRequestJsonBodyAdapter *jsonBodyAdapter = [[GrowingRequestJsonBodyAdapter alloc] init];
    jsonBodyAdapter.parameter = parameter;
    return jsonBodyAdapter;
}

- (NSMutableURLRequest *)adaptedRequest:(NSMutableURLRequest *)request {
    
    if (!self.parameter) {
        return request;
    }
    
    NSData *JSONData = [self.parameter growingHelper_jsonData];
    NSMutableURLRequest *needAdaptReq = request;
    needAdaptReq.HTTPBody = JSONData;
    
    return needAdaptReq;
}

@end



