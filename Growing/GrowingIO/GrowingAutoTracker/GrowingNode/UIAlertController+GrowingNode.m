//
//  UIAlertController+GrowingNode.m
//  GrowingTracker
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

@implementation UIAlertController (GrowingNode)

- (CGRect)growingNodeFrame {
    return [self.view growingNodeFrame];
}


- (NSMapTable*)growing_allActionViews
{
    UICollectionView *collectionView = [self growing_collectionView];
    NSMapTable *retMap = [[NSMapTable alloc] initWithKeyOptions:NSPointerFunctionsStrongMemory
                                                valueOptions:NSPointerFunctionsStrongMemory
                                                    capacity:4];
    // ios9以及以下时，包含actionView
    // 获取UIAlert中的TextField等元素，以collectionView为容器
    if (collectionView) {
        [[collectionView indexPathsForVisibleItems] enumerateObjectsUsingBlock:^(NSIndexPath * _Nonnull obj,
                                                                                 NSUInteger idx,
                                                                                 BOOL * _Nonnull stop) {
            UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:obj];
            if (cell)
            {
                [retMap setObject:[NSNumber numberWithInteger:obj.row] forKey:cell];
            }
        }];
    }
    //  ios10以及以上
    // 获取actionViews
    NSArray *views = nil;
    if ([self.view growingHelper_getIvar:"_actionViews" outObj:&views]) {
        [views enumerateObjectsUsingBlock:^(UIView *obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [retMap setObject:[NSNumber numberWithInteger:idx] forKey:obj];
        }];
    }
    return retMap;
}

- (UICollectionView*)growing_collectionView
{
    return [self growing_alertViewCollectionView:self.view];
}

- (UICollectionView*)growing_alertViewCollectionView:(UIView*)view
{
    for (UIView *subview in view.subviews)
    {
        if ([subview isKindOfClass:[UICollectionView class]])
        {
            return (UICollectionView*)subview;
        }
        else
        {
            UICollectionView *ret = [self growing_alertViewCollectionView:subview];
            if (ret)
            {
                return ret;
            }
        }

    }
    return nil;
}

- (NSArray<id<GrowingNode>>*)growingNodeChilds {
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

+ (UIAlertAction*)growing_actionForActionView:(UIView*)actionView
{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    NSString *viewSelectorString = [NSString stringWithFormat:@"a%@ion%@w", @"ct", @"Vie"];
    if ([actionView respondsToSelector:NSSelectorFromString(viewSelectorString)]) {
        actionView = [actionView performSelector:NSSelectorFromString(viewSelectorString)];
    }
#pragma clang diagnostic pop
    UIAlertAction *action = nil;
    if ([actionView respondsToSelector:@selector(action)])
    {
        action =[actionView performSelector:@selector(action)];
    }
    return action;
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

- (id<GrowingNode>)growingNodeParent {
    UIResponder *nextNode = self.nextResponder;
    while (nextNode && ![nextNode isKindOfClass:[UIAlertController class]]) {
        nextNode = nextNode.nextResponder;
    }
    return (id<GrowingNode>)nextNode;
}

- (NSString *)growingNodeSubPath {
    // TODO:SubPath index 计算
    UIAlertController *alertVC = (UIAlertController*)[self growingNodeParent];
    UIAlertAction *action = [UIAlertController growing_actionForActionView:(id)self];
    NSInteger index = -1;
    if (alertVC.actions && action) {
        index = [alertVC.actions indexOfObject:action];
    }
    return index < 0
               ? @"Button"
               : [NSString stringWithFormat:@"Button[%ld]", (long)index];
}

// TODO: crash when open it
//- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
//    [super touchesBegan:touches withEvent:event];
//}

- (BOOL)growingNodeUserInteraction
{
    return YES;
}

- (NSString*)growingNodeName
{
    return @"弹出框选项";
}
- (NSString*)growingNodeContent
{
    NSString *nodeContent = [[UIAlertController growing_actionForActionView:(id)self] title];
    
    if (nodeContent.length) {
        return nodeContent;
    } else {
        return self.accessibilityLabel;
    }
}

@end
