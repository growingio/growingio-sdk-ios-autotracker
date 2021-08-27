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

#import "UIAlertController+GrowingNode.h"
#import <objc/runtime.h>
#import "NSObject+GrowingIvarHelper.h"
#import "UIView+GrowingNode.h"
#import "UIAlertController+GrowingAutotracker.h"
#import "UIView+GrowingHelper.h"

@implementation UIAlertController (GrowingNode)

- (CGRect)growingNodeFrame {
    return [self.view growingNodeFrame];
}

- (NSArray <id <GrowingNode> > *)growingNodeChilds {
    NSMutableArray *childs = [NSMutableArray array];
    NSMapTable *allButton = [self growing_allActionViews];
    for (UIView *view in  [allButton keyEnumerator]) {
        [childs addObject:view];
    }
    
    UIView *view = nil;
    if ([self.view growingHelper_getIvar:"_titleLabel" outObj:&view]) {
        [childs addObject:view];
    }
    if ([self.view growingHelper_getIvar:"_messageLabel" outObj:&view]) {
        [childs addObject:view];
    }
    
    return childs;
}

@end


@implementation GrowingAlertVCActionView

+ (void)load {
    unsigned int count = 0;
    Method *methods = class_copyMethodList(self, &count);
    NSMutableArray *classes = [[NSMutableArray alloc] init];
    NSArray *classNames= @[[NSString stringWithFormat:@"_UI%@Controller%@",@"Alert",@"CollectionViewCell"],[NSString stringWithFormat:@"_UI%@Controller%@View",@"Alert",@"Action"]];
    for (NSString *clsname  in classNames) {
        Class clazz = NSClassFromString(clsname);
        if (clazz) {
            [classes addObject:clazz];
        }
    }
    for (unsigned int i = 0 ; i < count ; i++) {
        Method method = methods[i];
        for (Class clazz in classes) {
            class_addMethod(clazz,
                            method_getName(method),
                            method_getImplementation(method),
                            method_getTypeEncoding(method));
        }
    }
    free(methods);
}


- (NSString *)growingNodeSubPath {
    
    NSString *subpath = @"Button";
    
    UIViewController *responderVC = [self growingHelper_viewController];
    if ([responderVC isKindOfClass:UIAlertController.class]) {
        UIAlertController *alertVC = (UIAlertController *)responderVC;
        
        UIAlertAction *action = [UIAlertController growing_actionForActionView:(id)self];
        NSInteger index = -1;
        if (alertVC.actions && action) {
            index = [alertVC.actions indexOfObject:action];
        }
        subpath = (index < 0) ? subpath : [NSString stringWithFormat:@"Button[%ld]", (long)index];
    }
    
    return subpath;
}


- (BOOL)growingNodeUserInteraction {
    return YES;
}

- (NSString *)growingNodeName {
    return @"弹出框选项";
}

- (NSString *)growingNodeContent {
    NSString *nodeContent = [[UIAlertController growing_actionForActionView:(id)self] title];
    
    if (nodeContent.length) {
        return nodeContent;
    } else {
        return self.accessibilityLabel;
    }
}


@end
