//
//  NodeTest.m
//  GrowingAnalytics
//
//  Created by YoloMao on 2021/12/31.
//  Copyright (C) 2021 Beijing Yishu Technology Co., Ltd.
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

#import <XCTest/XCTest.h>

@interface NodeTest : XCTestCase

@end

@implementation NodeTest

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testGrowingUIViewController {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
    UIViewController *vc1 = [[UIViewController alloc] init];
    [vc1 performSelector:@selector(growingNodeParent)];
    [vc1 performSelector:@selector(growingNodeKeyIndex)];
    [vc1 performSelector:@selector(growingNodeSubPath)];
    [vc1 performSelector:@selector(growingNodeSubIndex)];
    [vc1 performSelector:@selector(growingNodeSubSimilarIndex)];
#pragma clang diagnostic pop
}

- (void)testGrowingUICollectionView {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.headerReferenceSize = CGSizeMake(10, 10);
    layout.itemSize = CGSizeMake(110, 150);

    UICollectionView *view1 = [[UICollectionView alloc] initWithFrame:UIScreen.mainScreen.accessibilityFrame
                                                 collectionViewLayout:layout];
    UICollectionViewCell *cell = [[UICollectionViewCell alloc] init];
    [view1 performSelector:@selector(growingNodeChilds)];
    [cell performSelector:@selector(growingNodeKeyIndex)];
    [cell performSelector:@selector(growingNodeSubPath)];
    [cell performSelector:@selector(growingNodeSubIndex)];
    [cell performSelector:@selector(growingNodeSubSimilarIndex)];
    [cell performSelector:@selector(growingNodeDonotCircle)];
    [cell performSelector:@selector(growingNodeUserInteraction)];
    [cell performSelector:@selector(growingViewUserInteraction)];
    [cell performSelector:@selector(growingNodeDonotCircle)];
    [cell performSelector:@selector(growingNodeUserInteraction)];
    [cell performSelector:@selector(growingViewUserInteraction)];
#pragma clang diagnostic pop
}

- (void)testGrowingUIView {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
    UIView *view2 = [[UIView alloc] init];
    [view2 performSelector:@selector(growingNodeKeyIndex)];
    [view2 performSelector:@selector(growingNodeSubPath)];
    [view2 performSelector:@selector(growingNodeSubIndex)];
    [view2 performSelector:@selector(growingNodeSubSimilarIndex)];
    [view2 performSelector:@selector(growingNodeChilds)];
    [view2 performSelector:@selector(growingNodeParent)];
    [view2 performSelector:@selector(growingViewNodeIsInvisible)];
    [view2 performSelector:@selector(growingImpNodeIsVisible)];
    [view2 performSelector:@selector(growingNodeDonotTrack)];
    [view2 performSelector:@selector(growingViewDontTrack)];
    [view2 performSelector:@selector(growingNodeDonotCircle)];
    [view2 performSelector:@selector(growingViewContent)];
    [view2 performSelector:@selector(growingNodeUserInteraction)];
    [view2 performSelector:@selector(growingViewUserInteraction)];
    [view2 performSelector:@selector(growingIMPTracked)];
    [view2 performSelector:@selector(growingIMPTrackEventName)];
    [view2 performSelector:@selector(growingIMPTrackVariable)];
    [view2 performSelector:@selector(growingViewIgnorePolicy)];
    [view2 performSelector:@selector(growingStopTrackImpression)];
#pragma clang diagnostic pop
}

@end
