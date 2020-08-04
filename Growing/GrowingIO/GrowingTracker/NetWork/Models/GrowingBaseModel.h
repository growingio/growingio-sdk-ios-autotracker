//
//  GrowingBaseModel.h
//  GrowingTracker
//
//  Created by GrowingIO on 15/10/27.
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

#import "GrowingNetworkConfig.h"

typedef void ( ^GROWNetworkSuccessBlock ) ( NSHTTPURLResponse *httpResponse , NSData *data);
typedef void ( ^GROWNetworkFailureBlock ) ( NSHTTPURLResponse *httpResponse , NSData *data, NSError *error );

typedef NS_ENUM(NSUInteger,GrowingModelType)
{
    GrowingModelTypeEvent,
    GrowingModelTypeSDKCircle,
    GrowingModelTypeCount
};

@interface GrowingBaseModel : NSObject

+ (instancetype)sdkInstance;
+ (instancetype)shareInstanceWithType:(GrowingModelType)type;

@property (nonatomic, readonly) GrowingModelType modelType;

- (void)authorityVerification:(NSMutableURLRequest *)request;

/**
 For httpstatusCode 403 (except GrowingModelTypeEvent)
 
 @param finishBlock 重新授权后的回调,YES为授权成功,成功后底层将resend之前的请求 NO为授权失败
  
 @return YES为终止底层网络回调 NO为不终止底层网络回调
 */
- (BOOL)authorityErrorHandle:(void(^)(BOOL flag))finishBlock;

- (void)startTaskWithURL:(NSString *)url
              httpMethod:(NSString*)httpMethod
              parameters:(id)parameters // NSArray or NSDictionary
                 success:(GROWNetworkSuccessBlock)success
                 failure:(GROWNetworkFailureBlock)failure;

- (void)startTaskWithURL:(NSString *)url
              httpMethod:(NSString*)httpMethod
              parameters:(id)parameters // NSArray or NSDictionary
            outsizeBlock:(void (^)(unsigned long long))outsizeBlock
           configRequest:(void(^)(NSMutableURLRequest* request))configRequest
                     STM:(unsigned long long int)STM
        timeoutInSeconds:(NSUInteger)timeout
                 success:(GROWNetworkSuccessBlock)success
                 failure:(GROWNetworkFailureBlock)failure;

- (NSURLSessionTask *)startTaskForEvents:(NSArray <NSString *> *)events
                               urlString:(NSString *)urlString
                           withAccountId:(NSString *)accountId
                            andTimestamp:(unsigned long long)timestamp
                            outsizeBlock:(void (^)(unsigned long long))outsizeBlock
                                 success:(GROWNetworkSuccessBlock)success
                                 failure:(GROWNetworkFailureBlock)failure;

@end
