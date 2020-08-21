//
//  GrowingWebCircle.m
//  Growing
//
//  Created by GrowingIO on 2020.
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

#import "GrowingWebCircle.h"

#import <JavaScriptCore/JavaScriptCore.h>
#import <UIKit/UIKit.h>
#import <arpa/inet.h>
#import <ifaddrs.h>

#import "GrowingAlert.h"
#import "GrowingAttributesConst.h"
#import "GrowingCocoaLumberjack.h"
#import "GrowingCustomField.h"
#import "GrowingDeviceInfo.h"
#import "GrowingDispatchManager.h"
#import "GrowingEventManager.h"
#import "GrowingEventNodeManager.h"
#import "GrowingHybridBridgeProvider.h"
#import "GrowingInstance.h"
#import "GrowingPageManager.h"
#import "GrowingPageGroup.h"
#import "GrowingStatusBar.h"
#import "GrowingNodeHelper.h"
#import "NSArray+GrowingHelper.h"
#import "NSData+GrowingHelper.h"
#import "NSDictionary+GrowingHelper.h"
#import "NSString+GrowingHelper.h"
#import "UIApplication+GrowingHelper.h"
#import "UIApplication+GrowingNode.h"
#import "UIImage+GrowingHelper.h"
#import "UIViewController+GrowingAutoTrack.h"
#import "UIViewController+GrowingNode.h"
#import "UIViewController+GrowingPageHelper.h"
#import "UIWindow+GrowingHelper.h"
#import "UIWindow+GrowingNode.h"
#import "WKWebView+GrowingAutoTrack.h"
#import "GrowingNetworkConfig.h"

@interface GrowingWeakObject : NSObject
@property (nonatomic, weak) JSContext *context;
@property (nonatomic, weak) id webView;
@end
@implementation GrowingWeakObject
@end

//文本
static NSString *const kGrowingWebCircleText = @"TEXT";
//按钮
static NSString *const kGrowingWebCircleButton = @"BUTTON";
//输入框
static NSString *const kGrowingWebCircleInput = @"INPUT";
//列表元素 - 这里指TableView中的cell元素
static NSString *const kGrowingWebCircleList = @"LIST";
//WKWebView - webview只做标记用，不参与元素定义。
static NSString *const kGrowingWebCircleWebView = @"WEB_VIEW";


@interface GrowingWebCircle () <GrowingSRWebSocketDelegate, GrowingEventManagerObserver>

//表示web和app是否同时准备好数据发送，此时表示可以发送数据
@property (nonatomic, assign) BOOL isReady;
@property (nonatomic, retain) NSTimer *keepAliveTimer;

@property (nonatomic, copy) void (^onReadyBlock)(void);
@property (nonatomic, copy) void (^onFinishBlock)(void);

@property (nonatomic, retain) GrowingStatusBar *statusWindow;

@property (nonatomic, retain) NSMutableArray<NSMutableDictionary *> *cachedEvents;

@property (nonatomic, strong) NSMutableArray *gWebViewArray;
@property (nonatomic, assign) int nodeZLevel;
@property (nonatomic, assign) int zLevel;
@property (nonatomic, assign) unsigned long snapNumber;  //数据发出序列号
@end

@implementation GrowingWebCircle {
    NSMutableArray *tempArray;
}

static GrowingWebCircle *shareInstance = nil;

+ (void)setNeedUpdateScreen {
    // 不用self 不会创建实例
    if ([shareInstance isRunning]) {
        [shareInstance setNeedUpdateScreen];
    }
}

+ (instancetype)shareInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareInstance = [[GrowingWebCircle alloc] init];
    });
    return shareInstance;
}

+ (void)runWithCircleRoomNumber:(NSString *)circleRoomNumber
                     readyBlock:(void (^)(void))readyBlock
                    finishBlock:(void (^)(void))finishBlock {
    [[self shareInstance] runWithCircleRoomNumber:circleRoomNumber readyBlock:readyBlock finishBlock:finishBlock];
}

+ (void)stop {
    [[self shareInstance] stop];
}

+ (BOOL)isRunning {
    return [[self shareInstance] isRunning];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _cachedEvents = [[NSMutableArray alloc] init];
    }
    return self;
}

#pragma mark - actions

- (void)_setNeedUpdateScreen {
    [self sendScreenShot];
}

- (void)setNeedUpdateScreen {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(_setNeedUpdateScreen) object:nil];
    [self performSelector:@selector(_setNeedUpdateScreen) withObject:nil afterDelay:1];
}

#pragma mark - screenShot

- (UIImage *)screenShot {
    CGFloat scale = [[self class] impressScale];

    NSArray *windows = [[UIApplication sharedApplication].growingHelper_allWindowsWithoutGrowingWindow
        sortedArrayUsingComparator:^NSComparisonResult(UIWindow *obj1, UIWindow *obj2) {
            if (obj1.windowLevel == obj2.windowLevel) {
                return NSOrderedSame;
            } else if (obj1.windowLevel > obj2.windowLevel) {
                return NSOrderedDescending;
            } else {
                return NSOrderedAscending;
            }
        }];

    UIImage *image = [UIWindow growingHelper_screenshotWithWindows:windows
                                                       andMaxScale:scale
                                                             block:^(CGContextRef context){
                                                                 //  CGContextSetStrokeColorWithColor(context,[[UIColor
                                                                 //  orangeColor] colorWithAlphaComponent:0.4].CGColor);
                                                                 //  CGContextSetLineWidth(context,1);
                                                             }];

    return image;
}

+ (CGFloat)impressScale {
    CGFloat scale = [UIScreen mainScreen].scale;
    return MIN(scale, 2);
}

#pragma mark - node

- (BOOL)isContainer:(id<GrowingNode>)node {
    return [[self class] isContainer:node];
}

+ (BOOL)isContainer:(id<GrowingNode>)node {
    // if node is like a button
    if ([node growingNodeUserInteraction]) {
        return YES;
    }
    // if node is like a text label
    for (node = [node growingNodeParent]; node != nil; node = [node growingNodeParent]) {
        if ([node growingNodeUserInteraction]) {
            // text label is within a button, so it is not container
            return NO;
        }
    }
    // text label is standalone
    return YES;
}

/*
 Page Json Data is like this:
 {
   "path": "/WebActivity",
   "title": "WebActivity",
   "left": 0,
   "top": 0,
   "width": 720,
   "height": 1520,
   "isIgnored": true
 }
 */
- (NSMutableDictionary *)dictFromPage:(id<GrowingNode>)aNode xPath:(NSString *)xPath {
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    CGRect frame = [aNode growingNodeFrame];
    if (!CGRectEqualToRect(frame, CGRectZero)) {
        CGFloat scale = [[self class] impressScale];
        dict[@"left"] = [NSNumber numberWithInt:(int)(frame.origin.x * scale)];
        dict[@"top"] = [NSNumber numberWithInt:(int)(frame.origin.y * scale)];
        dict[@"width"] = [NSNumber numberWithInt:(int)(frame.size.width * scale)];
        dict[@"height"] = [NSNumber numberWithInt:(int)(frame.size.height * scale)];
    }
    dict[@"path"] = xPath;

    UIViewController *vc = (UIViewController *)aNode;
    if (vc.title) {
        dict[@"title"] = vc.title;
    }

    dict[@"isIgnored"] = @([vc growingPageHelper_pageDidIgnore]);
    return dict;
}

- (NSMutableDictionary *)dictFromNode:(id<GrowingNode>)aNode
                             pageData:(NSDictionary *)pageData
                             keyIndex:(NSInteger)keyIndex
                                xPath:(NSString *)xPath
                          isContainer:(BOOL)isContainer {
   
    if (![aNode growingNodeContent].length && ![aNode growingNodeUserInteraction] &&
        ![aNode isKindOfClass:[WKWebView class]]) {
        return nil;
    }

    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict addEntriesFromDictionary:pageData];
    NSString *v = [aNode growingNodeContent];
    if (!v) {
        v = @"";
    } else {
        v = [v growingHelper_safeSubStringWithLength:50];
    }
    dict[@"content"] =
        [v stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];

    //1. 默认 TEXT
    //2. 判断特殊类型 并赋值
    //3. 不属于上述类型，且可以点击，则为 BUTTON
    //4. 否则以 TEXT 传入
    NSString *nodetype = kGrowingWebCircleText;
    if ([aNode isKindOfClass:NSClassFromString(@"_UIButtonBarButton")] ||
        [aNode isKindOfClass:NSClassFromString(@"_UIModernBarButton")]) {
        nodetype = kGrowingWebCircleButton;
    }else if ([aNode isKindOfClass:[UITextField class]] || [aNode isKindOfClass:[UISearchBar class]] ||
        [aNode isKindOfClass:[UITextView class]]) {
        nodetype = kGrowingWebCircleInput;
    }else if ([aNode isKindOfClass:[UICollectionViewCell class]] || [aNode isKindOfClass:[UITableViewCell class]]) {
        nodetype = kGrowingWebCircleList;
    }else if ([aNode isKindOfClass:[WKWebView class]]){
        nodetype = kGrowingWebCircleWebView;
    }else if ([aNode growingNodeUserInteraction]) {
        nodetype = kGrowingWebCircleButton;
    }

    //为anode元素添加 ，层级属性
    if ([aNode isKindOfClass:[UIView class]]) {
        self.nodeZLevel = aNode.growingNodeWindow.windowLevel;
        self.zLevel = 0;
        [self getElementLevelInWindow:aNode andWindow:aNode.growingNodeWindow];
        dict[@"zLevel"] = [NSNumber numberWithInt:self.zLevel];
    }

    if (keyIndex >= 0) {
        dict[@"index"] = [NSString stringWithFormat:@"%ld", (long)keyIndex];
    }
    dict[@"xpath"] = xPath;

    CGRect frame = [aNode growingNodeFrame];
    if (!CGRectEqualToRect(frame, CGRectZero)) {
        CGFloat scale = [[self class] impressScale];
        dict[@"left"] = [NSNumber numberWithInt:(int)(frame.origin.x * scale)];
        dict[@"top"] = [NSNumber numberWithInt:(int)(frame.origin.y * scale)];
        dict[@"width"] = [NSNumber numberWithInt:(int)(frame.size.width * scale)];
        dict[@"height"] = [NSNumber numberWithInt:(int)(frame.size.height * scale)];
    }else {
        GIOLogError(@"Node (%@) frame is CGRectZero",aNode);
        return nil;
    }
    dict[@"nodeType"] = nodetype;
    dict[@"isContainer"] = @(isContainer);
    return dict;
}

- (void)getElementLevelInWindow:(id<GrowingNode>)aNode andWindow:(UIView *)superView {
    for (int i = 0; i < superView.subviews.count; i++) {
        self.nodeZLevel++;
        if (superView.subviews[i] == aNode) {
            self.zLevel = self.nodeZLevel;
        } else {
            [self getElementLevelInWindow:aNode andWindow:superView.subviews[i]];
        }
    }
}

- (unsigned long)getSnapshotKey {
    @synchronized(self) {
        _snapNumber++;
    }
    return _snapNumber;
}

//获取 WebView
- (GrowingWeakObject *)getHitWebview:(CGPoint)point {
    for (GrowingWeakObject *weakObjc in self.gWebViewArray) {
        if ([self isInView:weakObjc.webView andPoint:point]) {
            return weakObjc;
        }
    }
    return nil;
}

//判断点是否在视图内
- (BOOL)isInView:(UIView *)view andPoint:(CGPoint)point {
    if (CGRectContainsPoint(view.frame, point)) {
        return YES;
    } else {
        return NO;
    }
}

//存储webview数组
- (NSMutableArray *)gWebViewArray {
    if (!_gWebViewArray) {
        tempArray = [NSMutableArray array];
        _gWebViewArray = tempArray;
    }
    return _gWebViewArray;
}

- (void)fillAllViewsForWebCircle:(NSDictionary *)dataDict completion:(void (^)(NSMutableDictionary *dict))completion {
    NSMutableArray *elements = [[NSMutableArray alloc] init];
    GrowingNodeManager *manager = [[GrowingNodeManager alloc]
        initWithNodeAndParent:[GrowingPageManager sharedInstance].rootViewController
                   checkBlock:^BOOL(id<GrowingNode> node) {
                       if ([node growingNodeDonotTrack] || [node growingNodeDonotCircle]) {
                           GIOLogDebug(@"WebCircle Donot : %@", NSStringFromClass([node class]));
                           return NO;
                       } else {
                           return YES;
                       }
                   }];

    NSMutableDictionary *modifiedPageData = [[NSMutableDictionary alloc] init];
    modifiedPageData[@"page"] = [[[GrowingPageManager sharedInstance] currentViewController] growingPageName] ?: @"";
    modifiedPageData[@"domain"] = [GrowingDeviceInfo currentDeviceInfo].bundleID;

    NSMutableDictionary *finalDataDict = [NSMutableDictionary dictionaryWithDictionary:dataDict];
    [self.gWebViewArray removeAllObjects];
    self.gWebViewArray = nil;
    NSMutableArray *pages = [[NSMutableArray alloc] init];
    [manager enumerateChildrenUsingBlock:^(id<GrowingNode> aNode, GrowingNodeManagerEnumerateContext *context) {
        //支持WKWebview
        if ([aNode isKindOfClass:[WKWebView class]]) {
            WKWebView *wkweb = (WKWebView *)aNode;
            GrowingWeakObject *weakObjc = [[GrowingWeakObject alloc] init];
            weakObjc.webView = wkweb;
            if (![self.gWebViewArray containsObject:weakObjc]) {
                [self.gWebViewArray addObject:weakObjc];
            }
            NSMutableDictionary *dict = [self dictFromNode:aNode
                                                  pageData:modifiedPageData
                                                  keyIndex:aNode.growingNodeKeyIndex
                                                     xPath:[GrowingNodeHelper xPathForNode:aNode]
                                               isContainer:[self isContainer:aNode]];

            [[GrowingHybridBridgeProvider sharedInstance]
                getDomTreeForWebView:wkweb
                   completionHandler:^(NSDictionary *_Nullable domTee, NSError *_Nullable error) {
                       if (domTee.count > 0) {
                           [dict setValue:domTee forKey:@"webView"];
                           [elements addObject:dict];
                       }
                   }];
        } else {
            if ([aNode isKindOfClass:[GrowingWindow class]]) {
                [context skipThisChilds];
                return;
            }

            if ([aNode isKindOfClass:[UIViewController class]]) {
                UIViewController *current = (UIViewController *)aNode;
                GrowingPageGroup *page = [current growingPageHelper_getPageObject];
                if (!page) {
                    [[GrowingPageManager sharedInstance] createdViewControllerPage:current];
                    page = [current growingPageHelper_getPageObject];
                }
                NSMutableDictionary *dict = [self dictFromPage:aNode xPath:page.path];
                if (dict.count > 0) {
                    [pages addObject:dict];
                }
            } else {
                NSMutableDictionary *dict = [self dictFromNode:aNode
                                                      pageData:modifiedPageData
                                                      keyIndex:aNode.growingNodeKeyIndex
                                                         xPath:[GrowingNodeHelper xPathForNode:aNode]
                                                   isContainer:[self isContainer:aNode]];

                if (dict.count > 0) {
                    [elements addObject:dict];
                }
            }
        }
    }];
    finalDataDict[@"elements"] = elements;
    finalDataDict[@"pages"] = pages;
    if (completion != nil) {
        completion(finalDataDict);
    }
}

- (void)onDomChangeWkWebivew {
    [self setNeedUpdateScreen];
}
- (NSDictionary *)dictForUserAction:(NSString *)action {
    if (action.length == 0) {
        return nil;
    }

    //    UIViewController *vc = [[GrowingPageManager sharedInstance] rootViewController];

    UIImage *image = [self screenShot];
    NSData *data = [image growingHelper_JPEG:0.8];

    NSString *imgBase64Str = [data growingHelper_base64String];

    if (!data.length || !imgBase64Str.length) {
        return nil;
    }

    // TODO：如果要传 avar，pvar，evar 等变量，在这里准备好，然后塞到下面的 dict 中
    //    CGSize screenSize = [GrowingDeviceInfo deviceScreenSize];
    //    = (image.size.width * image.scale)/screenSize.width
    NSDictionary *dict = @{
        @"screenWidth" : @(image.size.width * image.scale),
        @"screenHeight" : @(image.size.height * image.scale),
        @"scale" : @(1),  //暂时没有计算
        @"screenshot" : [@"data:image/jpeg;base64," stringByAppendingString:imgBase64Str],
        @"msgType" : action,
        @"snapshotKey" : @([self getSnapshotKey]),
    };

    return dict;
}

- (void)sendScreenShot {
    [self sendScreenShotWithEventType:nil optionalTargets:nil optionalNodeName:nil optionalPageName:nil callback:nil];
}

+ (void)retrieveAllElementsAsync:(void (^)(NSString *))callback {
    [[self shareInstance] sendScreenShotWithEventType:nil
                                      optionalTargets:nil
                                     optionalNodeName:nil
                                     optionalPageName:nil
                                             callback:callback];
}

- (void)sendScreenShotWithEventType:(NSString *)eventType               // nil or clck or page
                    optionalTargets:(NSArray<NSDictionary *> *)targets  // valid if eventType is clck
                   optionalNodeName:(NSString *)nodeName                // valid if eventType is clck
                   optionalPageName:(NSString *)pageName                // valid if eventType is page
                           callback:(void (^)(NSString *))callback      // in case of error, the
                                                                        // callback parameter is nil
{
    // eventType已经忽略
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    NSString *userAction = @"refreshScreenshot";
    [dict addEntriesFromDictionary:[self dictForUserAction:userAction]];
    if (dict.count == 0) {
        if (callback != nil) {
            callback(nil);
        }
        return;
    }

    __weak GrowingWebCircle *wself = self;
    [self fillAllViewsForWebCircle:dict
                        completion:^(NSMutableDictionary *dict) {
                            GrowingWebCircle *sself = wself;
                            // assign parentXPath for each event in "elements", and
                            // assign targets
                            {
                                NSMutableArray<NSDictionary *> *allContainers = [[NSMutableArray alloc] init];
                                NSArray<NSMutableDictionary *> *allImpressedEvent = dict[@"elements"];
                                for (NSDictionary *event in allImpressedEvent) {
                                    NSNumber *isContainer = event[@"isContainer"];
                                    if (isContainer != nil && [isContainer boolValue]) {
                                        [allContainers addObject:event];
                                    }
                                }
                                [allContainers
                                    sortUsingComparator:^NSComparisonResult(id _Nonnull obj1, id _Nonnull obj2) {
                                        NSDictionary *event1 = obj1;
                                        NSDictionary *event2 = obj2;
                                        if ([event1[@"xpath"] length] > [event2[@"xpath"] length]) {
                                            return NSOrderedAscending;
                                        } else if ([event1[@"xpath"] length] < [event2[@"xpath"] length]) {
                                            return NSOrderedDescending;
                                        } else {
                                            return NSOrderedSame;
                                        }
                                    }];
                                for (NSMutableDictionary *event in allImpressedEvent) {
                                    NSNumber *isContainer = event[@"isContainer"];
                                    if (isContainer == nil || ![isContainer boolValue]) {
                                        NSString *eventXPath = event[@"xpath"];
                                        for (NSInteger i = 0; i < allContainers.count; i++) {
                                            NSString *containerXPath = allContainers[i][@"xpath"];
                                            if ([eventXPath hasPrefix:containerXPath]) {
                                                event[@"parentXPath"] = containerXPath;
                                                //web端仅用index来标识list元素所述，所以子元素index需要和父元素一致
                                                event[@"index"] = allContainers[i][@"index"];
                                                break;
                                            }
                                        }
                                    }
                                }

                                if (targets) {
                                    dict[@"targets"] = targets;
                                }
                            }
                            if (sself != nil) {
                                [sself sendJson:dict];
                            }
                            if (callback != nil) {
                                NSString *dictString = [dict growingHelper_jsonString];
                                callback(dictString);  // dictString == nil for error
                            }
                        }];
}

- (void)sendClickOrTouchAction {
}

- (void)remoteReady {
    [self sendScreenShot];
}

- (void)runWithCircleRoomNumber:(NSString *)circleRoomNumber
                     readyBlock:(void (^)(void))readyBlock
                    finishBlock:(void (^)(void))finishBlock {
    if (!self.isReady) {
        [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];

        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(handleDeviceOrientationDidChange:)
                                                     name:UIDeviceOrientationDidChangeNotification
                                                   object:nil];

        [UIApplication sharedApplication].idleTimerDisabled = YES;
        GIOLogDebug(@"开始起服务");
        if (!self.statusWindow) {
            self.statusWindow = [[GrowingStatusBar alloc] initWithFrame:[UIScreen mainScreen].bounds];
            self.statusWindow.hidden = NO;
            self.statusWindow.statusLable.text = @"正在等待web链接";
            self.statusWindow.statusLable.textAlignment = NSTextAlignmentCenter;

            __weak typeof(self) wself = self;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                if (wself && [wself.statusWindow.statusLable.text isEqualToString:@"正在等待web链接"]) {
                    GrowingAlert *alert = [GrowingAlert createAlertWithStyle:UIAlertControllerStyleAlert
                                                                       title:@"提示"
                                                                     message:
                                                                         @"电脑端连接超时，请刷新电脑页面，"
                                                                         @"再次尝试扫码圈选。"];
                    [alert addOkWithTitle:@"知道了" handler:nil];
                    [alert showAlertAnimated:NO];
                }
            });
            self.statusWindow.onButtonClick = ^{
                NSString *content = [NSString
                    stringWithFormat:@"APP版本: %@\nSDK版本: %@", [GrowingDeviceInfo currentDeviceInfo].appShortVersion,
                                     [NSString stringWithFormat:@"SDK版本: %@", [Growing getVersion]]];
                GrowingAlert *alert = [GrowingAlert createAlertWithStyle:UIAlertControllerStyleAlert
                                                                   title:@"正在进行圈选"
                                                                 message:content];
                [alert addOkWithTitle:@"继续圈选" handler:nil];
                [alert
                    addCancelWithTitle:@"退出圈选"
                               handler:^(UIAlertAction *_Nonnull action, NSArray<UITextField *> *_Nonnull textFields) {
                                   [GrowingWebCircle stop];
                               }];
                [alert showAlertAnimated:NO];
            };
        }
        if (self.webSocket) {
            [self.webSocket close];
            self.webSocket = nil;
        }
        NSString *endPoint = @"";
        endPoint = [GrowingNetworkConfig.sharedInstance wsEndPoint];
        NSString *urlStr = [NSString stringWithFormat:endPoint, [GrowingInstance sharedInstance].projectID, circleRoomNumber];
        self.webSocket = [[GrowingSRWebSocket alloc] initWithURLRequest: [NSURLRequest requestWithURL: [NSURL URLWithString:urlStr]]];
//        NSString *urlStr =
//            @"wss://gta1.growingio.com/app/0a1b4118dd954ec3bcc69da5138bdb96/"
//            @"circle/p5Xvy2Mt5OIkWHg8";
//        self.webSocket =
//            [[GrowingSRWebSocket alloc] initWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlStr]]];
        self.webSocket.delegate = self;
        [self.webSocket open];

        self.onReadyBlock = readyBlock;
        self.onFinishBlock = finishBlock;
    }

}

- (void)handleDeviceOrientationDidChange:(UIInterfaceOrientation)interfaceOrientation {
    static CGRect lastRect;
    CGRect rect = [UIScreen mainScreen].bounds;
    if (!CGRectEqualToRect(lastRect, rect)) {
        [[self class] setNeedUpdateScreen];
    }

    lastRect = rect;
}

- (void)beginKeepAlive {
    if (!self.keepAliveTimer) {
        self.keepAliveTimer = [NSTimer scheduledTimerWithTimeInterval:30
                                                               target:self
                                                             selector:@selector(keepAlive)
                                                             userInfo:nil
                                                              repeats:YES];
    }
}

- (void)endKeepAlive {
    if (self.keepAliveTimer) {
        [self.keepAliveTimer invalidate];
        self.keepAliveTimer = nil;
    }
}

- (void)keepAlive {
    NSDictionary *dict = @{@"msgType" : @"heartbeat"};
    [self sendJson:dict];
}

- (void)stop {
    GIOLogDebug(@"开始断开连接");
    NSDictionary *dict = @{@"msgType" : @"quit"};
    [self sendJson:dict];
    self.statusWindow.statusLable.text = @"正在关闭web圈选...";
    self.statusWindow.statusLable.textAlignment = NSTextAlignmentCenter;
    [self _stopWithError:nil];
}

- (void)_stopWithError:(NSString *)error {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
    [[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];

    [[GrowingEventManager shareInstance] removeObserver:self];

    [self endKeepAlive];
    //    if (self.httpServer) {
    //        [self.httpServer stop];
    //        self.httpServer = nil;
    //    }
    if (self.webSocket) {
        self.webSocket.delegate = nil;
        [self.webSocket close];
        self.webSocket = nil;
    }
    if (self.onFinishBlock) {
        self.onFinishBlock();
        self.onFinishBlock = nil;
    }
    if (self.onReadyBlock) {
        self.onReadyBlock = nil;
    }
    if (self.statusWindow) {
        self.statusWindow.hidden = YES;
        self.statusWindow = nil;
    }
    if (error.length) {
        GrowingAlert *alert = [GrowingAlert createAlertWithStyle:UIAlertControllerStyleAlert
                                                           title:@"设备已断开连接"
                                                         message:error];
        [alert addOkWithTitle:@"知道了" handler:nil];
        [alert showAlertAnimated:NO];
    }
}

- (BOOL)isRunning {
    //        return self.webSocket != nil;
    return self.isReady;
}

- (void)sendJson:(id)json {
    if (self.webSocket.readyState == Growing_SR_OPEN &&
        ([json isKindOfClass:[NSDictionary class]] || [json isKindOfClass:[NSArray class]])) {
        NSString *jsonString = [json growingHelper_jsonString];
        [self.webSocket send:jsonString];
    }
}

#pragma mark - Websocket Delegate

- (void)webSocket:(GrowingSRWebSocket *)webSocket didReceiveMessage:(id)message {
    if ([message isKindOfClass:[NSString class]]) {
        GIOLogDebug(@"didReceiveMessage: %@", message);
        NSMutableDictionary *dict = [[message growingHelper_jsonObject] mutableCopy];

        //如果收到了ready消息，说明可以发送圈选数据了
        if ([[dict objectForKey:@"msgType"] isEqualToString:@"ready"]) {
            [self remoteReady];
            self.statusWindow.statusLable.text = @"正在进行GrowingIO移动端圈选";
            self.statusWindow.statusLable.textAlignment = NSTextAlignmentCenter;
            if (self.onReadyBlock) {
                self.onReadyBlock();
                self.onReadyBlock = nil;
            }
            //序列号置零
            _snapNumber = 0;
            self.isReady = YES;
            // Hybird的布局改变回调代理设置
            [GrowingHybridBridgeProvider sharedInstance].domChangedDelegate = self;
            //监听原生事件，变动时发送
            [[GrowingEventManager shareInstance] addObserver:self];
            // webSocket连接成功的速度比viewDidAppear慢,因此page事件没有发送成功
            //解决方式在webSocket链接成功后 再发一次page事件
            [[GrowingPageManager sharedInstance]
                createdViewControllerPage:[[GrowingPageManager sharedInstance] currentViewController]];
        }
        // 版本号不适配web圈选
        if ([[dict objectForKey:@"msgType"] isEqualToString:@"incompatible_version"]) {
            GrowingAlert *alert = [GrowingAlert createAlertWithStyle:UIAlertControllerStyleAlert
                                                               title:@"抱歉"
                                                             message:@"您使用的SDK版本号过低,请升级SDK后再使用"];
            [alert addOkWithTitle:@"知道了" handler:nil];
            [alert showAlertAnimated:NO];
            [self stop];
        }

        // web端退出了圈选
        if ([[dict objectForKey:@"msgType"] isEqualToString:@"quit"]) {
            self.isReady = NO;
            [self _stopWithError:@"当前设备已与Web端断开连接,如需继续圈选请扫码重新连接。"];
        }
    }
}

- (void)webSocketDidOpen:(GrowingSRWebSocket *)webSocket {
    GIOLogDebug(@"websocket已连接");
    CGSize screenSize = [GrowingDeviceInfo deviceScreenSize];
    NSString *projectId = [GrowingInstance sharedInstance].projectID ?: @"";
    NSDictionary *dict = @{
        @"projectId" : projectId,
        @"msgType" : @"ready",
        @"timestamp" : @([[NSDate date] timeIntervalSince1970]),
        @"domain" : [GrowingDeviceInfo currentDeviceInfo].bundleID,
        @"sdkVersion" : [Growing getVersion],
        @"appVersion" : [GrowingDeviceInfo currentDeviceInfo].appFullVersion,
        @"os" : @"iOS",
        @"screenWidth" : [NSNumber numberWithInteger:screenSize.width],
        @"screenHeight" : [NSNumber numberWithInteger:screenSize.height],
    };
    [self sendJson:dict];
    [self beginKeepAlive];
}

- (void)webSocket:(GrowingSRWebSocket *)webSocket
    didCloseWithCode:(NSInteger)code
              reason:(NSString *)reason
            wasClean:(BOOL)wasClean {
    GIOLogDebug(@"已断开链接");
    _isReady = NO;
    if (code != GrowingSRStatusCodeNormal) {
        [self _stopWithError:@"当前设备已与Web端断开连接,如需继续圈选请扫码重新连接。"];
    }
}

- (void)webSocket:(GrowingSRWebSocket *)webSocket didFailWithError:(NSError *)error {
    GIOLogDebug(@"error : %@", error);
    _isReady = NO;
    [self _stopWithError:@"服务器链接失败"];
}

- (void)webSocket:(GrowingSRWebSocket *)webSocket didReceivePong:(NSData *)pongPayload {
}

#pragma mark - Nodes

- (NSString *)getViewControllerName:(UIViewController *)viewController {
    NSString *currentPageName = [viewController growingPageName];
    if (!currentPageName.length) {
        currentPageName = [viewController growingPageName];
    }
    if (currentPageName.length > 0) {
        return currentPageName;
    } else {
        return @"页面";
    }
}

- (NSString *)getNodeName:(id<GrowingNode>)node
                withXPath:(NSString *)xPath
             withKeyIndex:(NSInteger)keyIndex
              withContent:(NSString *)content
                 withPage:(NSString *)page {

    __block CGFloat maxFontSize = 0.0;
    __block NSString *maxFontContent = nil;
    GrowingNodeManager *manager = [[GrowingEventNodeManager alloc] initWithNode:node
                                                                      eventType:GrowingEventTypeUIPageShow];
    [manager enumerateChildrenUsingBlock:^(id<GrowingNode> aNode, GrowingNodeManagerEnumerateContext *context) {
        NSString *content = [aNode growingNodeContent];
        BOOL userInteractive = [aNode growingNodeUserInteraction];
        if (content.length > 0) {
            if ([aNode isKindOfClass:[UILabel class]]) {
                UILabel *lbl = (UILabel *)aNode;
                CGFloat fontSize = lbl.font.pointSize;
                if (fontSize > maxFontSize) {
                    maxFontSize = fontSize;
                    maxFontContent = content;
                }
            }
        } else if (userInteractive && aNode != node) {
            [context skipThisChilds];
        }
    }];
    if (maxFontContent.length > 0) {
        return maxFontContent;
    }

    return @"按钮";
}

#pragma mark - GrowingWebViewDomChangedDelegate
// hybird变动，重新发送dom tree
- (void)webViewDomDidChanged {
    [self sendScreenShot];
}

#pragma mark - GrowingEventManagerObserver

- (void)growingEventManagerWillAddEvent:(GrowingEvent *_Nullable)event
                               thisNode:(id<GrowingNode> _Nullable)thisNode
                            triggerNode:(id<GrowingNode> _Nullable)triggerNode
                            withContext:(id<GrowingAddEventContext> _Nullable)context {
    __weak GrowingWebCircle *wself = self;
    // toDictionary每次都会生成新字典，这里存储一份，避免重复生成
    NSDictionary *eventDictionary = event.toDictionary;
    NSString *eventType = eventDictionary[@"t"];
    if ([eventType isEqualToString:@"clck"]
        //        || [eventType isEqualToString:@"tchd"]
        || [eventType isEqualToString:@"lngclck"] || [eventType isEqualToString:@"dbclck"]) {
        NSMutableDictionary *pageData = [[NSMutableDictionary alloc] init];

        NSString *page = eventDictionary[@"p"];
        pageData[@"page"] = page;
        pageData[@"domain"] = eventDictionary[@"d"];
  
        NSInteger keyIndex =
            eventDictionary[@"idx"] ? [eventDictionary[@"idx"] integerValue] : [GrowingNodeItemComponent indexNotFound];
        NSString *xPath = eventDictionary[@"x"];
        BOOL isContainer = [self isContainer:thisNode];
        NSMutableDictionary *dict = [self dictFromNode:thisNode
                                              pageData:pageData
                                              keyIndex:keyIndex
                                                 xPath:xPath
                                           isContainer:isContainer];
        if (dict.count <= 0) {
            return;
        }
        NSString *nodeName = [self getNodeName:thisNode
                                     withXPath:xPath
                                  withKeyIndex:keyIndex
                                   withContent:[thisNode growingNodeContent]
                                      withPage:page];
        dict[@"_nodeName"] = nodeName;
        [self.cachedEvents addObject:dict];

        dispatch_async(dispatch_get_main_queue(), ^{
            GrowingWebCircle *sself = wself;
            if (sself.cachedEvents.count == 0) {
                return;
            }

            NSMutableArray<NSMutableDictionary *> *cachedEvents = sself.cachedEvents;
            sself.cachedEvents = [[NSMutableArray alloc] init];

            NSInteger rootIndex = 0;
            for (NSInteger i = 1; i < cachedEvents.count; i++) {
                if ([cachedEvents[i][@"xpath"] length] < [cachedEvents[rootIndex][@"xpath"] length]) {
                    rootIndex = i;
                }
            }
            for (NSInteger i = 0; i < cachedEvents.count; i++) {
                if (rootIndex != i) {
                    cachedEvents[i][@"parentXPath"] = cachedEvents[rootIndex][@"xpath"];
                }
            }
            NSString *nodeName = cachedEvents[rootIndex][@"_nodeName"];
            for (NSInteger i = 0; i < cachedEvents.count; i++) {
                [cachedEvents[i] removeObjectForKey:@"_nodeName"];
            }
            [self sendScreenShotWithEventType:@"clck"
                              optionalTargets:cachedEvents
                             optionalNodeName:nodeName
                             optionalPageName:nil
                                     callback:nil];
        });
    } else if ([eventType isEqualToString:@"page"]) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            NSString *pageName = [thisNode isKindOfClass:[UIViewController class]]
                                     ? [self getViewControllerName:(UIViewController *)thisNode]
                                     : eventDictionary[@"p"];
            [self sendScreenShotWithEventType:@"page"
                              optionalTargets:nil
                             optionalNodeName:nil
                             optionalPageName:pageName
                                     callback:nil];
        });
    }
}

- (BOOL)growingEventManagerShouldAddEvent:(GrowingEvent *_Nullable)event
                              triggerNode:(id<GrowingNode> _Nullable)triggerNode
                              withContext:(id<GrowingAddEventContext> _Nullable)context {
    for (id<GrowingNode> obj in [context contextNodes]) {
        if ([obj isKindOfClass:[GrowingWindow class]]) {
            return NO;
        }
        if ([obj isKindOfClass:[UIView class]]) {
            UIView *view = (UIView *)obj;
            return ![view.window isKindOfClass:[GrowingWindow class]];
        }
    }
    return YES;
}

@end
