//
// WebSocketTests.m
// ExampleTests
//
//  Created by GrowingIO on 3/1/21.
//  Copyright (C) 2017 Beijing Yishu Technology Co., Ltd.
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
#import <KIF/KIF.h>
#import "UIImage+GrowingHelper.h"
#import "UIWindow+GrowingHelper.h"
#import "GrowingStatusBarEventManager.h"
#import "GrowingHybridPageEvent.h"
#import "GrowingHybridCustomEvent.h"
#import "GrowingPageCustomEvent.h"
#import "GrowingHybridViewElementEvent.h"
#import "GrowingLoginRequest.h"
#import "GrowingNodeItem.h"
#import "GrowingDeepLinkHandler.h"
#import "UIViewController+GrowingNode.h"
#import "UICollectionView+GrowingNode.h"
#import "UIView+GrowingNode.h"
#import "FirstViewController.h"
#import "GrowingDeviceInfo.h"
#import "GrowingFileStorage.h"
#import <WebKit/WebKit.h>


#define KEY_PROTOCOL_TYPE @"UnitTest-protocoltype"
#define KEY_QUERY @"UnitTest-query"
#define KEY_TITLE @"UnitTest-title"
#define KEY_PATH @"UnitTest-path"

#define KEY_TIMESTAMP 11111111
#define KEY_PAGE_SHOW_TIMESTAMP 22222222
#define KEY_DOMAIN @"UnitTest-domain"
#define KEY_ATTRIBUTES @{@"UnitTest-attributes":@"TEST"}
#define KEY_REFERRAL_PAGE @"UnitTest-refferalpage"
#define KEY_EVENT_NAME @"UnitTest-eventname"

@interface WebSocketTests : KIFTestCase

@end

@implementation WebSocketTests

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}


-(void)testImageHelper{
    UIImage *image = [[UIImage alloc]init];
    NSData *data = [image growingHelper_JPEG:0.8];
    [image growingHelper_PNG];
    [image growingHelper_Base64PNG];
    [image growingHelper_Base64JPEG:0.9];
    [image growingHelper_getSubImage:CGRectMake(0.8, 0.8, 0.8, 0.8)];
    
}
-(void)testUIWindowHelper{
    [UIWindow growingHelper_screenshotWithWindows:nil andMaxScale:0.8];
    [UIWindow growingHelper_screenshotWithWindows:nil andMaxScale:0.8 block:nil];
}

-(void)testGrowingStatusBarEventManager{
    [[GrowingStatusBarEventManager sharedInstance] dispatchTapStatusBar:nil];
    [[GrowingStatusBarEventManager sharedInstance] addStatusBarObserver:self];
    [[GrowingStatusBarEventManager sharedInstance] removeStatusBarObserver:self];
}
-(void)testGrowingHybridPageEvent{
    [GrowingHybridPageEvent builder];
    
    GrowingHybridPageEvent.builder.setProtocolType(KEY_PROTOCOL_TYPE)
    .setQuery(KEY_QUERY)
    .setTitle(KEY_TITLE)
    .setReferralPage(KEY_REFERRAL_PAGE)
    .setPath(KEY_PATH)
    .setTimestamp(KEY_TIMESTAMP)
    .setDomain(KEY_DOMAIN);
}


-(void)testGrowingHybridCustomEvent{
    [GrowingHybridCustomEvent builder];
    GrowingHybridCustomEvent.builder.setQuery(KEY_QUERY)
    .setPath(KEY_PATH)
    .setPageShowTimestamp(KEY_PAGE_SHOW_TIMESTAMP)
    .setAttributes(KEY_ATTRIBUTES)
    .setEventName(KEY_EVENT_NAME)
    .setDomain(KEY_DOMAIN);
}

-(void)testGrowingPageCustomEvent{
    [GrowingPageCustomEvent builder];
    [GrowingPageCustomEvent builder].setPath(KEY_PATH)
    .setEventName(KEY_EVENT_NAME)
    .setAttributes(KEY_ATTRIBUTES)
    .setPageShowTimestamp(KEY_PAGE_SHOW_TIMESTAMP);
}

-(void)testGrowingHybridViewElementEvent{
    [GrowingHybridViewElementEvent builder];
    GrowingHybridViewElementEvent.builder.setQuery(KEY_QUERY)
    .setPath(KEY_PATH)
    .setPageShowTimestamp(KEY_PAGE_SHOW_TIMESTAMP)
    .setHyperlink(@"Hyperlink")
    .setEventType(@"KEY_EVENT_Type")
    .setXpath(@"Xpath")
    .setIndex(0)
    .setDomain(KEY_DOMAIN);
}

-(void)testGrowingLoginRequest{
    
    [GrowingLoginRequest loginRequestWithHeader:@{@"header":@"h1"} parameter:@{@"parameter":@"p1"}];
    [GrowingWebSocketRequest webSocketRequestWithParameter:@{@"param":@"p2"}];
}
-(void)testGrowingNodeItem{
    [GrowingNodeItemComponent indexNotFound];
    [GrowingNodeItemComponent indexNotDefine];
    
}
-(void)testGrowingDeepLinkHandler{
    NSURL *url1 = [NSURL URLWithString:@"http://test.growingio.com/oauth2/qrcode.html?URLScheme=growing.test&productId=test&circleRoomNumber=test0f4cfa51ff3f&serviceType=circle&appName=GrowingIO&wsUrl=    ws://cdp.growingio.com/app/test/circle/test0f4cfa51ff3f"];

    [GrowingDeepLinkHandler handlerUrl:url1];
}
-(void)testGrowingUIViewController{
    UIViewController *vc1 = [[FirstViewController alloc]init];
    [vc1 performSelector:@selector(growingNodeParent)];
    //growingAppearStateCanTrack
    [vc1 performSelector:@selector(growingAppearStateCanTrack)];
    [vc1 performSelector:@selector(growingNodeDonotTrack)];
    [vc1 performSelector:@selector(growingNodeDonotCircle)];
    [vc1 performSelector:@selector(growingNodeUserInteraction)];
    [vc1 performSelector:@selector(growingNodeName)];
    [vc1 performSelector:@selector(growingNodeContent)];
    [vc1 performSelector:@selector(growingNodeDataDict)];
    [vc1 performSelector:@selector(growingNodeWindow)];
    [vc1 performSelector:@selector(growingNodeUniqueTag)];
    [vc1 performSelector:@selector(growingNodeKeyIndex)];
    [vc1 performSelector:@selector(growingNodeSubPath)];
    [vc1 performSelector:@selector(growingNodeSubSimilarPath)];
    [vc1 performSelector:@selector(growingNodeIndexPath)];
    [vc1 performSelector:@selector(growingNodeChilds)];
    [vc1 performSelector:@selector(growingPageIgnorePolicy)];

}

-(void)testGrowingUICollectionView{
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    //设置collectionView滚动方向
    //[layout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    //设置headerView的尺寸大小
    layout.headerReferenceSize = CGSizeMake(10, 10);
    //该方法也可以设置itemSize
    layout.itemSize = CGSizeMake(110, 150);

    UICollectionView *view1 = [[UICollectionView alloc] initWithFrame:UIScreen.mainScreen.accessibilityFrame collectionViewLayout:layout];
    UICollectionViewCell *cell = [[UICollectionViewCell alloc]init];
    [view1 performSelector:@selector(growingNodeChilds)];
    [cell performSelector:@selector(growingNodeKeyIndex)];
    [cell performSelector:@selector(growingNodeIndexPath)];
    [cell performSelector:@selector(growingNodeSubPath)];
    [cell performSelector:@selector(growingNodeSubSimilarPath)];
    [cell performSelector:@selector(growingNodeDonotCircle)];
    [cell performSelector:@selector(growingNodeUserInteraction)];
    [cell performSelector:@selector(growingViewUserInteraction)];
    [cell performSelector:@selector(growingNodeName)];
    [cell performSelector:@selector(growingNodeDonotCircle)];
    [cell performSelector:@selector(growingNodeUserInteraction)];
    [cell performSelector:@selector(growingViewUserInteraction)];

}

-(void)testGrowingUIView{
    UIView *view2 = [[UIView alloc]init];
    [view2 performSelector:@selector(growingNodeIndexPath)];
    [view2 performSelector:@selector(growingNodeKeyIndex)];
    [view2 performSelector:@selector(growingNodeSubPath)];
    [view2 performSelector:@selector(growingNodeSubSimilarPath)];
    [view2 performSelector:@selector(growingNodeChilds)];
    [view2 performSelector:@selector(growingNodeParent)];
    [view2 performSelector:@selector(growingViewNodeIsInvisiable)];
    [view2 performSelector:@selector(growingImpNodeIsVisible)];
    [view2 performSelector:@selector(growingNodeDonotTrack)];
    [view2 performSelector:@selector(growingViewDontTrack)];
    [view2 performSelector:@selector(growingNodeSubPath)];
    [view2 performSelector:@selector(growingNodeDonotCircle)];
    [view2 performSelector:@selector(growingNodeName)];
    [view2 performSelector:@selector(growingViewContent)];
    [view2 performSelector:@selector(growingNodeUserInteraction)];
    [view2 performSelector:@selector(growingViewUserInteraction)];
    [view2 performSelector:@selector(growingNodeDataDict)];
    [view2 performSelector:@selector(growingNodeWindow)];
    [view2 performSelector:@selector(growingNodeUniqueTag)];
    [view2 performSelector:@selector(growingViewCustomContent)];
    [view2 performSelector:@selector(growingIMPTracked)];
    [view2 performSelector:@selector(growingIMPTrackEventName)];
    [view2 performSelector:@selector(growingIMPTrackVariable)];
    [view2 performSelector:@selector(growingViewIgnorePolicy)];
    [view2 performSelector:@selector(growingStopTrackImpression)];

}


-(void)testGrowingDeviceInfo{
    [[GrowingDeviceInfo currentDeviceInfo] deviceInfoReported];
    [[GrowingDeviceInfo currentDeviceInfo] pasteboardDeeplinkReported];
    [GrowingDeviceInfo deviceScreenSize];
}


-(void)testGrowingFileStorage{
    [[[GrowingFileStorage alloc]initWithName:@"testGrowingFileStorage"] resetAll];
    [[[GrowingFileStorage alloc]initWithName:@"testGrowingFileStorage"] removeKey:@"testKey"];
    [[[GrowingFileStorage alloc]initWithName:@"testGrowingFileStorage"] setArray:@[@"testa",@"testb"] forKey:@"testKey"];
    [[[GrowingFileStorage alloc]initWithName:@"testGrowingFileStorage"] arrayForKey:@"testKey"];
    [[[GrowingFileStorage alloc]initWithName:@"testGrowingFileStorage"] setNumber:@1 forKey:@"testKeyNum"];
    XCTAssertNotNil( [[[GrowingFileStorage alloc]initWithName:@"testGrowingFileStorage"] numberForKey:@"testKeyNum"]);



}

@end
