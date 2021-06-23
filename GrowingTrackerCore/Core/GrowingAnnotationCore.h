//
// GrowingAnnotationCore.h
// GrowingAnalytics
//
//  Created by sheng on 2021/6/10.
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


#import <Foundation/Foundation.h>
#import "GrowingServiceManager.h"
#import "GrowingModuleManager.h"

#ifndef GrowingModSectName

#define GrowingModSectName "GrowingMods"

#endif

#ifndef GrowingServiceSectName

#define GrowingServiceSectName "GrowingServices"

#endif

#define GrowingService(servicename,impl) \
class GrowingAnnotationCore; char * k##servicename##_service GrowingDATA(GrowingServices) = "{ \""#servicename"\" : \""#impl"\"}";


#define GrowingMod(name) \
class GrowingAnnotationCore; char * k##name##_mod GrowingDATA(GrowingMods) = ""#name"";

#define GrowingDATA(sectname) __attribute((used, section("__DATA,"#sectname"")))


NS_ASSUME_NONNULL_BEGIN

@interface GrowingAnnotationCore : NSObject

@end

NS_ASSUME_NONNULL_END
