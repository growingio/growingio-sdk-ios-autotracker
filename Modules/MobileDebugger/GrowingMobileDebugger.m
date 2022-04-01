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

#import "Modules/MobileDebugger/GrowingMobileDebugger.h"
#import <UIKit/UIKit.h>
#import <arpa/inet.h>
#import <ifaddrs.h>
#import "GrowingTrackerCore/Menu/GrowingAlert.h"
#import "GrowingTrackerCore/Manager/GrowingApplicationEventManager.h"
#import "GrowingTrackerCore/GrowingAttributesConst.h"
#import "GrowingTrackerCore/Thirdparty/Logger/GrowingLogger.h"
#import "GrowingTrackerCore/Manager/GrowingConfigurationManager.h"
#import "GrowingTrackerCore/DeepLink/GrowingDeepLinkHandler.h"
#import "GrowingTrackerCore/Utils/GrowingDeviceInfo.h"
#import "GrowingTrackerCore/Thread/GrowingDispatchManager.h"
#import "GrowingTrackerCore/Network/Request/GrowingNetworkConfig.h"
#import "GrowingTrackerCore/Menu/GrowingStatusBar.h"
#import "GrowingTrackerCore/Helpers/NSArray+GrowingHelper.h"
#import "GrowingTrackerCore/Helpers/NSData+GrowingHelper.h"
#import "GrowingTrackerCore/Helpers/NSDictionary+GrowingHelper.h"
#import "GrowingTrackerCore/Helpers/NSString+GrowingHelper.h"
#import "GrowingTrackerCore/Helpers/NSURL+GrowingHelper.h"
#import "GrowingTrackerCore/Helpers/UIApplication+GrowingHelper.h"
#import "GrowingTrackerCore/Helpers/UIImage+GrowingHelper.h"
#import "GrowingTrackerCore/Helpers/UIWindow+GrowingHelper.h"
#import "GrowingTrackerCore/Utils/GrowingTimeUtil.h"
#import "Modules/MobileDebugger/GrowingDebuggerEventQueue.h"
#import "GrowingTrackerCore/Network/Request/GrowingNetworkConfig.h"
#import "GrowingTrackerCore/GrowingRealTracker.h"
#import "GrowingTrackerCore/Public/GrowingAnnotationCore.h"
#import "Modules/MobileDebugger/GrowingDebuggerEventQueue.h"
#import "GrowingTrackerCore/Public/GrowingServiceManager.h"
#import "GrowingTrackerCore/Public/GrowingWebSocketService.h"

#define LOCK(...) dispatch_semaphore_wait(self->_lock, DISPATCH_TIME_FOREVER); \
__VA_ARGS__; \
dispatch_semaphore_signal(self->_lock);

GrowingMod(GrowingMobileDebugger)

@interface GrowingMobileDebugger () <GrowingWebSocketDelegate,
                                GrowingApplicationEventProtocol,
                                GrowingDeepLinkHandlerProtocol>

//表示web和app是否同时准备好数据发送，此时表示可以发送数据
@property (nonatomic, assign) BOOL isReady;
@property (nonatomic, strong) NSMutableArray * cacheArray;
@property (nonatomic, strong) NSMutableArray * cacheEvent;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, retain) GrowingStatusBar *statusWindow;
@property (nonatomic, assign) unsigned long snapNumber;  //数据发出序列号
@property (nonatomic, copy) NSString *absoluteURL;

@end

@implementation GrowingMobileDebugger {
    dispatch_semaphore_t _lock;
}

//static GrowingMobileDebugger *sharedInstance = nil;

- (void)growingModInit:(GrowingContext *)context {
    [GrowingDebuggerEventQueue startQueue];
    [[GrowingDeepLinkHandler sharedInstance] addHandlersObject:self];
}

- (instancetype)init {
    if (self = [super init]) {
        _lock = dispatch_semaphore_create(1);
        _cacheEvent =  [NSMutableArray arrayWithCapacity:0];
    }
    return self;
}

//获取url字段
- (NSString *)absoluteURL {
    if (!_absoluteURL) {
        _absoluteURL = [GrowingNetworkConfig absoluteURL];
    }
    return _absoluteURL;
}

- (void)runWithMobileDebugger:(NSURL *)url {
    Class <GrowingWebSocketService> serviceClass = [[GrowingServiceManager sharedInstance] serviceImplClass:@protocol(GrowingWebSocketService)];
    if (!serviceClass) {
        GIOLogError(@"-runWithMobileDebugger: mobile debugger error : no websocket service support");
        return;
    }
    
    if (self.webSocket) {
        self.webSocket.delegate = nil;
        [self.webSocket close];
        self.webSocket = nil;
    }
    if (url) {
        self.webSocket = [[(Class)serviceClass alloc] initWithURLRequest:[NSURLRequest requestWithURL:url]];
        self.webSocket.delegate = self;
        [self.webSocket open];
    }
}

#pragma mark - GrowingDeepLinkHandlerProtocol

- (BOOL)growingHandlerUrl:(NSURL *)url {
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

- (void)remoteReady {
    [self sendJson:[self userInfo]];
    [self sendScreenShot];
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

- (void)dealloc {
    [self stop];
}


- (void)_stopWithError:(NSString *)error {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
    [[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];

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
}

- (BOOL)isRunning {
    return self.isReady;
}

- (void)sendJson:(id)json {
    NSLog(@"sendJson : %@", json);
    if (self.webSocket.readyState == Growing_WS_OPEN &&
        ([json isKindOfClass:[NSDictionary class]] || [json isKindOfClass:[NSArray class]])) {
        NSString *jsonString = [json growingHelper_jsonString];
        [self.webSocket send:jsonString];
    }
}

- (void)nextOne {
    if (self.cacheArray.count > 0) {
        NSMutableDictionary *cacheDic = [NSMutableDictionary dictionary];
        cacheDic[@"msgType"] = @"logger_data";
        cacheDic[@"sdkVersion"] = GrowingTrackerVersionName;
        LOCK(cacheDic[@"data"] = self.cacheArray.copy;
        [self.cacheArray removeAllObjects]);
        [self sendJson:cacheDic];
    }
    
    if (self.cacheEvent.count > 0) {
        //防止遍历的时候进行增删改查
        LOCK(NSArray *events = self.cacheEvent.copy;
             [self.cacheEvent removeAllObjects];);
        for (int i = 0; i < events.count; i++) {
            NSMutableDictionary *attrs = [[NSMutableDictionary alloc] initWithDictionary:events[i]];
            NSMutableDictionary *cacheDic = [NSMutableDictionary dictionary];
            cacheDic[@"msgType"] = @"debugger_data";
            cacheDic[@"sdkVersion"] = GrowingTrackerVersionName;
            cacheDic[@"data"] = attrs;
            cacheDic[@"data"][@"url"] = self.absoluteURL;
            [self sendJson:cacheDic];
        }
    }
}


- (void)startTimer {
    if (!self.timer) {
        self.cacheArray = [NSMutableArray arrayWithCapacity:0];
        self.timer =  [NSTimer timerWithTimeInterval:1.0 target:self selector:@selector(nextOne) userInfo:nil repeats:YES];
        [[NSRunLoop mainRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
    }
}

- (void)stopTimer {
    if (self.timer) {
        [self.timer invalidate];
        self.timer = nil;
    }
}

- (void)webSocket:(id <GrowingWebSocketService>)webSocket didReceiveMessage:(id)message {
    if ([message isKindOfClass:[NSString class]] || ((NSString *)message).length > 0) {
        GIOLogDebug(@"didReceiveMessage: %@", message);
        NSMutableDictionary *dict = [message growingHelper_jsonObject];

        //如果收到了ready消息，说明可以发送数据了
        if ([[dict objectForKey:@"msgType"] isEqualToString:@"ready"]) {
            [self start];
            [self startTimer];
            [GrowingDebuggerEventQueue currentQueue].debuggerBlock = ^(NSArray * _Nonnull events) {
                if (events.count > 0) {
                    LOCK([self.cacheEvent addObjectsFromArray:events]);
                }
            };
            //队列出队
            [[GrowingDebuggerEventQueue currentQueue] dequeue];
            return;
        }
        //发送log信息
        NSString *msg = dict[@"msgType"];
        if ([msg isKindOfClass:NSString.class]) {
             if ([msg isEqualToString:@"logger_open"]) {
                [self startTimer];
                [GrowingWSLogger sharedInstance].loggerBlock = ^(NSArray * logMessageArray) {
                       if (logMessageArray.count > 0) {
                           LOCK([self.cacheArray addObjectsFromArray:logMessageArray]);
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

- (void)webSocketDidOpen:(id <GrowingWebSocketService>)webSocket {
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

- (void)webSocket:(id <GrowingWebSocketService>)webSocket
    didCloseWithCode:(NSInteger)code
              reason:(NSString *)reason
            wasClean:(BOOL)wasClean {
    GIOLogDebug(@"已断开链接");
    _isReady = NO;
    if (code != GrowingWebSocketStatusCodeNormal) {
        [self _stopWithError:@"当前设备已与Web端断开连接,如需继续调试请扫码重新连接。"];
    }
}

- (void)webSocket:(id <GrowingWebSocketService>)webSocket didFailWithError:(NSError *)error {
    GIOLogDebug(@"error : %@", error);
    _isReady = NO;
    [self _stopWithError:@"服务器链接失败"];
}

#pragma mark - GrowingApplicationEventManager

- (void)growingApplicationEventSendEvent:(UIEvent *)event {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(_setNeedUpdateScreen) object:nil];
    [self performSelector:@selector(_setNeedUpdateScreen) withObject:nil afterDelay:1];
}

@end

