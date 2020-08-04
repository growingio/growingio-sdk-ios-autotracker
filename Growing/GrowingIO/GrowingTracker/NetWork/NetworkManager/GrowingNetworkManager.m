//
//  GrowingNetworkManager.m
//  GrowingTracker
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


#import "GrowingNetworkManager.h"
#import "NSURLSession+GrowingURLSessionHelper.h"
#import "GrowingURLSessionDataTaskProtocol.h"
#import "GrowingURLSessionProtocol.h"
#import "GrowingRequestProtocol.h"
#import "GrowingCocoaLumberjack.h"

@interface GrowingNetworkManager ()

@property (nonatomic, strong) id <GrowingURLSessionProtocol> session;

@end

@implementation GrowingNetworkManager

+ (instancetype)shareManager {
    return [self shareManagerURLSession:[NSURLSession sharedSession]];
}

+ (instancetype)shareManagerURLSession:(id<GrowingURLSessionProtocol>)session {
    static GrowingNetworkManager *manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[GrowingNetworkManager alloc] init];
        manager.session = session;
    });
    return manager;
}

- (id <GrowingURLSessionDataTaskProtocol>)sendRequest:(id<GrowingRequestProtocol>)request
                                              success:(GrowingNetworkSuccessBlock)success
                                              failure:(GrowingNetworkFailureBlock)failure {
    
    NSURLRequest *urlRequest = [self createRequest:request];
    
    if (![self.session respondsToSelector:@selector(dataTaskWithRequest:completion:)]) {
        GIOLogError(@"Session(%@) cannot respond to dataTaskWithRequest:completion method.", self.session);
        return nil;
    }
    
    id <GrowingURLSessionDataTaskProtocol> task =
    [self.session dataTaskWithRequest:urlRequest
                           completion:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error) {
                GIOLogError(@"Request(%@) failed with connection error: %@", request.absoluteURL.absoluteString, error);
                if (failure) {
                    failure(httpResponse, data, error);
                }
                return;
            }
            
            if (httpResponse.statusCode >= 200 && httpResponse.statusCode < 300) {
                
                GIOLogDebug(@"Request(%@) succeeded: %zd.", request.absoluteURL.absoluteString, httpResponse.statusCode);
                if (success) {
                    success(httpResponse, data);
                }
            } else {
                GIOLogError(@"Request(%@) failed with unexpected status code: %zd.", request.absoluteURL.absoluteString, httpResponse.statusCode);
                if (failure) {
                    failure(httpResponse, data, error);
                }
            }
        });
    }];
    
    if ([task respondsToSelector:@selector(resume)]) {
        [task resume];
    }
    
    return task;
}

- (NSURLRequest *)createRequest:(id <GrowingRequestProtocol>)request {
    
    if (![request respondsToSelector:@selector(absoluteURL)]) {
        return nil;
    }
    
    NSTimeInterval timeout = 60;
    if ([request respondsToSelector:@selector(timeoutInSeconds)] && request.timeoutInSeconds > 0) {
        timeout = request.timeoutInSeconds;
    }
    
    NSMutableURLRequest *resultReq = [NSMutableURLRequest requestWithURL:request.absoluteURL
                                                             cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                         timeoutInterval:timeout];
    
    if (![request respondsToSelector:@selector(adapters)]) {
        return resultReq;
    }
    
    for (id <GrowingRequestAdapter> adapter in request.adapters) {
       resultReq = [adapter adaptedRequest:resultReq];
    }

    return resultReq;
}

@end
