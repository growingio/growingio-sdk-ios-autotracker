//
//  GrowingNode.m
//  GrowingTracker
//
//  Created by GrowingIO on 15/12/12.
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


#import "GrowingNode.h"
#import "GrowingPropertyDefine.h"
#import "GrowingPageManager.h"
#import "UIApplication+GrowingHelper.h"
#import "UIApplication+GrowingNode.h"
#import "UIWindow+GrowingNode.h"
#import "UIViewController+GrowingNode.h"
#import "UIViewController+GrowingAutoTrack.h"
#import "UIImage+GrowingHelper.h"
#import "UIViewController+GrowingNode.h"
#import "UIWindow+GrowingNode.h"

@implementation NSObject (GrowingNode)

static char growingNodeIsBadNodeKey;
- (BOOL)growingNodeIsBadNode {
    return objc_getAssociatedObject(self, &growingNodeIsBadNodeKey) != nil;
}

- (void)setGrowingNodeIsBadNode:(BOOL)growingNodeIsBadNode {
    objc_setAssociatedObject(self, &growingNodeIsBadNodeKey,
                             growingNodeIsBadNode ? @"yes" : nil,
                             OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end

@implementation GrowingRootNode

- (UIImage *)growingNodeScreenShot:(UIImage *)fullScreenImage {
    return nil;
}

- (UIImage *)growingNodeScreenShotWithScale:(CGFloat)maxScale {
    return nil;
}

+ (instancetype)rootNode {
    static id node = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        node = [[self alloc] init];
    });
    return node;
}

// 原始父节点
- (id<GrowingNode>)growingNodeParent {
    return nil;
}

- (BOOL)growingNodeDonotTrack {
    return NO;
}

- (BOOL)growingNodeDonotCircle {
    return NO;
}

// 值
- (BOOL)growingNodeUserInteraction {
    return NO;
}
- (NSString *)growingNodeName {
    return @"根节点";
}
- (NSString *)growingNodeContent {
    return nil;
}

- (NSDictionary *)growingNodeDataDict {
    return [[[GrowingPageManager sharedInstance] currentViewController]
        growingNodeDataDict];
}

- (UIWindow *)growingNodeWindow {
    return nil;
}

- (CGRect)growingNodeFrame {
    return CGRectZero;
}

- (NSString *)growingNodeUniqueTag {
    return nil;
}

- (NSArray<id<GrowingNode>> * _Nullable)growingNodeChilds {
    return nil;
}

- (NSIndexPath *)growingNodeIndexPath {
    return nil;
}

- (NSString *)growingNodeSubPath {
    return nil;
}

- (NSString *)growingNodeSubSimilarPath {
    return nil;
}

- (NSInteger)growingNodeKeyIndex {
    return 0;
}

@end

@interface GrowingDullNode ()

// NOTE: all weak pointers are nil
//       if you want to hold something, make it 'retain'
@property (nonatomic, weak) id<GrowingNode> growingNodeParent;
@property (nonatomic, assign) BOOL growingNodeDonotTrack;
@property (nonatomic, assign) BOOL growingNodeDonotCircle;
@property (nonatomic, assign) BOOL growingNodeUserInteraction;
@property (nonatomic, copy) NSString *growingNodeName;
@property (nonatomic, copy) NSString *growingNodeContent;
@property (nonatomic, weak) NSNumber *growingNodeIndex;
@property (nonatomic, weak) NSDictionary *growingNodeDataDict;
@property (nonatomic, weak) UIWindow *growingNodeWindow;
@property (nonatomic, assign) CGRect growingNodeFrame;

@property (nonatomic, copy) NSString *growingNodeXPath;
@property (nonatomic, copy) NSString *growingNodePatternXPath;
@property (nonatomic, assign) NSInteger growingNodeKeyIndex;
@property (nonatomic, copy) NSString *growingNodeHyperlink;
@property (nonatomic, copy) NSString *growingNodeType;

@end

@implementation GrowingDullNode

- (instancetype)initWithName:(NSString *)name
                  andContent:(NSString *)content
          andUserInteraction:(BOOL)userInteraction
                    andFrame:(CGRect)frame
                 andKeyIndex:(NSInteger)keyIndex
                    andXPath:(NSString *)xPath
             andPatternXPath:(NSString *)patternXPath
                andHyperlink:(NSString *)hyperlink
                 andNodeType:(NSString *)nodeType
      andSafeAreaInsetsValue:(NSValue *)safeAreaInsetsValue
    isHybridTrackingEditText:(BOOL)isHybridTrackingEditText {
    self = [super init];
    if (self) {
        self.growingNodeParent = nil;
        self.growingNodeDonotTrack = NO;
        self.growingNodeDonotCircle = NO;
        self.growingNodeUserInteraction = userInteraction;
        self.growingNodeName = name;
        self.growingNodeContent = content;
        self.growingNodeIndex = nil;
        self.growingNodeDataDict = nil;
        self.growingNodeWindow = nil;
        self.growingNodeFrame = frame;
        self.growingNodeXPath = xPath;
        self.growingNodePatternXPath = patternXPath;
        self.growingNodeKeyIndex = keyIndex;
        self.growingNodeHyperlink = hyperlink;
        self.growingNodeType = nodeType;
        self.safeAreaInsetsValue = safeAreaInsetsValue;
        self.isHybridTrackingEditText = isHybridTrackingEditText;
    }
    return self;
}

// 截图
- (UIImage *)growingNodeScreenShot:(UIImage *)fullScreenImage {
    CGRect frame = [self growingNodeFrame];
    if (self.safeAreaInsetsValue) {
        UIEdgeInsets safeAreaInsets =
            self.safeAreaInsetsValue.UIEdgeInsetsValue;
        frame.origin.y += safeAreaInsets.top;
    }
    UIImage *image = [fullScreenImage growingHelper_getSubImage:frame];
    return image;
}

- (UIImage *)growingNodeScreenShotWithScale:(CGFloat)maxScale {
    return nil;
}

- (NSString *)growingNodeUniqueTag {
    return nil;
}

- (NSArray<id<GrowingNode>> * _Nullable)growingNodeChilds {
    return nil;
}

- (NSIndexPath *)growingNodeIndexPath {
    return nil;
}

- (NSString *)growingNodeSubPath {
    return nil;
}

- (NSString *)growingNodeSubSimilarPath {
    return nil;
}

@end
