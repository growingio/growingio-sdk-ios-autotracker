//
//  GrowingGlobal.h
//  GrowingTracker
//
//  Created by GrowingIO on 9/1/16.
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


#ifndef GrowingGlobal_h
#define GrowingGlobal_h
extern BOOL                 g_GDPRFlag;

// 埋点的一些限制
extern const NSUInteger g_maxCountOfKVPairs;
extern const NSUInteger g_maxLengthOfKey;
extern const NSUInteger g_maxLengthOfValue;

BOOL SDKDoNotTrack(void);
#define parameterKeyErrorLog @"当前数据的标识符不合法。合法的标识符的详细定义请参考：https://docs.growingio.com/v3/developer-manual/sdkintegrated/ios-sdk/ios-sdk-api/customize-api"
#define parameterValueErrorLog @"当前数据的值不合法。合法值的详细定义请参考：https://docs.growingio.com/v3/developer-manual/sdkintegrated/ios-sdk/ios-sdk-api/customize-api"
// Feature 编译控制宏

// 是否支持 Hybrid 埋点
#define kHybridModeTrack 1
// 是否支持 Hybrid Pattern Server
// 这里 Hybrid Pattern Server 还没有经过严格测试, 暂时关闭
#define kHybridPatternServer 0

#endif /* GrowingGlobal_h */
