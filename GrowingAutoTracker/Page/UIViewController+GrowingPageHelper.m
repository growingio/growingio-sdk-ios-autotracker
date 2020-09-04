//
// Created by xiangyang on 2020/5/20.
// Copyright (C) 2020 Beijing Yishu Technology Co., Ltd.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.


#import <objc/runtime.h>
#import "UIViewController+GrowingPageHelper.h"
#import "GrowingPage.h"
#import "GrowingAutoTracker.h"
#import "GrowingPageManager.h"

static void *const GROWING_PAGE_OBJECT = "GROWING_PAGE_OBJECT";
static void *const GROWING_PAGE_IGNORE = "GROWING_PAGE_IGNORE";

@implementation UIViewController (GrowingPageHelper)

- (void)growingPageHelper_setPageObject:(GrowingPageGroup *)page {
    objc_setAssociatedObject(self, GROWING_PAGE_OBJECT, page, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (GrowingPageGroup *)growingPageHelper_getPageObject {
    return objc_getAssociatedObject(self, GROWING_PAGE_OBJECT);
}

- (BOOL)growingPageHelper_pageDidIgnore {
    NSNumber *isIgnoredObj = objc_getAssociatedObject(self, GROWING_PAGE_OBJECT);
    if (isIgnoredObj) {
        NSLog(@"找到记录的ignored值 ： %d",isIgnoredObj.boolValue);
        return isIgnoredObj.boolValue;
    }
    // judge self firstly
    GrowingIgnorePolicy selfPolicy = self.growingPageIgnorePolicy;
    if (GrowingIgnoreAll == selfPolicy || GrowingIgnoreSelf == selfPolicy) {
        objc_setAssociatedObject(self, GROWING_PAGE_IGNORE, @(YES), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        return YES;
    }
    
    // judge parent
    UIViewController *current = self;
    while (current.parentViewController) {
        UIViewController *parent = current.parentViewController;
        GrowingIgnorePolicy parentPolicy = parent.growingPageIgnorePolicy;
 
        if (GrowingIgnoreChildren == parentPolicy || GrowingIgnoreAll == parentPolicy) {
            objc_setAssociatedObject(self, GROWING_PAGE_IGNORE, @(YES), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
            return YES;
        }
        
        current = parent;
    }
    
    return NO;
}

@end
