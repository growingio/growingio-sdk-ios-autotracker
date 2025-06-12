//
//  GrowingDeepLinkHandler+XCTest.m
//  GrowingAnalytics
//
//  Created by YoloMao on 2022/6/15.
//  Copyright (C) 2022 Beijing Yishu Technology Co., Ltd.
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

#import "GrowingDeepLinkHandler+XCTest.h"
#import "GrowingTrackerCore/DeepLink/GrowingDeepLinkHandler+Private.h"
#import <UIKit/UIKit.h>
#import <objc/runtime.h>

@implementation GrowingDeepLinkHandler (XCTest)

+ (void)load {
    SEL originSelector = @selector(handleURL:);
    SEL swizzleSelector = @selector(XCTest_handleURL:);
    
    id handler = object_getClass(self);
    
    Method originMethod = class_getInstanceMethod(handler, originSelector);
    if (!originMethod) {
        return;
    }
    Method swizzleMethod = class_getInstanceMethod(handler, swizzleSelector);
    if (!swizzleMethod) {
        return;
    }
    class_addMethod(handler,
                    originSelector,
                    class_getMethodImplementation(handler, originSelector),
                    method_getTypeEncoding(originMethod));
    class_addMethod(handler,
                    swizzleSelector,
                    class_getMethodImplementation(handler, swizzleSelector),
                    method_getTypeEncoding(swizzleMethod));
    
    method_exchangeImplementations(class_getInstanceMethod(handler, originSelector),
                                   class_getInstanceMethod(handler, swizzleSelector));
}

+ (BOOL)XCTest_handleURL:(NSURL *)url {
    if ([url.absoluteString containsString:@"xctest=DeepLinkTest"]) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            UIAlertController *controller = [UIAlertController alertControllerWithTitle:@"XCTest_handleURL"
                                                                                message:@""
                                                                         preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"XCTest" style:UIAlertActionStyleCancel handler:nil];
            [controller addAction:cancel];
            [self.XCTest_keywindow.rootViewController presentViewController:controller animated:YES completion:nil];
        });
    }
    
    return [self XCTest_handleURL:url];
}

+ (UIWindow *)XCTest_keywindow {
    UIWindow *window = nil;
#if __IPHONE_OS_VERSION_MIN_REQUIRED < 130000
    if (@available(iOS 13.0, *)) {
#endif
        NSArray<__kindof UIWindow *> *windows = UIApplication.sharedApplication.windows;
        for (UIWindow *w in windows) {
            if (w.isKeyWindow) {
                window = w;
                break;
            }
        }
#if __IPHONE_OS_VERSION_MIN_REQUIRED < 130000
    } else {
        window = UIApplication.sharedApplication.keyWindow;
    }
#endif
    return window;
}

@end
