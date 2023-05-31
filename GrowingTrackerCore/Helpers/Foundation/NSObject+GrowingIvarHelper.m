//
//  NSObject+GrowingIVarHelper.m
//  GrowingAnalytics
//
//  Created by GrowingIO on 2020/8/4.
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

#import <objc/runtime.h>
#import "GrowingTrackerCore/Helpers/Foundation/NSObject+GrowingIvarHelper.h"

@implementation NSObject (GrowingIvarHelper)

- (BOOL)growingHelper_getIvar:(const char *)ivarName outObj:(id *)outObj {
    unsigned count = 0;
    Ivar var = nil;
    Ivar *ivars = class_copyIvarList(self.class, &count);
    if (ivars) {
        for (unsigned int i = 0; i < count; ++i) {
            const char *name = ivar_getName(ivars[i]);
            if (strcmp(name, ivarName) == 0) {
                var = ivars[i];
                break;
            }
        }
    }
    free(ivars);

    if (outObj && var) {
        *outObj = object_getIvar(self, var);
    }
    return var ? YES : NO;
}

@end
