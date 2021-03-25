//
// GrowingMobileDebugger.m
// GrowingAnalytics
//
//  Created by gio on 2021/3/2.
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


#import "GrowingMobileDebugger.h"
#import <UIKit/UIKit.h>
#import <arpa/inet.h>
#import <ifaddrs.h>
#import "GrowingAlert.h"
#import "GrowingApplicationEventManager.h"
#import "GrowingAttributesConst.h"
#import "GrowingAutotrackEventType.h"
#import "GrowingCocoaLumberjack.h"
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
#import "NSArray+GrowingHelper.h"
#import "NSData+GrowingHelper.h"
#import "NSDictionary+GrowingHelper.h"
#import "NSString+GrowingHelper.h"
#import "NSURL+GrowingHelper.h"
#import "UIApplication+GrowingHelper.h"
#import "UIImage+GrowingHelper.h"
#import "UIViewController+GrowingNode.h"
#import "UIViewController+GrowingPageHelper.h"
#import "UIWindow+GrowingHelper.h"
#import "UIWindow+GrowingNode.h"
#import "GrowingStatusBarAutotracker.h"
#import "GrowingTimeUtil.h"

@interface GrowingMobileDebugger () <GrowingSRWebSocketDelegate,
                                GrowingEventInterceptor,
                                GrowingApplicationEventProtocol,
                                GrowingDeepLinkHandlerProtocol>

//表示web和app是否同时准备好数据发送，此时表示可以发送数据
@property (nonatomic, assign) BOOL isReady;
@property (nonatomic, strong) NSMutableArray * cacheArray;
@property (nonatomic, strong) NSMutableArray * cacheEvent;
@property (nonatomic, strong) NSTimer *timer;
@property(strong, nonatomic, readonly) NSLock *lock;
@property (nonatomic, retain) GrowingStatusBar *statusWindow;
@property (nonatomic, assign) unsigned long snapNumber;  //数据发出序列号

@end

@implementation GrowingMobileDebugger

static GrowingMobileDebugger *shareInstance = nil;

+ (instancetype)shareInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareInstance = [[GrowingMobileDebugger alloc] init];
    });
    return shareInstance;
}

- (instancetype)init
{
    if (self = [super init]) {
        _lock = [[NSLock alloc] init];
        self.cacheEvent =  [NSMutableArray arrayWithCapacity:0];
    }
    return self;
}

+ (void)stop {
    [[self shareInstance] stop];
}

+ (BOOL)isRunning {
    return [[self shareInstance] isRunning];
}

- (void)runWithMobileDebugger:(NSURL *)url{
    if (self.webSocket) {
        [self.webSocket close];
        self.webSocket.delegate = nil;
        self.webSocket = nil;
    }
    self.webSocket = [[GrowingSRWebSocket alloc] initWithURLRequest:[NSURLRequest requestWithURL:url]];
    self.webSocket.delegate = self;
    [self.webSocket open];
}
#pragma mark - GrowingDeepLinkHandlerProtocol

- (BOOL)growingHandlerUrl:(NSURL *)url {
    [[GrowingEventManager shareInstance] addInterceptor:self];
    NSDictionary *params = url.growingHelper_queryDict;
    NSString *serviceType = params[@"serviceType"];
    NSString *wsurl = params[@"wsUrl"];
    if (serviceType.length > 0 && [serviceType isEqualToString:@"debugger"] && wsurl.length > 0) {
        [self runWithMobileDebugger:[NSURL URLWithString:wsurl] ];
        return YES;
    }
    return NO;
}

#pragma mark - actions

- (void)_setNeedUpdateScreen {
    [self sendScreenShot];
}

+ (CGFloat)impressScale {
    CGFloat scale = [UIScreen mainScreen].scale;
    return MIN(scale, 2);
}

- (unsigned long)getSnapshotKey {
    @synchronized(self) {
        _snapNumber++;
    }
    return _snapNumber;
}


#pragma mark - screenShot

- (void)sendScreenShot {
    if (self.isReady) {
        UIImage *image = [self screenShot];
        NSData *data = [image growingHelper_JPEG:0.8];
        NSString *imgBase64Str = [data growingHelper_base64String];
        
        if(!data.length || !imgBase64Str.length) {
            return ;
        }
        
        
        NSDictionary *dict = @{
            @"screenWidth" : @(image.size.width * image.scale),
            @"screenHeight" : @(image.size.height * image.scale),
            @"scale" : @(1),  //暂时没有计算
            @"screenshot" : [@"data:image/jpeg;base64," stringByAppendingString:imgBase64Str],
            @"msgType" : @"refreshScreenshot",
            @"snapshotKey" : @([self getSnapshotKey]),
        };
        [self sendJson:dict];
    }
}

- (UIImage *)screenShot {
    CGFloat scale = MIN([UIScreen mainScreen].scale, 2);
    NSArray *windows = [[UIApplication sharedApplication].growingHelper_allWindowsWithoutGrowingWindow sortedArrayUsingComparator:^NSComparisonResult(UIWindow *obj1, UIWindow *obj2) {
        if (obj1.windowLevel == obj2.windowLevel) {
            return NSOrderedSame;
        }else if (obj1.windowLevel > obj2.windowLevel) {
            return NSOrderedDescending;
        }else {
            return NSOrderedAscending;
        }
    }];
    
    UIImage *image = [UIWindow growingHelper_screenshotWithWindows:windows
                                                       andMaxScale:scale
                                                             block:^(CGContextRef context) {
                                                                 
                                                             }];
    return image;
}

- (void)reissueEvent
{
    if(self.cacheEvent.count>0)
    {
        
        for(int i = 0;i<self.cacheEvent.count;++i)
        {
            [self sendJson:self.cacheEvent[i]];
        }
        [self.cacheEvent removeAllObjects];
    }
}

- (void)remoteReady {
    [self sendJson:[self userInfo]];
    [self sendScreenShot];
    [self reissueEvent];
}


- (void)start {
    self.isReady = YES;
    [self remoteReady];
    if (!self.statusWindow) {
        self.statusWindow = [[GrowingStatusBar alloc] initWithFrame:[UIScreen mainScreen].bounds];
        self.statusWindow.hidden = NO;
        self.statusWindow.statusLable.text = @"正在进行Debugger";
        self.statusWindow.statusLable.textAlignment = NSTextAlignmentCenter;
    }
    [[GrowingApplicationEventManager sharedInstance] addApplicationEventObserver:self];
}

- (void)stop {
    GIOLogDebug(@"开始断开连接");
    NSDictionary *dict = @{@"msgType" : @"quit"};
    [self sendJson:dict];
    self.statusWindow.statusLable.text = @"正在关闭Debugger";
    self.statusWindow.statusLable.textAlignment = NSTextAlignmentCenter;
    [self _stopWithError:nil];
}

- (void)_stopWithError:(NSString *)error {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
    [[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];

    [[GrowingEventManager shareInstance] removeInterceptor:self];
    [[GrowingApplicationEventManager sharedInstance] removeApplicationEventObserver:self];
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
    [GrowingWSLogger sharedInstance].loggerBlock = nil;
    [[GrowingEventManager shareInstance] removeInterceptor:self];
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

- (void)nextOne
{
   if(self.cacheArray.count > 0)
   {
       NSMutableDictionary *cacheDic = [NSMutableDictionary dictionary];
       cacheDic[@"msgType"] = @"logger_data";
       cacheDic[@"sdkVersion"] = GrowingTrackerVersionName;
       [self.lock lock];
       cacheDic[@"data"] = self.cacheArray.copy;
       [self.cacheArray removeAllObjects];
       [self.lock unlock];
       [self sendJson:cacheDic];
   }
}


- (void)startTimer
{
    if(!self.timer)
    {
        
    self.cacheArray =  [NSMutableArray arrayWithCapacity:0];
    self.timer =  [NSTimer timerWithTimeInterval:1.0 target:self selector:@selector(nextOne) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
    }
}
-(void)stopTimer
{
    if(self.timer)
    {
    [self.timer invalidate];
    self.timer = nil;
    }
}
- (void)webSocket:(GrowingSRWebSocket *)webSocket didReceiveMessage:(id)message {
    if ([message isKindOfClass:[NSString class]] || ((NSString *)message).length > 0) {
        GIOLogDebug(@"didReceiveMessage: %@", message);
        NSMutableDictionary *dict = [message growingHelper_jsonObject];

        //如果收到了ready消息，说明可以发送数据了
        if ([[dict objectForKey:@"msgType"] isEqualToString:@"ready"]) {
            [self start];
            return;
        }
        //发送log信息
        NSString *msg = dict[@"msgType"];
        if ([msg isKindOfClass:NSString.class]) {
             if ([msg isEqualToString:@"logger_open"]) {
                 
                [self startTimer];
                [GrowingWSLogger sharedInstance].loggerBlock = ^(NSArray * logMessageArray) {
                       if (logMessageArray.count > 0) {
                           [self.cacheArray addObjectsFromArray:logMessageArray];
                       }
                    
                };
             }
             else if ([msg isEqualToString:@"logger_close"]) {
                [self stopTimer];
                [GrowingWSLogger sharedInstance].loggerBlock =nil;
            }
            return;
        }
        // 版本号不适配
        if ([[dict objectForKey:@"msgType"] isEqualToString:@"incompatible_version"]) {
            GrowingAlert *alert = [GrowingAlert createAlertWithStyle:UIAlertControllerStyleAlert
                                                               title:@"抱歉"
                                                             message:@"您使用的SDK版本号过低,请升级SDK后再使用"];
            [alert addOkWithTitle:@"知道了" handler:nil];
            [alert showAlertAnimated:NO];
            [self stop];
            return;
        }

        // web端退出了调试
        if ([[dict objectForKey:@"msgType"] isEqualToString:@"quit"]) {
            self.isReady = NO;
            [self _stopWithError:@"当前设备已与Web端断开连接,如需继续调试请扫码重新连接。"];
            return;
        }
    }
}

#pragma mark 应用信息
- (NSDictionary *)userInfo {
    
    GrowingDeviceInfo *deviceInfo = [GrowingDeviceInfo currentDeviceInfo];
    NSDictionary *dict = @{
        @"msgType" : @"client_info",
        @"sdkVersion" : GrowingTrackerVersionName,
        @"data" :@{
                @"os" : @"iOS",
                @"appVersion" : deviceInfo.appFullVersion,
                @"appChannel" : @"App Store",
                @"osVersion" : deviceInfo.platformVersion,
                @"deviceType" : deviceInfo.deviceType,
                @"deviceBrand" : deviceInfo.deviceBrand,
                @"deviceModel" : deviceInfo.deviceModel
        }
        
    };
    
    return dict;
}

#pragma mark - websocket delegate

- (void)webSocketDidOpen:(GrowingSRWebSocket *)webSocket {
    GIOLogDebug(@"websocket已连接");
    CGSize screenSize = [GrowingDeviceInfo deviceScreenSize];
    NSString *projectId = GrowingConfigurationManager.sharedInstance.trackConfiguration.projectId;
    NSDictionary *dict = @{
        @"projectId" : projectId,
        @"msgType" : @"ready",
        @"timestamp" : @([GrowingTimeUtil currentTimeMillis]),
        @"domain" : [GrowingDeviceInfo currentDeviceInfo].bundleID,
        @"sdkVersion" : GrowingTrackerVersionName,
        @"sdkVersionCode" : [GrowingDeviceInfo currentDeviceInfo].appFullVersion,
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
        [self _stopWithError:@"当前设备已与Web端断开连接,如需继续调试请扫码重新连接。"];
    }
}

- (void)webSocket:(GrowingSRWebSocket *)webSocket didFailWithError:(NSError *)error {
    GIOLogDebug(@"error : %@", error);
    _isReady = NO;
    [self _stopWithError:@"服务器链接失败"];
}

- (void)webSocket:(GrowingSRWebSocket *)webSocket didReceivePong:(NSData *)pongPayload {
}


#pragma mark - GrowingApplicationEventManager

- (void)growingApplicationEventSendEvent:(UIEvent *)event {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(_setNeedUpdateScreen) object:nil];
    [self performSelector:@selector(_setNeedUpdateScreen) withObject:nil afterDelay:1];
}

//#pragma mark - GrowingEventInterceptor

- (void)growingEventManagerEventDidBuild:(GrowingBaseEvent* _Nullable)event{
    [self.lock lock];
    [self sendEventDidBuild:event];
    [self.lock unlock];
}

//获取url字段
+ (NSString *)absoluteURL {
    NSString *baseUrl = [GrowingNetworkConfig sharedInstance].growingApiHostEnd;
    if (!baseUrl.length) {
        return nil;
    }
    NSString *absoluteURLString = [baseUrl absoluteURLStringWithPath:self.path andQuery:nil ];
    return absoluteURLString;
}

+ (NSString *)path {
    NSString *accountId = [GrowingConfigurationManager sharedInstance].trackConfiguration.projectId ? : @"";
    NSString *path = [NSString stringWithFormat:@"v3/projects/%@/collect", accountId];
    return path;
}

//发送用户行为信息
- (void)sendEventDidBuild:(GrowingBaseEvent *)event {
    NSMutableDictionary *atts = [[NSMutableDictionary alloc] initWithDictionary:event.toDictionary];
    NSDictionary *dict = @{
        @"msgType" : @"debugger_data",
        @"sdkVersion" : GrowingTrackerVersionName,
        @"data" :atts
    };
    dict[@"data"][@"url"] = [[self class] absoluteURL];
    if(self.isReady)
    {
        [self sendJson:dict];
    }
    else{
        [self.cacheEvent addObject:dict.copy];
    }

}

@end

