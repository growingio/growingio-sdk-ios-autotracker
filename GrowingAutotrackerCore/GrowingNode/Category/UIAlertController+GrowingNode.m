//
//  UIAlertController+GrowingNode.m
//  GrowingAnalytics
//
//  Created by GrowingIO on 15/12/15.
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
#import "GrowingAutotrackerCore/Autotrack/UIAlertController+GrowingAutotracker.h"
#import "GrowingAutotrackerCore/GrowingNode/Category/UIAlertController+GrowingNode.h"
#import "GrowingAutotrackerCore/GrowingNode/Category/UIView+GrowingNode.h"
#import "GrowingTrackerCore/Helpers/GrowingHelpers.h"

@implementation UIAlertController (GrowingNode)

- (CGRect)growingNodeFrame {
    return [self.view growingNodeFrame];
}

@end

@implementation GrowingAlertSwizzleHelper

+ (void)addAutoTrackSwizzles {
    unsigned int count = 0;
    Method *methods = class_copyMethodList(self, &count);
    NSMutableArray *classes = [[NSMutableArray alloc] init];
    NSArray *classNames = @[
        [NSString stringWithFormat:@"_UI%@Controller%@", @"Alert", @"CollectionViewCell"],  // iOS 9
        [NSString stringWithFormat:@"_UI%@Controller%@View", @"Alert", @"Action"]           // iOS 10(+)
    ];
    for (NSString *clsname in classNames) {
        Class clazz = NSClassFromString(clsname);
        if (clazz) {
            [classes addObject:clazz];
        }
    }
    if (methods) {
        for (unsigned int i = 0; i < count; i++) {
            Method method = methods[i];
            for (Class clazz in classes) {
                class_addMethod(clazz,
                                method_getName(method),
                                method_getImplementation(method),
                                method_getTypeEncoding(method));
            }
        }
    }
    free(methods);
}

- (NSString *)growingNodeSubPath {
    return @"Button";
}

- (NSString *)growingNodeSubIndex {
    NSString *subIndex = @"0";
    UIViewController *responderVC = [self growingHelper_viewController];
    if ([responderVC isKindOfClass:UIAlertController.class]) {
        UIAlertController *alertVC = (UIAlertController *)responderVC;
        UIAlertAction *action = [UIAlertController growing_actionForActionView:(id)self];
        NSInteger index = -1;
        if (alertVC.actions && action) {
            index = [alertVC.actions indexOfObject:action];
        }
        if (index >= 0) {
            subIndex = [NSString stringWithFormat:@"%ld", (long)index];
        }
    }

    return subIndex;
}

- (BOOL)growingViewUserInteraction {
    return YES;
}

- (NSString *)growingNodeContent {
    return [[UIAlertController growing_actionForActionView:(id)self] title];
}

@end
