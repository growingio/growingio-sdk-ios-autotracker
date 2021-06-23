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
#import "GrowingApplicationEventManager.h"
#import "GrowingAttributesConst.h"
#import "GrowingAutotrackEventType.h"
#import "GrowingLogger.h"
#import "GrowingConfigurationManager.h"
#import "GrowingDeepLinkHandler.h"
#import "GrowingDeviceInfo.h"
#import "GrowingDispatchManager.h"
#import "GrowingEventManager.h"
#import "GrowingNetworkConfig.h"
#import "GrowingNodeHelper.h"
#import "GrowingPageGroup.h"
#import "GrowingPageManager.h"
#import "GrowingStatusBar.h"
#import "GrowingWebCircleElement.h"
#import "GrowingWebViewDomChangedDelegate.h"
#import "NSArray+GrowingHelper.h"
#import "NSData+GrowingHelper.h"
#import "NSDictionary+GrowingHelper.h"
#import "NSString+GrowingHelper.h"
#import "NSURL+GrowingHelper.h"
#import "UIApplication+GrowingHelper.h"
#import "UIApplication+GrowingNode.h"
#import "UIImage+GrowingHelper.h"
#import "UIViewController+GrowingAutotracker.h"
#import "UIViewController+GrowingNode.h"
#import "UIViewController+GrowingPageHelper.h"
#import "UIWindow+GrowingHelper.h"
#import "UIWindow+GrowingNode.h"
//#import "WKWebView+GrowingAutotracker.h"
#import "GrowingStatusBarAutotracker.h"
#import "GrowingServiceManager.h"
#import "GrowingHybridBridgeProvider.h"

@GrowingMod(GrowingWebCircle)

@interface GrowingWeakObject : NSObject
@property (nonatomic, weak) JSContext *context;
@property (nonatomic, weak) id webView;
@end
@implementation GrowingWeakObject
@end

@interface GrowingWebCircle () <GrowingSRWebSocketDelegate,
                                GrowingEventInterceptor,
                                GrowingWebViewDomChangedDelegate,
                                GrowingApplicationEventProtocol,
                                GrowingDeepLinkHandlerProtocol>

//表示web和app是否同时准备好数据发送，此时表示可以发送数据
@property (nonatomic, assign) BOOL isReady;

@property (nonatomic, copy) void (^onReadyBlock)(void);
@property (nonatomic, copy) void (^onFinishBlock)(void);

@property (nonatomic, retain) GrowingStatusBar *statusWindow;

@property (nonatomic, retain) NSMutableArray<NSString *> *cachedEvents;

@property (nonatomic, assign) int zLevel;
@property (nonatomic, assign) unsigned long snapNumber;  //数据发出序列号
@property (nonatomic, assign) BOOL onProcessing;
//当页面vc的page未生成，即viewDidAppear未执行，此时忽略数据，并不发送
@property (nonatomic, assign) BOOL isPageDontShow;
@property (nonatomic, strong) NSMutableArray *elements;
@end

@implementation GrowingWebCircle

//static GrowingWebCircle *sharedInstance = nil;
//
//+ (instancetype)sharedInstance {
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
//        sharedInstance = [[GrowingWebCircle alloc] init];
//        [GrowingStatusBarAutotracker track];
//    });
//    return sharedInstance;
//}

//+ (void)runWithCircle:(NSURL *)url readyBlock:(void (^)(void))readyBlock finishBlock:(void (^)(void))finishBlock;
//{ [[self sharedInstance] runWithCircle:url readyBlock:readyBlock finishBlock:finishBlock]; }
//
//+ (void)stop {
//    [[self sharedInstance] stop];
//}
//
//+ (BOOL)isRunning {
//    return [[self sharedInstance] isRunning];
//}

- (void)growingModInit:(GrowingContext *)context {
    [GrowingStatusBarAutotracker track];
    [[GrowingDeepLinkHandler sharedInstance] addHandlersObject:self];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _cachedEvents = [[NSMutableArray alloc] init];
    }
    return self;
}

#pragma mark - GrowingDeepLinkHandlerProtocol

- (BOOL)growingHandlerUrl:(NSURL *)url {
    NSDictionary *params = url.growingHelper_queryDict;
    NSString *serviceType = params[@"serviceType"];
    NSString *wsurl = params[@"wsUrl"];
    if (serviceType.length > 0 && [serviceType isEqualToString:@"circle"] && wsurl.length > 0) {
        [self runWithCircle:[NSURL URLWithString:wsurl] readyBlock:nil finishBlock:nil];
        return YES;
    }
    return NO;
}

#pragma mark - actions

- (void)_setNeedUpdateScreen {
    [self sendScreenShot];
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

    UIImage *image = [UIWindow growingHelper_screenshotWithWindows:windows andMaxScale:scale block:nil];

    return image;
}

+ (CGFloat)impressScale {
    CGFloat scale = [UIScreen mainScreen].scale;
    return MIN(scale, 2);
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

- (NSMutableDictionary *)dictFromNode:(GrowingViewNode *)node {
    GrowingPage *page = [[GrowingPageManager sharedInstance] findPageByView:node.view];
    if (!page) {
        self.isPageDontShow = YES;
        GIOLogDebug(@"page of view %@ not found", node.view);
    }
    GrowingWebCircleElement *element = GrowingWebCircleElement.builder.setRect(node.view.growingNodeFrame)
                                           .setContent(node.viewContent)
                                           .setZLevel(self.zLevel++)
                                           .setIndex(node.index)
                                           .setXpath(node.xPath)
                                           .setParentXPath(node.clickableParentXPath)
                                           .setNodeType(node.nodeType)
                                           .setPage(page.path)
                                           .build;

    return [NSMutableDictionary dictionaryWithDictionary:element.toDictionary];
}

- (unsigned long)getSnapshotKey {
    @synchronized(self) {
        _snapNumber++;
    }
    return _snapNumber;
}

- (void)resetSnapshotKey {
    @synchronized(self) {
        _snapNumber = 0;
    }
}

- (NSMutableArray *)elements {
    if (!_elements) {
        _elements = [NSMutableArray array];
    }
    return _elements;
}

- (void)traverseViewNode:(GrowingViewNode *)viewNode {
    if (self.isPageDontShow) {
        return;
    }
    UIView *node = viewNode.view;
    if ([node growingNodeUserInteraction] || [node isKindOfClass:NSClassFromString(@"WKWebView")]) {
        if ([node growingNodeDonotTrack] || [node growingNodeDonotCircle]) {
            GIOLogDebug(@"圈选过滤节点:%@,DontTrack:%d,DontCircle:%d", [node class], [node growingNodeDonotTrack],
                        [node growingNodeDonotCircle]);
        } else {
            NSMutableDictionary *dict = [self dictFromNode:viewNode];
            if ([viewNode.view isKindOfClass:NSClassFromString(@"WKWebView")]) {
                [[GrowingHybridBridgeProvider sharedInstance]
                    getDomTreeForWebView:viewNode.view
                       completionHandler:^(NSDictionary *_Nullable domTee, NSError *_Nullable error) {
                           if (domTee.count > 0) {
                               [dict setValue:domTee forKey:@"webView"];
                           }
                       }];
            }
            [self.elements addObject:dict];
        }
    }

    NSArray *childs = [node growingNodeChilds];
    if (childs.count > 0) {
        for (int i = 0; i < childs.count; i++) {
            GrowingViewNode *tmp = [viewNode appendNode:childs[i] isRecalculate:YES];
            [self traverseViewNode:tmp];
        }
    }
}

- (void)fillAllViewsForWebCircle:(NSDictionary *)dataDict completion:(void (^)(NSMutableDictionary *dict))completion {
    NSMutableDictionary *finalDataDict = [NSMutableDictionary dictionaryWithDictionary:dataDict];
    //初始化数组
    self.elements = [NSMutableArray array];
    CGFloat windowLevel = UIWindowLevelNormal;
    UIWindow *topwindow = nil;
    for (UIWindow *window in [UIApplication sharedApplication].growingHelper_allWindowsWithoutGrowingWindow) {
        //如果找到了keywindow跳出循环
        if (window.isKeyWindow) {
            topwindow = window;
            break;
        }
        if (window.windowLevel >= windowLevel) {
            windowLevel = window.windowLevel;
            topwindow = window;
        }
    }
    if (topwindow) {
        self.zLevel = 0;
        self.isPageDontShow = NO;
        [self traverseViewNode:GrowingViewNode.builder.setView(topwindow)
                                   .setIndex(-1)
                                   .setViewContent([GrowingNodeHelper buildElementContentForNode:topwindow])
                                   .setXPath([GrowingNodeHelper xPathForView:topwindow similar:NO])
                                   .setOriginXPath([GrowingNodeHelper xPathForView:topwindow similar:NO])
                                   .setNodeType([GrowingNodeHelper getViewNodeType:topwindow])
                                   .build];
        if (self.isPageDontShow) {
            completion(nil);
            return;
        }
    }

    NSMutableArray *pages = [NSMutableArray array];
    NSArray *vcs = [[GrowingPageManager sharedInstance] allDidAppearViewControllers];
    for (int i = 0; i < vcs.count; i++) {
        UIViewController *tmp = vcs[i];
        GrowingPage *page = [[GrowingPageManager sharedInstance] findPageByViewController:tmp];
        NSMutableDictionary *dict = [self dictFromPage:tmp xPath:page.path];
        [pages addObject:dict];
    }
    finalDataDict[@"elements"] = self.elements;
    finalDataDict[@"pages"] = pages;
    if (completion != nil) {
        completion(finalDataDict);
    }
}

- (NSDictionary *)dictForUserAction:(NSString *)action {
    if (action.length == 0) {
        return nil;
    }

    UIImage *image = [self screenShot];
    NSData *data = [image growingHelper_JPEG:0.8];

    NSString *imgBase64Str = [data growingHelper_base64String];

    if (!data.length || !imgBase64Str.length) {
        return nil;
    }
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
    if (self.isReady) {
        [self sendScreenShotWithCallback:nil];
    }
}

- (void)sendScreenShotWithCallback:(void (^)(NSString *))callback  // in case of error, the
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
                            if (sself != nil && dict) {
                                [sself sendJson:dict];
                            }
                            if (callback != nil) {
                                NSString *dictString = [dict growingHelper_jsonString];
                                callback(dictString);  // dictString == nil for error
                            }
                        }];
}

- (void)remoteReady {
    [self sendScreenShot];
}

- (void)runWithCircle:(NSURL *)url readyBlock:(void (^)(void))readyBlock finishBlock:(void (^)(void))finishBlock;
{
    if (self.webSocket) {
        [self.webSocket close];
        self.webSocket.delegate = nil;
        self.webSocket = nil;
    }
    
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
                NSString *content = [NSString stringWithFormat:@"APP版本: %@\nSDK版本: %@",
                                                               [GrowingDeviceInfo currentDeviceInfo].appFullVersion,
                                                               GrowingTrackerVersionName];
                GrowingAlert *alert = [GrowingAlert createAlertWithStyle:UIAlertControllerStyleAlert
                                                                   title:@"正在进行圈选"
                                                                 message:content];
                [alert addOkWithTitle:@"继续圈选" handler:nil];
                [alert
                    addCancelWithTitle:@"退出圈选"
                               handler:^(UIAlertAction *_Nonnull action, NSArray<UITextField *> *_Nonnull textFields) {
                                   [wself stop];
                               }];
                [alert showAlertAnimated:NO];
            };
        }
        
        self.webSocket = [[GrowingSRWebSocket alloc] initWithURLRequest:[NSURLRequest requestWithURL:url]];
        self.webSocket.delegate = self;
        [self.webSocket open];

        self.onReadyBlock = readyBlock;
        self.onFinishBlock = finishBlock;
    }

    NSDictionary *dict = @{@"msgType" : @"ready"};
    [self webSocket:nil didReceiveMessage:dict.growingHelper_jsonString];
}

- (void)handleDeviceOrientationDidChange:(UIInterfaceOrientation)interfaceOrientation {
    static CGRect lastRect;
    CGRect rect = [UIScreen mainScreen].bounds;
    if (!CGRectEqualToRect(lastRect, rect)) {
        [self _setNeedUpdateScreen];
    }

    lastRect = rect;
}

- (void)start {
    [self remoteReady];
    self.statusWindow.statusLable.text = @"正在进行GrowingIO移动端圈选";
    self.statusWindow.statusLable.textAlignment = NSTextAlignmentCenter;
    if (self.onReadyBlock) {
        self.onReadyBlock();
        self.onReadyBlock = nil;
    }
    [self resetSnapshotKey];
    self.isReady = YES;
    // Hybrid的布局改变回调代理设置
    [GrowingHybridBridgeProvider sharedInstance].domChangedDelegate = self;
    //监听原生事件，变动时发送
    [[GrowingEventManager sharedInstance] addInterceptor:self];
    [[GrowingApplicationEventManager sharedInstance] addApplicationEventObserver:self];
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

    [[GrowingEventManager sharedInstance] removeInterceptor:self];
    [[GrowingApplicationEventManager sharedInstance] removeApplicationEventObserver:self];
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

    [[GrowingEventManager sharedInstance] removeInterceptor:self];
}

- (BOOL)isRunning {
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
    if ([message isKindOfClass:[NSString class]] || ((NSString *)message).length > 0) {
        GIOLogDebug(@"didReceiveMessage: %@", message);
        NSMutableDictionary *dict = [[message growingHelper_jsonObject] mutableCopy];

        //如果收到了ready消息，说明可以发送圈选数据了
        if ([[dict objectForKey:@"msgType"] isEqualToString:@"ready"]) {
            [self start];
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

#pragma mark - websocket delegate

- (void)webSocketDidOpen:(GrowingSRWebSocket *)webSocket {
    GIOLogDebug(@"websocket已连接");
    CGSize screenSize = [GrowingDeviceInfo deviceScreenSize];
    NSString *projectId = GrowingConfigurationManager.sharedInstance.trackConfiguration.projectId;
    NSDictionary *dict = @{
        @"projectId" : projectId,
        @"msgType" : @"ready",
        @"timestamp" : @([[NSDate date] timeIntervalSince1970]),
        @"domain" : [GrowingDeviceInfo currentDeviceInfo].bundleID,
        @"sdkVersion" : GrowingTrackerVersionName,
        @"appVersion" : [GrowingDeviceInfo currentDeviceInfo].appFullVersion,
        @"os" : @"iOS",
        @"screenWidth" : [NSNumber numberWithInteger:screenSize.width],
        @"screenHeight" : [NSNumber numberWithInteger:screenSize.height],
        @"urlScheme" : [GrowingDeviceInfo currentDeviceInfo].urlScheme
    };
    [self sendJson:dict];
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

#pragma mark - GrowingWebViewDomChangedDelegate
// Hybrid变动，重新发送dom tree
- (void)webViewDomDidChanged {
    [self sendWebcircleWithType:GrowingEventTypeViewClick];
}

#pragma mark - GrowingApplicationEventManager

- (void)growingApplicationEventSendEvent:(UIEvent *)event {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(_setNeedUpdateScreen) object:nil];
    [self performSelector:@selector(_setNeedUpdateScreen) withObject:nil afterDelay:1];
}

#pragma mark - GrowingEventManagerObserver
//事件被触发
- (void)growingEventManagerEventTriggered:(NSString *_Nullable)eventType {
    [self sendWebcircleWithType:eventType];
}

- (void)sendWebcircleWithType:(NSString *)eventType {
    // this call back run in main thread
    // so not use lock
    if (!_isReady) {
        return;
    }
    if ([eventType isEqualToString:GrowingEventTypeViewClick] || [eventType isEqualToString:GrowingEventTypePage]) {
        [self.cachedEvents addObject:eventType];
        if (self.onProcessing) {
            GIOLogDebug(@"[GrowingWebCircle] cached %lu event to webcircle", (unsigned long)self.cachedEvents.count);
            return;
        }
        self.onProcessing = YES;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(200 * NSEC_PER_MSEC)), dispatch_get_main_queue(), ^{
            if (self.cachedEvents.count == 0 || !self.isReady) return;
            NSMutableArray *eventArray = self.cachedEvents;
            self.cachedEvents = [NSMutableArray array];
            [eventArray
                enumerateObjectsWithOptions:NSEnumerationReverse
                                 usingBlock:^(__kindof NSString *_Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
                                     if ([obj isEqualToString:GrowingEventTypeViewClick] ||
                                         [obj isEqualToString:GrowingEventTypePage]) {
                                         [self sendScreenShotWithCallback:nil];
                                         *stop = YES;
                                     }
                                 }];
            self.onProcessing = NO;
        });
    }
}

@end
