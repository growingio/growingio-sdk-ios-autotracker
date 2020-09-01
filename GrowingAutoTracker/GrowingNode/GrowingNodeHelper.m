//
//  GrowingNodeHelper.m
//  GrowingAnalytics
//
//  Created by sheng on 2020/8/20.
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

#import "GrowingNodeHelper.h"
#import "UIView+GrowingNode.h"
#import "UIViewController+GrowingNode.h"
#import "GrowingPageManager.h"
#import "GrowingPageGroup.h"
#import "UIViewController+GrowingPageHelper.h"
#import "GrowingCocoaLumberjack.h"

@implementation GrowingNodeHelper

+ (NSString *)xPathForNode:(id<GrowingNode>)node {
    if ([node isKindOfClass:[UIView class]]) {
        return [self xPathForView:(UIView*)node];;
    }else if ([node isKindOfClass:[UIViewController class]]) {
        return [self xPathForViewController:(UIViewController*)node];;
    }
    return nil;
}

+ (NSString *)xPathForView:(UIView *)view {
    NSMutableArray *viewPathArray = [NSMutableArray array];
    id<GrowingNode> node = view;
    do {
        id<GrowingNode> parent = node.growingNodeParent;
        if ([parent isKindOfClass:[UIViewController class]]) {
            [viewPathArray addObject:@"Page"];
            break;
        }
        if ([parent isEqual:((UIView*)node).nextResponder]) { //如果父节点和nextResponder一致，说明没有进行跨度取值
            if ([parent isKindOfClass:[UIViewController class]]) {
                [viewPathArray addObject:@"Page"];
                break;
            }else {
                [viewPathArray addObject:node.growingNodeSubPath];
            }
        }else {
            [viewPathArray addObject:node.growingNodeSubPath];
        }
        
        node = parent;
    } while (node);
    NSString *viewPath = [[[viewPathArray reverseObjectEnumerator] allObjects] componentsJoinedByString:@"/"];
    viewPath = [@"/" stringByAppendingString:viewPath];
    return viewPath;
}


+ (NSString *)xPathForViewController:(UIViewController *)vc {
    UIViewController *parent = vc;
    if (parent) {
        GrowingPageGroup *page = [parent growingPageHelper_getPageObject];
        if (!page) {
            GIOLogError(@"%@(%@)未发送Page事件，重新获取并发送",page.carrier,page.carrier.class);
            [[GrowingPageManager sharedInstance] createdViewControllerPage:parent];
            page = [parent growingPageHelper_getPageObject];
        }
        return page.path;
    }
    return nil;
}


@end
