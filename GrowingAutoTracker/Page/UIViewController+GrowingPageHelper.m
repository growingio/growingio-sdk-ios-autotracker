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

static void *const GROWING_PAGE_OBJECT = "GROWING_PAGE_OBJECT";

@implementation UIViewController (GrowingPageHelper)

- (void)growingPageHelper_setPageObject:(GrowingPageGroup *)page {
    objc_setAssociatedObject(self, GROWING_PAGE_OBJECT, page, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (GrowingPageGroup *)growingPageHelper_getPageObject {
    return objc_getAssociatedObject(self, GROWING_PAGE_OBJECT);
}

- (BOOL)growingPageHelper_pageDidIgnore {
    GrowingIgnorePolicy selfPolicy = self.growingPageIgonrePolicy;
    GrowingIgnorePolicy parentPolicy = self.parentViewController.growingPageIgonrePolicy;
    
    if (selfPolicy == GrowingIgnoreNone &&
        (parentPolicy == GrowingIgnoreNone || parentPolicy == GrowingIgnoreSelf)) {
        return NO;
    }
    
    if (selfPolicy == GrowingIgnoreChild &&
        (parentPolicy == GrowingIgnoreNone || parentPolicy == GrowingIgnoreSelf)) {
        return NO;
    }
    
    return YES;
}

@end
