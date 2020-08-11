//
//  GrowingWebSocket.m
//  Growing
//
//  Created by 陈曦 on 15/8/26.
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

#import "GrowingWebSocket.h"
#import <UIKit/UIKit.h>
#import "UIViewController+GrowingNode.h"
#import "UIViewController+GrowingAutoTrack.h"
#import "GrowingInstance.h"
#import "UIWindow+GrowingNode.h"
#import "NSData+GrowingHelper.h"
#import "NSString+GrowingHelper.h"
#import "NSArray+GrowingHelper.h"
#import "NSDictionary+GrowingHelper.h"
#import "UIImage+GrowingHelper.h"
#import "GrowingDeviceInfo.h"
#import "GrowingEventManager.h"
#import "UIViewController+GrowingNode.h"
#import "GrowingStatusBar.h"
#import "UIApplication+GrowingHelper.h"
#import "UIWindow+GrowingHelper.h"
#import "GrowingAttributesConst.h"
#import "NSData+GrowingHelper.h"
#import "GrowingCustomField.h"
#import "metamacros.h"
#import "GrowingEventNodeManager.h"
#import "GrowingDispatchManager.h"
#import <ifaddrs.h>
#import <arpa/inet.h>
#import <JavaScriptCore/JavaScriptCore.h>
#import "WKWebView+GrowingAutoTrack.h"
#import "GrowingCocoaLumberjack.h"
#import "GrowingAlert.h"
#import "UIApplication+GrowingNode.h"
#import "GrowingPageManager.h"

typedef void(^GrowingWebSocketActionItemAction)(id);


@interface GrowingWebSocketActionItem : NSObject

@property (nonatomic, retain) NSMutableDictionary *childAction;
//@property (nonatomic, copy)   GrowingWebSocketActionItemAction action;
//@property (nonatomic, assign) GrowingWebSocketActionItem *parentItem;

@end

@implementation GrowingWebSocketActionItem
- (NSString*)description {
    return self.childAction.description;
}
@end

//@interface GrowingWebCircleHTTPConnection : GrowingHTTPConnection
//
//@end
//
//@implementation GrowingWebCircleHTTPConnection
//
//- (NSObject<GrowingHTTPResponse> *)GrowingHTTPResponseForMethod:(NSString *)method URI:(NSString *)path
//{
//    return [super GrowingHTTPResponseForMethod:method URI:path];
//}
//
//- (GrowingSRWebSocket *)webSocketServerForURI:(NSString *)path {
//    if ([path isEqualToString:@"/service"]) {
//        GrowingSRWebSocket *socketServer = [[GrowingSRWebSocket alloc] initWithURLRequest:request];
//        socketServer.delegate = [GrowingWebSocket shareInstance];
//        [GrowingWebSocket shareInstance].webSocket = socketServer;
//        return socketServer;
//    }
//
//    return [super webSocketServerForURI:path];
//}
//
//@end

@interface WeakObject : NSObject
@property(nonatomic ,weak) JSContext *context ;
@property(nonatomic ,weak) id webView ;
@end
@implementation WeakObject
@end

@interface GrowingWebSocket()<GrowingSRWebSocketDelegate, GrowingEventManagerObserver>
//websocketserver and web connect state
@property (nonatomic, assign) BOOL isConnected;
//表示ready是否
@property (nonatomic, assign) BOOL isReady;
@property (nonatomic, retain) NSTimer *keepAliveTimer;
@property (nonatomic, retain) GrowingWebSocketActionItem *rootAction;

@property (nonatomic, copy) void(^onReadyBlock)(void) ;
@property (nonatomic, copy) void(^onFinishBlock)(void) ;

@property (nonatomic, retain) GrowingStatusBar *statusWindow;

@property (nonatomic, retain) NSMutableArray<NSMutableDictionary *> *cachedEvents;

@property (nonatomic, strong) NSMutableArray *gWebViewArray ;
@property (nonatomic, assign) int nodeZLevel;
@property (nonatomic, assign) int zLevel;
@property (nonatomic, copy) NSString *randomNumber ;
@end

@implementation GrowingWebSocket{
    NSMutableArray *tempArray ;
}

static GrowingWebSocket *shareInstance = nil;

+ (void)setNeedUpdateScreen {
    // 不用self 不会创建实例
    if ([shareInstance isRunning]) {
        [shareInstance setNeedUpdateScreen];
    }
}

+ (instancetype)shareInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareInstance = [[GrowingWebSocket alloc] init];
    });
    return shareInstance;
}

+ (void)runWithCircleRoomNumber:(NSString *)circleRoomNumber ReadyBlock:(void(^)(void))readyBlock finishBlock:(void(^)(void))finishBlock {
    [[self shareInstance] runWithCircleRoomNumber:circleRoomNumber ReadyBlock:readyBlock finishBlock:finishBlock];
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

//- (void)addActionItemAtPath:(NSArray*)paths action:(GrowingWebSocketActionItemAction)action {
//    if (paths.count == 0) {
//        return;
//    }
//
//    if (!self.rootAction) {
//        self.rootAction = [[GrowingWebSocketActionItem alloc] init];
//        self.rootAction.childAction = [[NSMutableDictionary alloc] init];
//    }
//    GrowingWebSocketActionItem *curItem = self.rootAction;
//    for (NSString *origPath in paths) {
//        NSString *path = origPath.lowercaseString;
//        GrowingWebSocketActionItem *childItem = curItem.childAction[path];
//        if (!childItem) {
//            childItem = [[GrowingWebSocketActionItem alloc] init];
//            childItem.parentItem = curItem;
//            if (!curItem.childAction) {
//                curItem.childAction = [[NSMutableDictionary alloc] init];
//            }
//            curItem.childAction[path] = childItem;
//        }
//        curItem = childItem;
//    }
//    // 因为 paths.count > 0 所以 curItem != rootAction
//    curItem.action = action;
//}

//- (BOOL)runActionWithJsonObj:(id)jsonObj atPathItem:(GrowingWebSocketActionItem*)item unRunObj:(id*)unRunObj {
//    if (!item) {
//        *unRunObj = jsonObj;
//        return NO;
//    }
//    if (!jsonObj) {
//        if (item.action) {
//            item.action(nil);
//            return YES;
//        } else {
//            *unRunObj = jsonObj;
//            return NO;
//        }
//    }
//
//    if (item.childAction.count == 0) {
//        if (item.action) {
//            item.action(jsonObj);
//            return YES;
//        } else {
//            *unRunObj = jsonObj;
//            return NO;
//        }
//    }
//
//    if ([jsonObj isKindOfClass:[NSDictionary class]]) {
//        NSMutableDictionary *retDict = [[NSMutableDictionary alloc] init];
//        for (id thekey in jsonObj) {
//            NSString *key = nil;
//            if ([thekey isKindOfClass:[NSString class]]) {
//                key = thekey;
//            } else {
//                key = [thekey stringValue];
//            }
//
//            id value = jsonObj[key];
//            id outObj = nil;
//            if (![self runActionWithJsonObj:value atPathItem:item.childAction[key.lowercaseString] unRunObj:&outObj]) {
//                if (item.action) {
//                    item.action(outObj);
//                } else {
//                    retDict[key] = outObj;
//                }
//            }
//        }
//        if (retDict.count) {
//            *unRunObj = retDict;
//            return NO;
//        } else {
//            return YES;
//        }
//    } else if ([jsonObj isKindOfClass:[NSArray class]]) {
//        NSMutableArray *retArr = [[NSMutableArray alloc] init];
//        for (id childObj in jsonObj) {
//            id outObj = nil;
//            if (![self runActionWithJsonObj:childObj atPathItem:item unRunObj:&outObj]) {
//                if (item.action) {
//                    item.action(outObj);
//                } else {
//                    [retArr addObject:outObj];
//                }
//            }
//        }
//        if (retArr.count) {
//            *unRunObj = retArr;
//            return NO;
//        } else {
//            return YES;
//        }
//    } else if ([jsonObj isKindOfClass:[NSString class]]) {
//        NSString *str = [jsonObj lowercaseString];
//        id outObj = nil;
//        if (![self runActionWithJsonObj:nil atPathItem:item.childAction[str] unRunObj:&outObj])
//        {
//            if (item.action)
//            {
//                item.action(str);
//                return YES;
//            }
//            else
//            {
//                *unRunObj = str;
//                return NO;
//            }
//        }
//        else
//        {
//            return YES;
//        }
//    }
//    else if ([jsonObj isKindOfClass:[NSNumber class]])
//    {
//        NSString *str = [[jsonObj stringValue] lowercaseString];
//        id outObj = nil;
//        if (![self runActionWithJsonObj:nil atPathItem:item.childAction[str] unRunObj:&outObj])
//        {
//            if (item.action)
//            {
//                item.action(str);
//                return YES;
//            }
//            else
//            {
//                *unRunObj = str;
//                return NO;
//            }
//        }
//        else
//        {
//            return YES;
//        }
//    }
//    else
//    {
//        *unRunObj = jsonObj;
//        return NO;
//    }
//}

//- (void)runActionWithJsonObj:(id)jsonObj
//{
//    id outObj = nil;
//    if(![self runActionWithJsonObj:jsonObj atPathItem:self.rootAction unRunObj:&outObj])
//    {
//        GIOLogDebug(@"unrunobj %@",outObj);
//
//    }
//}

- (void)_setNeedUpdateScreen
{
    [self sendScreenShot];
}

- (void)setNeedUpdateScreen
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(_setNeedUpdateScreen) object:nil];
    [self performSelector:@selector(_setNeedUpdateScreen) withObject:nil afterDelay:1];
}

#pragma mark - screenShot

- (UIImage*)screenShot
{
    CGFloat scale = [[self class] impressScale];
    
    NSArray *windows = [[UIApplication sharedApplication].growingHelper_allWindowsWithoutGrowingWindow sortedArrayUsingComparator:^NSComparisonResult(UIWindow *obj1, UIWindow *obj2) {
        if (obj1.windowLevel == obj2.windowLevel)
        {
            return NSOrderedSame;
        }
        else if (obj1.windowLevel > obj2.windowLevel)
        {
            return NSOrderedDescending;
        }
        else
        {
            return NSOrderedAscending;
        }
    }];
    
    UIImage *image =
    [UIWindow growingHelper_screenshotWithWindows:windows
                                      andMaxScale:scale
                                            block:^(CGContextRef context) {
                                                //                                                CGContextSetStrokeColorWithColor(context, [[UIColor orangeColor] colorWithAlphaComponent:0.4].CGColor );
                                                //                                                CGContextSetLineWidth(context, 1);
                                            }];
    
    return image;
}

+ (CGFloat)impressScale
{
    CGFloat scale = [UIScreen mainScreen].scale;
    return MIN(scale, 2);
}

- (BOOL)isContainer:(id<GrowingNode>)node
{
    return [[self class] isContainer:node];
}

+ (BOOL)isContainer:(id<GrowingNode>)node
{
    // if node is like a button
    if ([node growingNodeUserInteraction])
    {
        return YES;
    }
    // if node is like a text label
    for (node = [node growingNodeParent]; node != nil; node = [node growingNodeParent])
    {
        if ([node growingNodeUserInteraction])
        {
            // text label is within a button, so it is not container
            return NO;
        }
    }
    // text label is standalone
    return YES;
}

- (NSMutableDictionary *)dictFromNode:(id<GrowingNode>)aNode
                             pageData:(NSDictionary *)pageData
                             keyIndex:(NSInteger)keyIndex
                                xPath:(NSString *)xPath
                             nodeType:(NSString *)nodeType
                          isContainer:(BOOL)isContainer
{
    if ( ![aNode growingNodeContent].length && ![aNode growingNodeUserInteraction] && ![aNode isKindOfClass:[WKWebView class]])
    {
        return nil;
    }
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict addEntriesFromDictionary:pageData];
    NSString *v = [aNode growingNodeContent];
    if (!v)
    {
        v = @"";
    }
    else
    {
        v = [v growingHelper_safeSubStringWithLength:50];
    }
    dict[@"content"] = [v stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    
    NSNumber *isClickable = [aNode growingNodeUserInteraction] ? @1 : @0;
    dict[@"isClickable"] = isClickable;

    if ([aNode isKindOfClass:NSClassFromString(@"_UIButtonBarButton")] || [aNode isKindOfClass:NSClassFromString(@"_UIModernBarButton")]) {
             dict[@"isClickable"] = @1 ;
    }
    
    if ([aNode isKindOfClass:[UITextField class]]
        || [aNode isKindOfClass:[UISearchBar class]]
        || [aNode isKindOfClass:[UITextView class]])
    {
        dict[@"isTrackingEditText"] = @YES;
        dict[@"isClickable"] = ((UIView *)aNode).userInteractionEnabled ? @1 : @0;
    }
    
    //判断是否是WKWebview
    if (@available(iOS 8.0, *)) {
        if ([aNode isKindOfClass:[WKWebView class]])  {
            dict[@"isWebview"] = @1;
            dict[@"isClickable"] = @1;
        }else{
            dict[@"isWebview"] = @0;
        }
    }else{
        dict[@"isWebview"] = @0;
    }
    
    //为anode元素添加 ，层级属性
    if ([aNode isKindOfClass:[UIView class]]) {
        self.nodeZLevel = aNode.growingNodeWindow.windowLevel ;
        self.zLevel = 0 ;
        [self getElementLevelInWindow:aNode andWindow:aNode.growingNodeWindow] ;
        dict[@"zLevel"] = [NSNumber numberWithInt:self.zLevel]  ;
    }
    
    if (keyIndex >= 0)
    {
        dict[@"index"] = [NSString stringWithFormat:@"%ld",(long)keyIndex];
    }
    dict[@"xpath"] = xPath;
    
    CGRect frame = [aNode growingNodeFrame];
    if (!CGRectEqualToRect(frame, CGRectZero))
    {
        CGFloat scale = [[self class] impressScale];
        dict[@"left"] = [NSNumber numberWithInt:(int)(frame.origin.x * scale)];
        dict[@"top"] = [NSNumber numberWithInt:(int)(frame.origin.y * scale)];
        dict[@"width"] = [NSNumber numberWithInt:(int)(frame.size.width * scale)];
        dict[@"height"] = [NSNumber numberWithInt:(int)(frame.size.height * scale)];
    }
    dict[@"nodeType"] = nodeType;
    dict[@"isContainer"] = @(isContainer);
    BOOL isTab = NO;
    if (![aNode isKindOfClass:[GrowingDullNode class]])
    {
        GrowingNodeManager *manager = [[GrowingEventNodeManager alloc] initWithNode:aNode
                                                                          eventType:GrowingEventTypeUIPageShow];
        __block id attribute = nil;
        [manager enumerateChildrenUsingBlock:^(id<GrowingNode> n, GrowingNodeManagerEnumerateContext *context) {
            [context stop];
            attribute = [context attributeValueForKey:GrowingAttributeIsTabbarInTabbarControllerKey];
        }];
        isTab = (attribute == GrowingAttributeReturnYESKey);
    }
    
    
    if ([aNode isKindOfClass:[UIView class]]) {
        UIView *view = (UIView *)aNode;
        if (view.growingViewCustomContent.length > 0) {
            dict[@"grContent"] = view.growingViewCustomContent;
        }
        // TODO: js
//        if (view.growingAttributesInfo.length > 0) {
//            dict[@"grObj"] = view.growingAttributesInfo;
//        }
    }
    
    dict[@"isTab"] = @(isTab);

    return dict;
}

- (void)getElementLevelInWindow:(id<GrowingNode>)aNode andWindow:(UIView *)superView{
    for (int i = 0 ; i < superView.subviews.count ; i ++) {
        self.nodeZLevel ++ ;
        if (superView.subviews[i] == aNode) {
            self.zLevel = self.nodeZLevel ;
        }else{
            [self getElementLevelInWindow:aNode andWindow:superView.subviews[i]];
        }
    }
}

- (NSString  *)getSK{
    NSString *r = [NSString stringWithFormat:@"%d",arc4random_uniform(10000)];
    if (![_randomNumber isEqualToString:r]) {
        _randomNumber = r ;
    }else{
        _randomNumber = [NSString stringWithFormat:@"%@new",r];
    }
    return _randomNumber ;
}


//web发送过来的数据
- (void)webSendData:(NSMutableDictionary *)dict{
    if (dict[@"x"] && dict[@"y"]) {
        CGFloat x = [dict[@"x"] floatValue] / [[self class] impressScale];
        CGFloat y = [dict[@"y"] floatValue] / [[self class] impressScale];
        CGPoint point = CGPointMake(x, y) ;
        WeakObject *weakObjc =  [self getHitWebview:point];
        [self exchangeHybridWithWeb:weakObjc andDic:dict];
    }else{
        for (WeakObject * weakObjc in self.gWebViewArray) {
            if ([weakObjc.webView isKindOfClass:[WKWebView class]]){
                WKWebView *webview = (WKWebView *)weakObjc.webView;
                NSString *jsonString = [dict growingHelper_jsonString];
                // TODO:js
//                NSString *jsStr = [NSString stringWithFormat:@"window._vds_hybrid.helper.handleWebEvent(%@)",jsonString];
//                [webview.growingHook_JavascriptCore executeJavascript:jsStr];
            }
        }
    }
}

//获取 WebView
- (WeakObject *)getHitWebview:(CGPoint )point{
    for (WeakObject * weakObjc in self.gWebViewArray) {
        if ( [self isInView:weakObjc.webView andPoint:point]) {
            return weakObjc ;
        }
    }
    return nil ;
}

//判断点是否在视图内
- (BOOL)isInView:(UIView *)view andPoint:(CGPoint )point{
    if (CGRectContainsPoint(view.frame, point)) {
        return YES ;
    }else{
        return NO ;
    }
}



//web向hybridd发送事件
-(void)exchangeHybridWithWeb:(WeakObject *)weakObjc andDic:(NSMutableDictionary *)dict{
    NSDictionary *dictFanal =  [self changeXYtoHybrid:dict andWeb:weakObjc.webView];
    NSString *jsonString = [dictFanal growingHelper_jsonString];
    NSString *jsStr = [NSString stringWithFormat:@"window._vds_hybrid.helper.handleWebEvent(%@)",jsonString];
    if (@available(iOS 8.0, *)) {
        if ([weakObjc.webView isKindOfClass:[WKWebView class]]){
            WKWebView *webview = (WKWebView *)weakObjc.webView;
            // TODO:js
//            [webview.growingHook_JavascriptCore executeJavascript:jsStr];
        }
    }
}

//存储webview数组
-(NSMutableArray *)gWebViewArray{
    if (!_gWebViewArray) {
        tempArray = [NSMutableArray array];
        _gWebViewArray = tempArray;
    }
    return _gWebViewArray ;
}

//转换坐标给hybrid
-(NSDictionary *)changeXYtoHybrid:(NSMutableDictionary *)dict andWeb:(id<GrowingNode>)web{
    NSArray *keys = [dict allKeys];
    CGRect frameRect =  [web growingNodeFrame];
    CGFloat insetX = 0;
    CGFloat insetY = 0;
    
    CGFloat scale = [UIScreen mainScreen].scale;
    
    UIScrollView *scrollView;
    if ([web respondsToSelector:@selector(scrollView)]) {
        scrollView = [web performSelector:@selector(scrollView)];
    }
    
    if (@available(iOS 11.0, *)) {
        insetX += scrollView.adjustedContentInset.left;
        insetY += scrollView.adjustedContentInset.top;
    }
    
    insetX += scrollView.contentInset.left;
    insetY += scrollView.contentInset.top;

    for (int i = 0; i < keys.count; i++)
    {
        if ([keys[i] isEqualToString:@"x"]) {
            float x = [dict[keys[i]] floatValue];
            x = x / [[self class] impressScale] * scale - frameRect.origin.x * scale - insetX * scale;
            dict[@"x"] = [NSNumber numberWithFloat:x];
        } else if ([keys[i] isEqualToString:@"y"]) {
            float y = [dict[keys[i]] floatValue];
            y = y / [[self class] impressScale] * scale - frameRect.origin.y * scale - insetY * scale;
            dict[@"y"] = [NSNumber numberWithFloat:y];
        } else if ([keys[i] isEqualToString:@"ex"]) {
            float ex = [dict[keys[i]] floatValue];
            ex = ex / [[self class] impressScale] * scale - frameRect.origin.x * scale - insetX * scale;
            dict[@"ex"] = [NSNumber numberWithFloat:ex];
        } else if ([keys[i] isEqualToString:@"ey"]) {
            float ey = [dict[keys[i]] floatValue];
            ey = ey / [[self class] impressScale] * scale - frameRect.origin.y * scale - insetY * scale;
            dict[@"ey"] = [NSNumber numberWithFloat:ey];
        } else if ([keys[i] isEqualToString:@"ew"]) {
            float ew = [dict[keys[i]] floatValue];
            ew = ew / [[self class] impressScale] * scale;
            dict[@"ew"] = [NSNumber numberWithFloat:ew];
        } else if ([keys[i] isEqualToString:@"eh"]) {
            float eh = [dict[keys[i]] floatValue];
            eh = eh / [[self class] impressScale] * scale;
            dict[@"eh"] = [NSNumber numberWithFloat:eh];
        }
    }
    return dict ;
}
//转换坐标给web
-(NSDictionary *)changeXYtoWeb:(NSMutableDictionary *)dict andWeb:(id<GrowingNode>)web{
    NSArray *keys = [dict allKeys];
    __block  CGRect frameRect =  [web growingNodeFrame];
    GIOLogDebug(@"frameRect.origin.x %f frameRect.origin.y %f", frameRect.origin.x ,frameRect.origin.y) ;
    CGFloat insetX = 0;
    CGFloat insetY = 0;
    
    CGFloat scale = [UIScreen mainScreen].scale;
    
    UIScrollView *scrollView;
    if ([web respondsToSelector:@selector(scrollView)]) {
        scrollView = [web performSelector:@selector(scrollView)];
    }
    
    if (@available(iOS 11.0, *)) {
        insetX += scrollView.adjustedContentInset.left;
        insetY += scrollView.adjustedContentInset.top;
    }
    
    insetX += scrollView.contentInset.left;
    insetY += scrollView.contentInset.top;
    
    for (int i = 0; i < keys.count; i++)
    {
        if ([keys[i] isEqualToString:@"ex"]) {
            float ex = [dict[keys[i]] floatValue];
            ex = ex / scale * [[self class] impressScale] + frameRect.origin.x * [[self class] impressScale] + insetX * [[self class] impressScale];
            dict[@"ex"] = [NSNumber numberWithFloat:ex];
        } else if ([keys[i] isEqualToString:@"ey"]) {
            float ey = [dict[keys[i]] floatValue];
            ey = ey / scale * [[self class] impressScale] + frameRect.origin.y * [[self class] impressScale] +  insetY  * [[self class] impressScale];
            dict[@"ey"] = [NSNumber numberWithFloat:ey];
        } else if ([keys[i] isEqualToString:@"x"]) {
            float x = [dict[keys[i]] floatValue];
            x = x / scale * [[self class] impressScale] + frameRect.origin.x * [[self class] impressScale] + insetX * [[self class] impressScale];
            dict[@"x"] = [NSNumber numberWithFloat:x];
        } else if ([keys[i] isEqualToString:@"y"]) {
            float y = [dict[keys[i]] floatValue];
            y = y / scale * [[self class] impressScale] + frameRect.origin.y * [[self class] impressScale] +  insetY  * [[self class] impressScale];
            dict[@"y"] = [NSNumber numberWithFloat:y];
        } else if ([keys[i] isEqualToString:@"ew"]) {
            float ew = [dict[keys[i]] floatValue];
            ew = ew / scale * [[self class] impressScale];
            dict[@"ew"] = [NSNumber numberWithFloat:ew];
        } else if ([keys[i] isEqualToString:@"eh"]) {
            float eh = [dict[keys[i]] floatValue];
            eh = eh / scale * [[self class] impressScale];
            dict[@"eh"] = [NSNumber numberWithFloat:eh];
        }
       
        if ([keys[i] isEqualToString:@"p"] || [keys[i] isEqualToString:@"q"] || [keys[i] isEqualToString:@"h"] || [keys[i] isEqualToString:@"rp"])
        {
            // TODO: js
//            GrowingJavascriptCore *javascriptCore = nil;
//            if ([web respondsToSelector:@selector(growingHook_JavascriptCore)]) {
//                javascriptCore = [web performSelector:@selector(growingHook_JavascriptCore)];
//            }
//
//            id value = [javascriptCore stringByRemovingLocalDir:dict[keys[i]]];
//            dict[keys[i]] = value ;
        }
    }
    return dict ;
}


- (void)fillAllViewsForWebCircle:(NSDictionary *)dataDict completion:(void(^)(NSMutableDictionary * dict))completion
{
    NSMutableArray *arr = [[NSMutableArray alloc] init];
    GrowingNodeManager *manager = [[GrowingNodeManager alloc] initWithNodeAndParent:[GrowingRootNode rootNode] checkBlock:^BOOL(id<GrowingNode> node) {
        if ([node growingNodeDonotTrack] || [node growingNodeDonotCircle])
        {
            return NO;
        }
        else
        {
            return YES;
        }
    }];
    
    NSMutableDictionary *modifiedPageData = [[NSMutableDictionary alloc] init];
    modifiedPageData[@"page"] = [[[GrowingPageManager sharedInstance] currentViewController] growingPageName] ?: @"";
    modifiedPageData[@"domain"] = [GrowingDeviceInfo currentDeviceInfo].bundleID;
    
    NSMutableDictionary * finalDataDict = [NSMutableDictionary dictionaryWithDictionary:dataDict];
    
    __block int asyncNativeHandlerWaitingCount = 0;
    [self.gWebViewArray removeAllObjects];
    self.gWebViewArray = nil ;
    [manager enumerateChildrenUsingBlock:^(id<GrowingNode> aNode, GrowingNodeManagerEnumerateContext *context)  {
        //支持WKWebview
        if (@available(iOS 8.0, *)) {
            if ([aNode isKindOfClass:[WKWebView class]]) {
                WKWebView *wkweb = (WKWebView *)aNode ;
                WeakObject *weakObjc = [[WeakObject alloc] init];
                weakObjc.webView = wkweb ;
                if (![self.gWebViewArray containsObject:weakObjc]) {
                    [self.gWebViewArray addObject:weakObjc];
                    // TODO: js
//                    wkweb.growingHook_JavascriptCore.webScoketDelegate = self ;
                }
            }
        }
        
        if ([aNode isKindOfClass:[GrowingWindow class]])
        {
            [context skipThisChilds];
            return;
        }
        
        if (![aNode isKindOfClass:[WKWebView class]]) {
            id<GrowingNodeAsyncNativeHandler> asyncHandler = [aNode growingNodeAsyncNativeHandler];
            if (asyncHandler != nil && ![aNode growingNodeDonotTrack] && [asyncHandler isResponsive])
            {
                asyncNativeHandlerWaitingCount++;
                [asyncHandler getAllNode:^(NSArray<GrowingDullNode *> *nodes, NSDictionary *webViewPageData) {
                    if (nodes.count > 0)
                    {
                        // TODO:js
                        // 拼page和domain
//                        NSString * mergedPage = [GrowingJavascriptCore jointField:modifiedPageData[@"page"]
//                                                                        withField:webViewPageData[@"p"]];
//                        NSString * mergedDomain = [GrowingJavascriptCore jointField:modifiedPageData[@"domain"]
//                                                                          withField:webViewPageData[@"d"]];
                        NSMutableDictionary * modifiedWebViewPageData = [[NSMutableDictionary alloc] init];
                        if (webViewPageData[@"q"] != nil)
                        {
                            modifiedWebViewPageData[@"query"] = webViewPageData[@"q"];
                        }
                        if (webViewPageData[@"h"] != nil)
                        {
                            modifiedWebViewPageData[@"href"] = webViewPageData[@"h"];
                        }
//                        modifiedWebViewPageData[@"page"] = mergedPage;
//                        modifiedWebViewPageData[@"domain"] = mergedDomain;
                        for (NSUInteger i = 0; i < nodes.count; i++)
                        {
                            GrowingDullNode * node = nodes[i];
                            NSMutableDictionary * dict = [self dictFromNode:node
                                                                   pageData:modifiedWebViewPageData
                                                                   keyIndex:node.growingNodeKeyIndex
                                                                      xPath:node.growingNodeXPath
                                                                   nodeType:node.growingNodeType
                                                                isContainer:YES];
                            if (dict.count > 0)
                            {
                                [arr addObject:dict];
                            }
                        }
                    }
                    asyncNativeHandlerWaitingCount--;
                    if (asyncNativeHandlerWaitingCount == 0)
                    {
                        finalDataDict[@"impress"] = arr;
                        if (completion != nil)
                        {
                            completion(finalDataDict);
                        }
                    }
                }];
                return;
            }
        }
        NSMutableDictionary * dict = [self dictFromNode:aNode
                                               pageData:modifiedPageData
                                               keyIndex:context.nodeKeyIndex
                                                  xPath:context.xpath
                                               nodeType:[aNode growingNodeUserInteraction] ? @"button" : @"text"
                                            isContainer:[self isContainer:aNode]];
        if (dict.count > 0)
        {
            [arr addObject:dict];
        }
    }];
    
    if (asyncNativeHandlerWaitingCount == 0)
    {
        finalDataDict[@"impress"] = arr;
        if (completion != nil)
        {
            completion(finalDataDict);
        }
    }
}


-(void)didRecieveWkWebivewMesage:(WKScriptMessage *)scriptMessage andWebview:(WKWebView *)wkWeb API_AVAILABLE(ios(8.0)){
    if ([scriptMessage.body isKindOfClass:[NSString class]]) {
        //        NSArray * callbackDataDictionaryArray = (NSArray *)scriptMessage.body;
        NSString *str = scriptMessage.body;
        id message =  [str growingHelper_jsonObject] ;
        GIOLogDebug(@"message %@",[message class]);
        if([message isKindOfClass:[NSDictionary class]]){
            NSMutableDictionary *dict = [message mutableCopy];
            dict[@"msgId"] = @"hybridEvent" ;
            dict[@"sk"] = self.randomNumber;
            NSMutableArray *array = [dict[@"e"] mutableCopy];
            for (int i = 0 ; i < array.count; i ++) {
                NSMutableDictionary *dict =  [array[i] mutableCopy];
                NSDictionary *tempDic = [self changeXYtoWeb:dict andWeb:wkWeb];
                array[i] = tempDic ;
            }
            dict[@"e"] = array ;

            //已圈选元素
            if (dict[@"el"]) {
                NSMutableArray *arrayEl = [dict[@"el"] mutableCopy];
                for (int i = 0 ; i < arrayEl.count; i ++) {
                    NSMutableDictionary *dict =  [arrayEl[i] mutableCopy];
                    NSDictionary *tempDic = [self changeXYtoWeb:dict andWeb:wkWeb];
                    arrayEl[i] = tempDic ;
                }
                dict[@"el"] = arrayEl ;
            }
            
            //热图元素
            if (dict[@"heatmap"]) {
                NSMutableArray *arrayHM = [dict[@"heatmap"] mutableCopy];
                for (int i = 0 ; i < arrayHM.count; i++) {
                    NSMutableDictionary *dict =  [arrayHM[i] mutableCopy];
                    NSDictionary *tempDic = [self changeXYtoWeb:dict andWeb:wkWeb];
                    arrayHM[i] = tempDic ;
                }
                dict[@"heatmap"] = arrayHM ;
            }

            //同类元素坐标转化
            if (dict[@"similar"]) {
                NSMutableArray *arraySimilar = [dict[@"similar"] mutableCopy];
                for (int i = 0 ; i < arraySimilar.count; i ++) {
                    NSMutableDictionary *dict =  [arraySimilar[i] mutableCopy];
                    NSDictionary *tempDic = [self changeXYtoWeb:dict andWeb:wkWeb];
                    arraySimilar[i] = tempDic ;
                }
                dict[@"similar"] = arraySimilar ;
            }
            // TODO: js
//            if (dict[@"p"])
//            {
//                id value = [wkWeb.growingHook_JavascriptCore stringByRemovingLocalDir:dict[@"p"]];
//                dict[@"p"] = value ;
//            }
//            if (dict[@"q"])
//            {
//                id value = [wkWeb.growingHook_JavascriptCore stringByRemovingLocalDir:dict[@"q"]];
//                dict[@"q"] = value ;
//            }
//            if (dict[@"h"])
//            {
//                id value = [wkWeb.growingHook_JavascriptCore stringByRemovingLocalDir:dict[@"h"]];
//                dict[@"h"] = value ;
//            }
//            if (dict[@"rp"])
//            {
//                id value = [wkWeb.growingHook_JavascriptCore stringByRemovingLocalDir:dict[@"rp"]];
//                dict[@"rp"] = value ;
//            }
            
            GIOLogDebug(@"发送给web %@",dict) ;
            [self sendJson:dict];
        }
    }
}

-(void)onDomChangeWkWebivew{
    [self setNeedUpdateScreen];
}
- (NSDictionary *)dictForUserAction:(NSString *)action
{
    if (action.length == 0) {
        return nil;
    }
    
    UIViewController *vc = [[GrowingPageManager sharedInstance] currentViewController];
    UIImage *image = [self screenShot];
    NSData *data = [image growingHelper_JPEG:0.8];
    
    NSString *imgBase64Str = [data growingHelper_base64String];
    
    if(!data.length || !imgBase64Str.length)
    {
        return nil;
    }
    
    
    NSDictionary *sdkConfig = @{
                                @"sdkVersion"        :[Growing getTrackVersion],
                                @"appVersion"        :[GrowingDeviceInfo currentDeviceInfo].appFullVersion,
                                @"isTrackWebView"    :@(YES)
                                };
    
    // TODO：如果要传 avar，pvar，evar 等变量，在这里准备好，然后塞到下面的 dict 中
    
    NSDictionary *dict = @{
                           @"msgId"             :@"user_action",
                           @"userAction"        :action,
                           @"title"             :[vc growingPageTitle] ?: @"",
                           @"page"              :[vc growingPageName] ?: @"",
                           @"domain"            :[GrowingDeviceInfo currentDeviceInfo].bundleID,
                           @"screenshot"        :[@"data:image/jpeg;base64," stringByAppendingString:imgBase64Str],
                           @"screenshotWidth"   :@(image.size.width * image.scale),
                           @"screenshotHeight"  :@(image.size.height * image.scale),
                           @"sdkVersion"        :[Growing getTrackVersion],
                           @"appVersion"        :[GrowingDeviceInfo currentDeviceInfo].appFullVersion,
                           @"actionDesc"        :@"a",
                           @"sdkConfig"         :sdkConfig,
                           @"sk"         :[self getSK],
                           };
    
    return dict;
}

- (void)sendScreenShot
{
    [self sendScreenShotWithEventType:nil optionalTargets:nil optionalNodeName:nil optionalPageName:nil callback:nil];
}

+ (void)retrieveAllElementsAsync:(void(^)(NSString *))callback
{
    [[self shareInstance] sendScreenShotWithEventType:nil optionalTargets:nil optionalNodeName:nil optionalPageName:nil callback:callback];
}

- (void)sendScreenShotWithEventType:(NSString*)eventType // nil or clck or page
                    optionalTargets:(NSArray<NSDictionary *> *)targets // valid if eventType is clck
                   optionalNodeName:(NSString *)nodeName // valid if eventType is clck
                   optionalPageName:(NSString *)pageName // valid if eventType is page
                           callback:(void (^)(NSString *))callback // in case of error, the callback parameter is nil
{
    NSMutableDictionary * dict = [[NSMutableDictionary alloc] init];
    NSString * userAction = nil;
    NSString * userActionDescription = nil;
    if (eventType == nil)
    {
        userAction = @"refresh";
        userActionDescription = @"更新截图";
    }
    else if ([eventType isEqualToString:@"page"])
    {
        userAction = @"page";
        userActionDescription = [NSString stringWithFormat:@"进入了%@", pageName];
    }
    else if ([eventType isEqualToString:@"clck"])
    {
        userAction = @"click";
        userActionDescription = [NSString stringWithFormat:@"点击了%@", nodeName];
    }
    //    else
    //    {
    //        userAction = @"touch";
    //        userActionDescription = [NSString stringWithFormat:@"点击了%@", nodeName];
    //    }
    [dict addEntriesFromDictionary:[self dictForUserAction:userAction]];
    if (dict.count == 0)
    {
        if (callback != nil)
        {
            callback(nil);
        }
        return;
    }
    dict[@"actionDesc"] = userActionDescription;
    
    __weak GrowingWebSocket * wself = self;
    [self fillAllViewsForWebCircle:dict completion:^(NSMutableDictionary * dict) {
        GrowingWebSocket * sself = wself;
        // assign parentXPath for each event in "impress", and assign targets
        {
            NSMutableArray<NSDictionary *> * allContainers = [[NSMutableArray alloc] init];
            NSArray<NSMutableDictionary *> * allImpressedEvent = dict[@"impress"];
            for (NSDictionary * event in allImpressedEvent)
            {
                NSNumber * isContainer = event[@"isContainer"];
                if (isContainer != nil && [isContainer boolValue])
                {
                    [allContainers addObject:event];
                }
            }
            [allContainers sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
                NSDictionary * event1 = obj1;
                NSDictionary * event2 = obj2;
                if ([event1[@"xpath"] length] > [event2[@"xpath"] length])
                {
                    return NSOrderedAscending;
                }
                else if ([event1[@"xpath"] length] < [event2[@"xpath"] length])
                {
                    return NSOrderedDescending;
                }
                else
                {
                    return NSOrderedSame;
                }
            }];
            for (NSMutableDictionary * event in allImpressedEvent)
            {
                NSNumber * isContainer = event[@"isContainer"];
                if (isContainer == nil || ![isContainer boolValue])
                {
                    NSString * eventXPath = event[@"xpath"];
                    for (NSInteger i = 0; i < allContainers.count; i++)
                    {
                        NSString * containerXPath = allContainers[i][@"xpath"];
                        if ([eventXPath hasPrefix:containerXPath])
                        {
                            event[@"parentXPath"] = containerXPath;
                            break;
                        }
                    }
                }
            }
            
            if (targets) {
                dict[@"targets"] = targets;
            }
        }
        if (sself != nil)
        {
            [sself sendJson:dict];
        }
        if (callback != nil)
        {
            NSString * dictString = [dict growingHelper_jsonString];
            callback(dictString); // dictString == nil for error
        }
    }];
}

- (void)sendClickOrTouchAction
{
}

- (void)remoteReady
{
    [self sendScreenShot];
}

- (void)addActions
{
    __weak GrowingWebSocket *wself = self;
    
//    [self addActionItemAtPath:@[@"msgId",@"editor_ready"] action:^(id something) {
//        [wself remoteReady];
//        wself.statusWindow.statusLable.text = @"正在进行GrowingIO移动端圈选";
//        wself.statusWindow.statusLable.textAlignment = NSTextAlignmentCenter ;
//        if (wself.onReadyBlock)
//        {
//            wself.onReadyBlock();
//            wself.onReadyBlock = nil;
//        }
//    }];
//    [self addActionItemAtPath:@[@"msgId",@"incompatible_version"] action:^(id something) {
//        GrowingMenuButton *btn = [GrowingMenuButton buttonWithTitle:@"知道了" block:nil];
//        [GrowingAlertMenu alertWithTitle:@"抱歉" text:@"您使用的SDK版本号过低,请升级SDK后再使用"
//                                 buttons:@[btn]];
//        [wself stop];
//    }];
//    [self addActionItemAtPath:@[@"msgId",@"editor_quit"] action:^(id something) {
//        [wself _stopWithError:@"当前设备已与Web端断开连接,如需继续圈选请扫码重新连接。"];
//    }];
}

- (void)runWithCircleRoomNumber:(NSString *)circleRoomNumber ReadyBlock:(void(^)(void))readyBlock finishBlock:(void(^)(void))finishBlock {
    if (!self.webSocket) {
        [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleDeviceOrientationDidChange:) name:UIDeviceOrientationDidChangeNotification object:nil];
        
        [UIApplication sharedApplication].idleTimerDisabled = YES;
        GIOLogDebug(@"开始起服务");
        if (!self.statusWindow) {
            self.statusWindow = [[GrowingStatusBar alloc] initWithFrame:[UIScreen mainScreen].bounds];
            self.statusWindow.hidden = NO;
            self.statusWindow.statusLable.text = @"正在等待web链接";
            self.statusWindow.statusLable.textAlignment = NSTextAlignmentCenter ;
            
            __weak typeof(self) wself = self;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                if (wself && [wself.statusWindow.statusLable.text isEqualToString:@"正在等待web链接"]){
//                    [GrowingAlertMenu alertWithTitle:@"提示"
//                                                text:@"电脑端连接超时，请刷新电脑页面，再次尝试扫码圈选。"
//                                             buttons:@[[GrowingMenuButton buttonWithTitle:@"知道了" block:nil]]];
                }
            });
            self.statusWindow.onButtonClick = ^{
                
//                GrowingMenuButton *btn = [GrowingMenuButton buttonWithTitle:@"继续圈选"
//                                                                      block:nil];
//                GrowingMenuButton *btn2 = [GrowingMenuButton buttonWithTitle:@"退出圈选"
//                                                                       block:^{
//                                                                           [GrowingWebSocket stop];
//                                                                       }];
//
//                [GrowingAlertMenu alertWithTitle:@"正在进行圈选"
//                                           text1:[NSString stringWithFormat:@"APP版本: %@", [GrowingDeviceInfo currentDeviceInfo].appShortVersion]
//                                           text2:[NSString stringWithFormat:@"SDK版本: %@", [Growing sdkVersion]]
//                                         buttons:@[btn,btn2]];
            };
        }
        
        
//        [self addActions];
        NSString *urlStr = @"wss://gta1.growingio.com/app/0a1b4118dd954ec3bcc69da5138bdb96/circle/p5Xvy2Mt5OIkWHg8";
        self.webSocket = [[GrowingSRWebSocket alloc] initWithURLRequest: [NSURLRequest requestWithURL: [NSURL URLWithString:urlStr]]];
        self.webSocket.delegate = self;
        [self.webSocket open];
//        // Create server using our custom GrowingHTTPServer class
//        self.httpServer = [[GrowingHTTPServer alloc] init];
//
//        // Tell server to use our custom GrowingWebCircleHTTPConnection class.
//        [self.httpServer setConnectionClass:[GrowingWebCircleHTTPConnection class]];
//
//        // Tell the server to broadcast its presence via Bonjour.
//        // This allows browsers such as Safari to automatically discover our service.
//        [self.httpServer setType:@"_http._tcp."];
        
        // Normally there's no need to run our server on any specific port.
        // Technologies like Bonjour allow clients to dynamically discover the server's port at runtime.
        // However, for easy testing you may want force a certain port so you can just hit the refresh button.
//        [self.httpServer setPort:8080];
        
        // Start the server (and check for problems)
//        NSError *error;
//        if(![self.httpServer start:&error])
//        {
//            GIOLogError(@"Error starting HTTP Server: %@", error);
//        } else {
//            NSString *ip = [self getIPAddress];
//            if (ip.length != 0) {
//                NSString *ws = [NSString stringWithFormat:@"ws://%@:%d/service", ip, [self.httpServer listeningPort]];
//
//                [[GrowingLocalCircleModel sdkInstance] postWSUrl:ws
//                                                         pairKey:circleRoomNumber succeed:^(NSHTTPURLResponse *httpResponse, NSData *data) {
//                                                             NSDictionary *dict = [data growingHelper_dictionaryObject];
//                                                             NSString *status = dict[@"status"];
//                                                             if ([status isEqualToString:@"ok"]) {
//                                                                 GIOLogDebug(@"web圈app native 传送ws服务成功");
//                                                             } else {
//                                                                 [self _stopWithError:@"post ws url error,请刷新网页重新扫描二维码"];
//                                                             }
//
//                                                         }
//                                                            fail:^(NSHTTPURLResponse *httpResponse, NSData *data, NSError *error) {
//                                                                NSDictionary *dict = [data growingHelper_dictionaryObject];
//                                                                if ([dict[@"status"] isEqualToString:@"has"]) {
//                                                                    [self _stopWithError:@"web圈app 已有手机连接"];
//                                                                } else {
//                                                                    [self _stopWithError:@"post ws url error,请刷新网页重新扫描二维码"];
//                                                                }
//                                                            }];
//            } else {
//                //not get valid ip address
//                [self _stopWithError:@"未获取到IP地址,请确保手机已经链接Wifi"];
//            }
//        }
        
        self.onReadyBlock = readyBlock;
        self.onFinishBlock = finishBlock;
        
        // this requirs a valid token, so it might fail silently
//        [[GrowingLocalCircleModel sdkInstance] requestAllTagItemsSucceed:nil fail:nil];
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

- (NSString *)getIPAddress {
    NSString *address = nil;
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    // retrieve the current interfaces - returns 0 on success
    success = getifaddrs(&interfaces);
    if (success == 0) {
        // Loop through linked list of interfaces
        temp_addr = interfaces;
        while(temp_addr != NULL) {
            if(temp_addr->ifa_addr->sa_family == AF_INET) {
                // Check if interface is en0 which is the wifi connection on the iPhone
                if([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"]) {
                    // Get NSString from C String
                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                }
            }
            temp_addr = temp_addr->ifa_next;
        }
    }
    // Free memory
    freeifaddrs(interfaces);
    return address;
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
    NSDictionary *dict = @{@"msgId":@"heartbeat"};
    [self sendJson:dict];
}

- (void)stop {
    GIOLogDebug(@"开始断开连接");
    NSDictionary *dict = @{@"msgId":@"client_quit"};
    [self sendJson:dict];
    self.statusWindow.statusLable.text = @"正在关闭web圈选...";
    self.statusWindow.statusLable.textAlignment = NSTextAlignmentCenter;
    [self _stopWithError:nil];
}

- (void)_stopWithError:(NSString*)error {
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
        // TODO: add Alert
//        [GrowingAlertMenu alertWithTitle:@"设备已断开连接"
//                                    text:error
//                                 buttons:@[[GrowingMenuButton buttonWithTitle:@"知道了" block:nil]]];
    }
}

- (BOOL)isRunning {
    return self.webSocket != nil;
}

- (void)sendJson:(id)json {
    if (self.isConnected && ([json isKindOfClass:[NSDictionary class]]
                             || [json isKindOfClass:[NSArray class]])) {
        NSString *jsonString = [json growingHelper_jsonString];
        [self.webSocket send:jsonString];
    }
}

#pragma mark - Websocket Delegate

- (void)webSocket:(GrowingSRWebSocket *)webSocket didReceiveMessage:(id)message {
    if ([message isKindOfClass:[NSString class]]) {
        // TODO:js
//        [self runActionWithJsonObj:[message growingHelper_jsonObject]];
        NSMutableDictionary *dict = [[message growingHelper_jsonObject] mutableCopy];
        //如果收到了ready消息，说明可以发送圈选数据了
        if ([[dict objectForKey:@"msgType"] isEqualToString:@"ready"])  {
            self.isReady = YES;
            [[GrowingEventManager shareInstance] addObserver:self];
            //webSocket连接成功的速度比viewDidAppear慢,因此page事件没有发送成功
            //解决方式在webSocket链接成功后 再发一次page事件
            [[[GrowingPageManager sharedInstance] currentViewController] growingTrackSelfPage];
        }
    }
}

- (void)webSocketDidOpen:(GrowingSRWebSocket *)webSocket {
    self.isConnected = YES;
    GIOLogDebug(@"web已连接websocket server");
    CGSize screenSize = [GrowingDeviceInfo deviceScreenSize];
    NSDictionary *dict = @{@"projectId" :[Growing getDeviceId],
                           @"msgType"   :@"ready",
                           @"timestamp" :@([[NSDate date] timeIntervalSince1970]),
                           @"domain"    :[GrowingDeviceInfo currentDeviceInfo].bundleID,
                           @"sdkVersion":[Growing getTrackVersion],
                           @"appVersion":[GrowingDeviceInfo currentDeviceInfo].appFullVersion,
                           @"os":@"iOS",
                           @"screenWidth":[NSNumber numberWithInteger:screenSize.width],
                           @"screenHeight":[NSNumber numberWithInteger:screenSize.height],};
    [self sendJson:dict];
    
    //[self beginKeepAlive];
    
    
}

- (void)webSocket:(GrowingSRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean {
    self.isConnected = NO;
    GIOLogDebug(@"已断开链接");
    [self _stopWithError:@"当前设备已与Web端断开连接,如需继续圈选请扫码重新连接。"];
}

- (void)webSocket:(GrowingSRWebSocket *)webSocket didFailWithError:(NSError *)error {
    GIOLogDebug(@"error : %@", error);
    [self _stopWithError:@"服务器链接失败"];
}

- (void)webSocket:(GrowingSRWebSocket *)webSocket didReceivePong:(NSData *)pongPayload {
    
}

#pragma mark - Nodes

- (NSString *)getViewControllerName:(UIViewController *)viewController {
    NSString * currentPageName = [viewController growingPageName];
    if (!currentPageName.length) {
        currentPageName = [viewController growingPageName];
    }
    //TODO:js
//    NSString * taggedPageName = [[GrowingLocalCircleModel sdkInstance] getControllerTagedName:currentPageName];
//    if (taggedPageName.length > 0)
//    {
//        currentPageName = taggedPageName;
//    }
    if (currentPageName.length > 0) {
        return currentPageName;
    } else {
        return @"页面";
    }
}

- (NSString *)getNodeName:(id<GrowingNode>)node withXPath:(NSString *)xPath withKeyIndex:(NSInteger)keyIndex withContent:(NSString *)content withPage:(NSString *)page {
    __block NSString * plainXPath = nil;
    void (^updatePlainXPath)(NSString * x) = ^void(NSString * x) {
        plainXPath = x;
    };
    // TODO:js
//    for (GrowingTagItem * item in [[GrowingLocalCircleModel sdkInstance] cacheTagItems])
//    {
//        if (item.index == [GrowingNodeItemComponent indexNotDefine] || item.index == keyIndex)
//        {
//            if (item.content.length == 0 || [item.content isEqualToString:content])
//            {
//                if (item.page.length == 0 || [item.page isEqualToString:page])
//                {
//                    if (item.name.length > 0)
//                    {
//                        if ([GrowingNodeManager isElementXPath:xPath orElementPlainXPath:plainXPath matchToTagXPath:item.xpath updatePlainXPathBlock:updatePlainXPath]){
//                            return item.name;
//                        }
//                    }
//                }
//            }
//        }
//    }
    
    if ([node isKindOfClass:[GrowingDullNode class]]) {
        if (content.length != 0) {
            return content;
        }
    } else {
        __block CGFloat maxFontSize = 0.0;
        __block NSString * maxFontContent = nil;
        GrowingNodeManager * manager = [[GrowingEventNodeManager alloc] initWithNode:node
                                                                           eventType:GrowingEventTypeUIPageShow];
        [manager enumerateChildrenUsingBlock:^(id<GrowingNode> aNode, GrowingNodeManagerEnumerateContext *context) {
            NSString * content = [aNode growingNodeContent];
            BOOL userInteractive = [aNode growingNodeUserInteraction];
            if (content.length > 0) {
                if ([aNode isKindOfClass:[UILabel class]]) {
                    UILabel *lbl = (UILabel*)aNode;
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
    }
    
    return @"按钮";
}

#pragma mark - GrowingEventManagerObserver
- (void)growingEventManagerWillAddEvent:(GrowingEvent* _Nullable)event
                               thisNode:(id<GrowingNode> _Nullable)thisNode
                            triggerNode:(id<GrowingNode> _Nullable)triggerNode
                            withContext:(id<GrowingAddEventContext> _Nullable)context {
    __weak GrowingWebSocket * wself = self;
    NSString * eventType = event.dataDict[@"t"];
    if ([eventType isEqualToString:@"clck"]
        //        || [eventType isEqualToString:@"tchd"]
        || [eventType isEqualToString:@"lngclck"]
        || [eventType isEqualToString:@"dbclck"]) {
        NSMutableDictionary * pageData = [[NSMutableDictionary alloc] init];
        NSString * page = event.dataDict[@"p"];
        pageData[@"page"] = page;
        pageData[@"domain"] = event.dataDict[@"d"];
        if ([thisNode isKindOfClass:[GrowingDullNode class]]) {
            if (event.dataDict[@"q"] != nil) {
                pageData[@"query"] = event.dataDict[@"q"];
            }
            if (event.dataDict[@"h"] != nil) {
                pageData[@"href"] = event.dataDict[@"h"];
            }
        }
        
        NSInteger keyIndex = event.dataDict[@"idx"]
        ? [event.dataDict[@"idx"] integerValue]
        : [GrowingNodeItemComponent indexNotFound];
        NSString * nodeType = [thisNode isKindOfClass:[GrowingDullNode class]]
        ? [((GrowingDullNode *)thisNode) growingNodeType]
        : ([thisNode growingNodeUserInteraction] ? @"button" : @"text");
        NSString * xPath = event.dataDict[@"x"];
        BOOL isContainer = [self isContainer:thisNode];
        NSMutableDictionary * dict = [self dictFromNode:thisNode
                                               pageData:pageData
                                               keyIndex:keyIndex
                                                  xPath:xPath
                                               nodeType:nodeType
                                            isContainer:isContainer];
        if (dict.count <= 0) {
            return;
        }
        NSString * nodeName = [self getNodeName:thisNode withXPath:xPath withKeyIndex:keyIndex withContent:[thisNode growingNodeContent] withPage:page];
        dict[@"_nodeName"] = nodeName;
        [self.cachedEvents addObject:dict];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            GrowingWebSocket * sself = wself;
            if (sself.cachedEvents.count == 0) {
                return;
            }
            
            NSMutableArray<NSMutableDictionary *> * cachedEvents = sself.cachedEvents;
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
            NSString * nodeName = cachedEvents[rootIndex][@"_nodeName"];
            for (NSInteger i = 0; i < cachedEvents.count; i++)
            {
                [cachedEvents[i] removeObjectForKey:@"_nodeName"];
            }
            [self sendScreenShotWithEventType:@"clck" optionalTargets:cachedEvents optionalNodeName:nodeName optionalPageName:nil callback:nil];
        });
    } else if ([eventType isEqualToString:@"page"]) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            NSString * pageName = [thisNode isKindOfClass:[UIViewController class]]
            ? [self getViewControllerName:(UIViewController *)thisNode]
            : event.dataDict[@"p"];
            [self sendScreenShotWithEventType:@"page" optionalTargets:nil optionalNodeName:nil optionalPageName:pageName callback:nil];
        });
    }
}

- (BOOL)growingEventManagerShouldAddEvent:(GrowingEvent* _Nullable)event
                              triggerNode:(id<GrowingNode> _Nullable)triggerNode
                              withContext:(id<GrowingAddEventContext> _Nullable)context {
    for (id<GrowingNode> obj in [context contextNodes]) {
        if ([obj isKindOfClass:[GrowingWindow class]]) {
            return NO;
        }
        if ([obj isKindOfClass:[UIView class]]) {
            UIView * view = (UIView *)obj;
            return ![view.window isKindOfClass:[GrowingWindow class]];
        }
    }
    return YES;
}

@end
