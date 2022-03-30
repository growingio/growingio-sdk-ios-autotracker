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

#import "GrowingTrackerCore/Core/GrowingAnnotationCore.h"
#include <mach-o/getsect.h>
#include <mach-o/loader.h>
#include <mach-o/dyld.h>
#include <dlfcn.h>
#include <mach-o/ldsyms.h>

static growing_section growing_modules;
static growing_section growing_services;

growing_section growingSectionDataModule(void) {
    return growing_modules;
}

growing_section growingSectionDataService(void) {
    return growing_services;
}

void GrowingReadConfiguration(growing_section* msection, char *sectionName, const struct mach_header *mhp) {
    unsigned long size = 0;
#ifndef __LP64__
    uintptr_t *memory = (uintptr_t *)getsectiondata(mhp, SEG_DATA, sectionName, &size);
#else
    const struct mach_header_64 *mhp64 = (const struct mach_header_64 *)mhp;
    uintptr_t *memory = (uintptr_t *)getsectiondata(mhp64, SEG_DATA, sectionName, &size);
#endif

    unsigned long counter = size / sizeof(void *);
    if (counter == 0) {
        return;
    }
    
    for (int idx = 0; idx < counter; ++idx) {
        if (msection->count < growing_section_size) {
            msection->charAddress[msection->count] = (uintptr_t)(memory[idx]);
            msection->count ++;
        }
    }
    return;
}


static void dyld_callback(const struct mach_header *mhp, intptr_t vmaddr_slide) {
    switch (mhp->filetype) {
        case MH_EXECUTE:
        case MH_DYLIB:
            GrowingReadConfiguration(&growing_modules,GrowingModSectName,mhp);
            GrowingReadConfiguration(&growing_services,GrowingServiceSectName,mhp);
        default:
            // do nothing
            break;
    }
}
// add callback before main()
__attribute__((constructor)) void GrowingInitProphet(void) {
    _dyld_register_func_for_add_image(dyld_callback);
}
