//
//  GrowingBaseModel.m
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


#import "GrowingBaseModel.h"
#import "GrowingInstance.h"
#import "NSDictionary+GrowingHelper.h"
#import "NSArray+GrowingHelper.h"
#import "NSData+GrowingHelper.h"
#import "GrowingCocoaLumberjack.h"

static NSMutableArray<NSMutableDictionary*> *allTypeInstance = nil;
static NSMutableDictionary *allAccountIdDict = nil;

@interface GrowingBaseModel()

@property (nonatomic, retain)  NSMutableURLRequest *request;

@end

@implementation GrowingBaseModel

+ (instancetype)shareInstanceWithType:(GrowingModelType)type
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        allTypeInstance = [[NSMutableArray alloc] initWithCapacity:GrowingModelTypeCount];
        for (NSUInteger i = 0 ; i < GrowingModelTypeCount ; i ++) {
            NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
            [allTypeInstance addObject:dict];
        }
    });
    
    NSMutableDictionary *dict = allTypeInstance[type];
    GrowingBaseModel *obj = nil;
    @synchronized (dict) {
        obj = [dict valueForKey:NSStringFromClass(self)];
        if (!obj) {
            obj = [[self alloc] init];
            obj ->_modelType = type;
            [dict setValue:obj forKey:NSStringFromClass(self)];
        }
    }
    return obj;
}

+ (instancetype)sdkInstance {
    return [self shareInstanceWithType:GrowingModelTypeSDKCircle];
}

- (void)authorityVerification:(NSMutableURLRequest *)request {
    // do nothing
}

- (BOOL)authorityErrorHandle:(void(^)(BOOL flag))finishBlock {
    finishBlock = nil;
    return NO;
}

- (void)startTaskWithURL:(NSString *)url
              httpMethod:(NSString *)httpMethod
              parameters:(id)parameters // NSArray or NSDictionary
                 success:(GROWNetworkSuccessBlock)success
                 failure:(GROWNetworkFailureBlock)failure
{
    [self startTaskWithURL:url
                httpMethod:httpMethod
                parameters:parameters
              outsizeBlock:nil
             configRequest:nil
                       STM:0
          timeoutInSeconds:0
                   success:success
                   failure:failure];
}

- (void)startTaskWithURL:(NSString *)url
              httpMethod:(NSString *)httpMethod
              parameters:(id)parameters // NSArray or NSDictionary
            outsizeBlock:(void (^)(unsigned long long))outsizeBlock
           configRequest:(void (^)(NSMutableURLRequest *))configRequest
                     STM:(unsigned long long int)STM
        timeoutInSeconds:(NSUInteger)timeout
                 success:(GROWNetworkSuccessBlock)success
                 failure:(GROWNetworkFailureBlock)failure
{
    self.request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:url]];
    [self.request setHTTPMethod:httpMethod];
    if (timeout > 0)
    {
        self.request.timeoutInterval = (NSTimeInterval)timeout;
    }

    if (configRequest != nil)
    {
        configRequest(self.request);
    }

    [self authorityVerification:self.request];
    
    [self.request addValue:[GROWGetTimestamp() stringValue] forHTTPHeaderField:@"X-Timestamp"];
    [self.request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    
    NSData *JSONData = nil;
    if (parameters)
    {
        JSONData = [parameters growingHelper_jsonData];
    }

    if (JSONData.length > 0)
    {
        [self.request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    }

    [self.request setHTTPBody:JSONData];
    
    if (outsizeBlock)
    {
        outsizeBlock(JSONData.length);
    }
    
    if (!success) success = ^( NSHTTPURLResponse *httpResponse , NSData *data ){};
    if (!failure) failure = ^( NSHTTPURLResponse *httpResponse , NSData *data, NSError *error ){};
    
    NSURLSession *session = [NSURLSession sharedSession];
    
    NSURLSessionTask *task = [session dataTaskWithRequest:self.request
                                        completionHandler:^(NSData * _Nullable data,
                                                            NSURLResponse * _Nullable _response,
                                                            NSError * _Nullable connectionError) {
                               NSHTTPURLResponse *response = (id)_response;
                               dispatch_async(dispatch_get_main_queue(), ^{
                                   if (connectionError) {
                                       GIOLogError(@"Request(%p) failed with connection error: %@", self.request, connectionError);
                                       failure(response,data,connectionError);
                                       return;
                                   }
                                   
                                   if (self.modelType != GrowingModelTypeEvent
                                       && response.statusCode == 403)
                                   {
                                       BOOL shouldReturn = [self authorityErrorHandle:^(BOOL flag) {
                                           if (flag) {
                                               [self startTaskWithURL:url
                                                           httpMethod:httpMethod
                                                           parameters:parameters
                                                         outsizeBlock:outsizeBlock
                                                        configRequest:configRequest
                                                                  STM:STM
                                                     timeoutInSeconds:timeout
                                                              success:success
                                                              failure:failure];
                                           } else {
                                               if (failure) {
                                                   failure(response,data,connectionError);
                                               }
                                           }
                                       }];
                                       
                                       if (shouldReturn) {
                                           return;
                                       }
                                   }
                                   
                                   if (response.statusCode != 200) {
                                       GIOLogError(@"Request(%p) failed with unexpected status code: %zd.", self.request, response.statusCode);
                                       failure(response,data,connectionError);
                                       return;
                                   }
                                   
                                   GIOLogDebug(@"Request(%p) succeeded: %zd.", self.request, response.statusCode);
                                   success(response, data);
                               });
                           }];
    GIOLogDebug(@"Request(%p) has been sent.", self.request);
    
    [task resume];
}

- (NSURLSessionTask *)startTaskForEvents:(NSArray <NSString *> *)events
                                 urlString:(NSString *)urlString
                             withAccountId:(NSString *)accountId
                              andTimestamp:(unsigned long long)timestamp
                              outsizeBlock:(void (^)(unsigned long long))outsizeBlock
                                   success:(GROWNetworkSuccessBlock)success
                                   failure:(GROWNetworkFailureBlock)failure {
    
    if (!events.count) { return nil;}

    self.request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:urlString]];
    [self.request setHTTPMethod:@"POST"];
    
    [self.request addValue:[GROWGetTimestamp() stringValue] forHTTPHeaderField:@"X-Timestamp"];
    [self.request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [self.request setValue:accountId forHTTPHeaderField:@"X-GrowingIO-UID"];
    
    NSData *JSONData = nil;
    NSString *jsonString = [self buildJSONStringWithEvents:events];
    if (jsonString) {
        JSONData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:JSONData options:NSJSONReadingMutableContainers error:nil];
        GIOLogDebug(@"request url = %@.\nprepare to sent events = %@\n", urlString, dict);
    }

    BOOL isSendingEvent = YES;
    if (isSendingEvent) {
        JSONData = [JSONData growingHelper_LZ4String];

        JSONData = [JSONData growingHelper_xorEncryptWithHint:(timestamp & 0xFF)];
        [self.request addValue:@"3" forHTTPHeaderField:@"X-Compress-Codec"]; // 3 stands for iOS LZ4 compression
        [self.request addValue:@"1" forHTTPHeaderField:@"X-Crypt-Codec"]; // 1 stands for XOR encryption
        [self.request addValue:@"application/octet-stream" forHTTPHeaderField:@"Content-Type"];
    
    } else if (JSONData.length > 0) { // for formate debug
        [self.request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    }

    [self.request setHTTPBody:JSONData];
    
    if (outsizeBlock) {
        outsizeBlock(JSONData.length);
    }
    
    if (!success) success = ^( NSHTTPURLResponse *httpResponse , NSData *data ){};
    if (!failure) failure = ^( NSHTTPURLResponse *httpResponse , NSData *data, NSError *error ){};
    
    NSURLSession *session = [NSURLSession sharedSession];
    
    NSURLSessionTask *task = [session dataTaskWithRequest:self.request
                                        completionHandler:^(NSData * _Nullable data,
                                                            NSURLResponse * _Nullable _response,
                                                            NSError * _Nullable connectionError) {
                               NSHTTPURLResponse *response = (id)_response;
                               dispatch_async(dispatch_get_main_queue(), ^{
                                   if (connectionError) {
                                       GIOLogError(@"Request(%p) failed with connection error: %@", self.request, connectionError);
                                       failure(response,data,connectionError);
                                       return;
                                   }
                                   
                                   if (response.statusCode != 200) {
                                       GIOLogError(@"Request(%p) failed with unexpected status code: %zd.", self.request, response.statusCode);
                                       failure(response,data,connectionError);
                                       return;
                                   }
                                   
                                   GIOLogDebug(@"Request(%p) succeeded: %zd.", self.request, response.statusCode);
                                   success(response, data);
                               });
                           }];
    [task resume];
    
    return task;
}

- (NSString *)buildJSONStringWithEvents:(NSArray<NSString *> *)events {
    return [NSString stringWithFormat:@"[%@]", [events componentsJoinedByString:@","]];
}

@end
