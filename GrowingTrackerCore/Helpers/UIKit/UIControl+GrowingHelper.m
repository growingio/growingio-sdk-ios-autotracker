//
//  UIButton+Block.m
//  TravelGuideMdd
//
//  Created by GrowingIO on 14/10/30.
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

#if __has_include(<UIKit/UIKit.h>) && !TARGET_OS_WATCH
#import <objc/runtime.h>
#import "GrowingTrackerCore/Helpers/UIKit/UIControl+GrowingHelper.h"

#define UICONTROL_BLOCK(EVENT, GETTER, SETTER)                                                         \
    static const char GETTER##_key;                                                                    \
    -(void)SETTER : (void (^)(void))block {                                                            \
        NSInteger flag = 0;                                                                            \
        if (self.GETTER) {                                                                             \
            flag -= 1;                                                                                 \
        }                                                                                              \
        if (block) {                                                                                   \
            flag += 1;                                                                                 \
        }                                                                                              \
        objc_setAssociatedObject(self, &GETTER##_key, block, OBJC_ASSOCIATION_COPY_NONATOMIC);         \
                                                                                                       \
        switch (flag) {                                                                                \
            case -1:                                                                                   \
                [self removeTarget:self action:@selector(__##GETTER##_handle) forControlEvents:EVENT]; \
                break;                                                                                 \
            case 0:                                                                                    \
                break;                                                                                 \
            case 1:                                                                                    \
            default:                                                                                   \
                [self addTarget:self action:@selector(__##GETTER##_handle) forControlEvents:EVENT];    \
                break;                                                                                 \
        }                                                                                              \
    }                                                                                                  \
    -(void (^)(void))GETTER {                                                                          \
        return objc_getAssociatedObject(self, &GETTER##_key);                                          \
    }                                                                                                  \
    -(void)__##GETTER##_handle {                                                                       \
        if (self.GETTER) {                                                                             \
            self.GETTER();                                                                             \
        }                                                                                              \
    }

@implementation UIControl (GrowingHelper)
UICONTROL_BLOCK(UIControlEventTouchUpInside, growingHelper_onClick, setGrowingHelper_onClick)
@end

@implementation UITextField (GrowingHelper)
UICONTROL_BLOCK(UIControlEventEditingChanged, growingHelper_onTextChange, setGrowingHelper_onTextChange)
@end
#endif
