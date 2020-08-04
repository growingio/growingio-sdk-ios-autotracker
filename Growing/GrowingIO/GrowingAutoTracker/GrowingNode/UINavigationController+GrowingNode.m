//
//  UINavigationController+GrowingNode.m
//  GrowingTracker
//
//  Created by GrowingIO on 15/9/10.
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


#import "UINavigationController+GrowingNode.h"
#import <objc/runtime.h>
@implementation UINavigationController (GrowingNode)

- (NSArray<id<GrowingNode>>*)growingNodeChilds {
    NSMutableArray *childs = [NSMutableArray array];
    [childs addObjectsFromArray:self.childViewControllers];
    [childs addObject:self.navigationBar];
    return childs;
}

@end


@implementation GrowingNavigationBarBackButton

+ (void)load {
    unsigned int count = 0;
    Method *methods = class_copyMethodList(self, &count);
    NSMutableArray *classes = [[NSMutableArray alloc] init];
    Class clazz = NSClassFromString([NSString stringWithFormat:@"UI%@Item%@View",@"Navigation",@"Button"]);
    if (clazz) {
        [classes addObject:clazz];
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

- (BOOL)growingNodeUserInteraction {
    return YES;
}

- (NSString*)growingNodeName {
    return @"返回按钮";
}

@end
