//
// GrowingEventNetworkService.h
// GrowingAnalytics
//
//  Created by sheng on 2021/6/8.
//  Copyright (C) 2017 Beijing Yishu Technology Co., Ltd.
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

#import "GrowingBaseService.h"
#import "GrowingRequestProtocol.h"

@protocol GrowingEventNetworkService <GrowingBaseService>

@required

/// event相关数据上传的网络请求
/// @param request request对象，需遵循GrowingRequestProtocol协议
/// @param callback 请求回调
- (void)sendRequest:(id <GrowingRequestProtocol> _Nonnull)request
         completion:(void(^_Nullable)(NSHTTPURLResponse * _Nonnull httpResponse,
                                      NSData * _Nullable data,
                                      NSError * _Nullable error))callback;

@end
