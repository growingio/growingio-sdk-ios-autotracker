//
// GrowingAnnotationCore.m
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

#import "GrowingAnnotationCore.h"
#include <mach-o/getsect.h>
#include <mach-o/loader.h>
#include <mach-o/dyld.h>
#include <dlfcn.h>
#import <objc/runtime.h>
#import <objc/message.h>
#include <mach-o/ldsyms.h>

// Debug Logging
#ifdef DEBUG
#define GrowingLog(x, ...) NSLog(x, ##__VA_ARGS__);
#else
#define GrowingLog(x, ...)
#endif

NSArray<NSString *> *GrowingReadConfiguration(char *sectionName, const struct mach_header *mhp) {
    unsigned long size = 0;
#ifndef __LP64__
    uintptr_t *memory = (uintptr_t *)getsectiondata(mhp, SEG_DATA, sectionName, &size);
#else
    const struct mach_header_64 *mhp64 = (const struct mach_header_64 *)mhp;
    uintptr_t *memory = (uintptr_t *)getsectiondata(mhp64, SEG_DATA, sectionName, &size);
#endif

    unsigned long counter = size / sizeof(void *);
    if (counter == 0) {
        return nil;
    }
    NSMutableArray *configs = [NSMutableArray array];
    for (int idx = 0; idx < counter; ++idx) {
        char *string = (char *)memory[idx];
        NSString *str = [NSString stringWithUTF8String:string];
        if (!str) continue;
        GrowingLog(@"[Growing] %@", str);
        if (str) [configs addObject:str];
    }

    return configs;
}

static void dyld_callback(const struct mach_header *mhp, intptr_t vmaddr_slide) {
    
    NSArray *mods = GrowingReadConfiguration(GrowingModSectName, mhp);
    for (NSString *modName in mods) {
        if (modName) {
            // 这里不进行 name -> class 转换,且只存储NSString
            [[GrowingModuleManager sharedInstance] addLocalModule:modName];
        }
    }

    // register services
    NSArray<NSString *> *services = GrowingReadConfiguration(GrowingServiceSectName, mhp);
    for (NSString *map in services) {
        NSData *jsonData = [map dataUsingEncoding:NSUTF8StringEncoding];
        NSError *error = nil;
        id json = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&error];
        if (!error) {
            if ([json isKindOfClass:[NSDictionary class]] && [json allKeys].count) {
                NSString *protocol = [json allKeys][0];
                NSString *clsName = [json allValues][0];
                if (protocol && clsName) {
                    // 这里不进行 name -> class 转换,且只存储NSString
                    [[GrowingServiceManager sharedInstance] registerServiceName:protocol implClassName:clsName];
                }
            }
        }
    }
}
// add callback before main()
__attribute__((constructor)) void GrowingInitProphet(void) {
    _dyld_register_func_for_add_image(dyld_callback);
}

@implementation GrowingAnnotationCore

@end
