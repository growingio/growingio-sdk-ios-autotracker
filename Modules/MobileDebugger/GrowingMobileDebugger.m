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
#import <arpa/inet.h>
#import <ifaddrs.h>
#import "GrowingTrackerCore/DeepLink/GrowingDeepLinkHandler+Private.h"
#import "GrowingTrackerCore/GrowingRealTracker.h"
#import "GrowingTrackerCore/Helpers/GrowingHelpers.h"
#import "GrowingTrackerCore/Manager/GrowingConfigurationManager.h"
#import "GrowingTrackerCore/Menu/GrowingAlert.h"
#import "GrowingTrackerCore/Menu/GrowingStatusBar.h"
#import "GrowingTrackerCore/Public/GrowingAnnotationCore.h"
#import "GrowingTrackerCore/Public/GrowingScreenshotService.h"
#import "GrowingTrackerCore/Public/GrowingServiceManager.h"
#import "GrowingTrackerCore/Public/GrowingWebSocketService.h"
#import "GrowingTrackerCore/Thirdparty/Logger/GrowingLogger.h"
#import "GrowingTrackerCore/Thread/GrowingDispatchManager.h"
#import "GrowingTrackerCore/Utils/GrowingDeviceInfo.h"
#import "GrowingTrackerCore/Utils/GrowingInternalMacros.h"
#import "GrowingULApplication.h"
#import "GrowingULTimeUtil.h"
#import "Modules/MobileDebugger/GrowingDebuggerEventQueue.h"

GrowingMod(GrowingMobileDebugger)

@interface GrowingMobileDebugger () <GrowingWebSocketDelegate,
                                     GrowingApplicationEventProtocol,
                                     GrowingDeepLinkHandlerProtocol>

// 表示web和app是否同时准备好数据发送，此时表示可以发送数据
@property (nonatomic, assign) BOOL isReady;
@property (nonatomic, strong) NSMutableArray *cacheLogs;
@property (nonatomic, strong) NSMutableArray *cacheEvent;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, retain) GrowingStatusBar *statusWindow;
@property (nonatomic, assign) unsigned long snapNumber;  // 数据发出序列号
@property (nonatomic, copy) NSString *absoluteURL;

@property (nonatomic, weak) id<GrowingScreenshotService> screenshotProvider;

@end

@implementation GrowingMobileDebugger {
    GROWING_LOCK_DECLARE(lock);
}

- (void)growingModInit:(GrowingContext *)context {
    if ([GrowingULApplication isAppExtension]) {
        return;
    }
    self.screenshotProvider =
        [[GrowingServiceManager sharedInstance] createService:@protocol(GrowingScreenshotService)];
    [GrowingDebuggerEventQueue startQueue];
    [[GrowingDeepLinkHandler sharedInstance] addHandlersObject:self];
}

- (instancetype)init {
    if (self = [super init]) {
        GROWING_LOCK_INIT(lock);
        _cacheEvent = [NSMutableArray arrayWithCapacity:0];
        _cacheLogs = [NSMutableArray arrayWithCapacity:0];
    }
    return self;
}

- (void)runWithMobileDebugger:(NSURL *)url {
    Class<GrowingWebSocketService> serviceClass =
        [[GrowingServiceManager sharedInstance] serviceImplClass:@protocol(GrowingWebSocketService)];
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

- (BOOL)growingHandleURL:(NSURL *)url {
    NSDictionary *params = url.growingHelper_queryDict;
    NSString *serviceType = params[@"serviceType"];
    NSString *wsurl = params[@"wsUrl"];
    if (serviceType.length > 0 && [serviceType isEqualToString:@"debugger"] && wsurl.length > 0) {
        [self runWithMobileDebugger:[NSURL URLWithString:wsurl]];
        return YES;
    }
    return NO;
}

#pragma mark - actions

- (void)_setNeedUpdateScreen {
    [self sendScreenshot];
}

- (unsigned long)getSnapshotKey {
    // running in main thread
    _snapNumber++;
    return _snapNumber;
}

#pragma mark - Screenshot

- (void)sendScreenshot {
    if (self.isReady) {
        UIImage *image = [self.screenshotProvider screenshot];
        NSData *data = [image growingHelper_JPEG:0.8];
        NSString *imgBase64Str = [data growingHelper_base64String];

        if (!data.length || !imgBase64Str.length) {
            return;
        }

        NSDictionary *dict = @{
            @"screenWidth": @(image.size.width * image.scale),
            @"screenHeight": @(image.size.height * image.scale),
            @"scale": @(1),  // 暂时没有计算
            @"screenshot": [@"data:image/jpeg;base64," stringByAppendingString:imgBase64Str],
            @"msgType": @"refreshScreenshot",
            @"snapshotKey": @([self getSnapshotKey]),
        };
        [self sendJson:dict];
    }
}

- (void)remoteReady {
    [self sendJson:[self userInfo]];
    [self sendScreenshot];
}

- (void)start {
    self.isReady = YES;
    [self remoteReady];
    if (!self.statusWindow) {
        self.statusWindow = [[GrowingStatusBar alloc] initWithFrame:[UIScreen mainScreen].bounds];
        self.statusWindow.hidden = NO;
        self.statusWindow.statusLabel.text = @"正在进行Debugger";
        self.statusWindow.statusLabel.textAlignment = NSTextAlignmentCenter;

        __weak typeof(self) wself = self;
        self.statusWindow.onButtonClick = ^{
            NSString *content = [NSString stringWithFormat:@"APP版本: %@\nSDK版本: %@",
                                                           [GrowingDeviceInfo currentDeviceInfo].appFullVersion,
                                                           GrowingTrackerVersionName];
            GrowingAlert *alert = [GrowingAlert createAlertWithStyle:UIAlertControllerStyleAlert
                                                               title:@"正在进行Debugger"
                                                             message:content];
            [alert addOkWithTitle:@"继续Debugger" handler:nil];
            [alert addCancelWithTitle:@"退出Debugger"
                              handler:^(UIAlertAction *_Nonnull action, NSArray<UITextField *> *_Nonnull textFields) {
                                  [wself stop];
                              }];
            [alert showAlertAnimated:NO];
        };
    }
    [self.screenshotProvider addApplicationEventObserver:self];
    [self startTimer];
}

- (void)stop {
    GIOLogDebug(@"开始断开连接");
    NSDictionary *dict = @{@"msgType": @"quit"};
    [self sendJson:dict];
    self.statusWindow.statusLabel.text = @"正在关闭Debugger";
    self.statusWindow.statusLabel.textAlignment = NSTextAlignmentCenter;
    [self _stopWithError:nil];
}

- (void)dealloc {
    [self stop];
}

- (void)_stopWithError:(NSString *)error {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
    [[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];

    [self.screenshotProvider removeApplicationEventObserver:self];
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
    [self stopTimer];
}

- (BOOL)isRunning {
    return self.isReady;
}

- (void)sendJson:(id)json {
    if (self.webSocket.readyState == Growing_WS_OPEN &&
        ([json isKindOfClass:[NSDictionary class]] || [json isKindOfClass:[NSArray class]])) {
        NSString *jsonString = [json growingHelper_jsonString];
        [self.webSocket send:jsonString];
    }
}

- (void)nextOne {
    if (self.cacheLogs.count > 0) {
        NSMutableDictionary *cacheDic = [NSMutableDictionary dictionary];
        cacheDic[@"msgType"] = @"logger_data";
        cacheDic[@"sdkVersion"] = GrowingTrackerVersionName;
        GROWING_LOCK(lock);
        cacheDic[@"data"] = self.cacheLogs.copy;
        [self.cacheLogs removeAllObjects];
        GROWING_UNLOCK(lock);
        [self sendJson:cacheDic];
    }

    if (self.cacheEvent.count > 0) {
        // 防止遍历的时候进行增删改查
        GROWING_LOCK(lock);
        NSArray *events = self.cacheEvent.copy;
        [self.cacheEvent removeAllObjects];
        GROWING_UNLOCK(lock);
        for (int i = 0; i < events.count; i++) {
            NSDictionary *attrs = events[i];
            if ([attrs isKindOfClass:[NSDictionary class]]) {
                NSMutableDictionary *cacheDic = [NSMutableDictionary dictionary];
                cacheDic[@"msgType"] = @"debugger_data";
                cacheDic[@"sdkVersion"] = GrowingTrackerVersionName;
                cacheDic[@"data"] = attrs;
                [self sendJson:cacheDic];
            }
        }
    }
}

- (void)startTimer {
    if (!self.timer) {
        self.timer = [NSTimer timerWithTimeInterval:1.0
                                             target:self
                                           selector:@selector(nextOne)
                                           userInfo:nil
                                            repeats:YES];
        [[NSRunLoop mainRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
    }
}

- (void)stopTimer {
    if (self.timer) {
        [self.timer invalidate];
        self.timer = nil;
    }
}

- (void)webSocket:(id<GrowingWebSocketService>)webSocket didReceiveMessage:(id)message {
    if ([message isKindOfClass:[NSString class]] && ((NSString *)message).length > 0) {
        GIOLogDebug(@"didReceiveMessage: %@", message);
        NSMutableDictionary *dict = [message growingHelper_jsonObject];

        if ([[dict objectForKey:@"msgType"] isEqualToString:@"ready"]) {
            // 如果收到了ready消息，说明可以发送数据了
            [self start];
            __weak typeof(self) weakSelf = self;
            [GrowingDebuggerEventQueue currentQueue].debuggerBlock = ^(NSArray *_Nonnull events) {
                __strong typeof(weakSelf) self = weakSelf;
                if (events.count > 0) {
                    GROWING_LOCK(self->lock);
                    [self.cacheEvent addObjectsFromArray:events];
                    GROWING_UNLOCK(self->lock);
                }
            };
            [[GrowingDebuggerEventQueue currentQueue] dequeue];
        } else if ([[dict objectForKey:@"msgType"] isEqualToString:@"logger_open"]) {
            // 发送log信息
            __weak typeof(self) weakSelf = self;
            [GrowingWSLogger sharedInstance].loggerBlock = ^(NSArray *logMessageArray) {
                __strong typeof(weakSelf) self = weakSelf;
                if (logMessageArray.count > 0) {
                    GROWING_LOCK(self->lock);
                    [self.cacheLogs addObjectsFromArray:logMessageArray];
                    GROWING_UNLOCK(self->lock);
                }
            };
        } else if ([[dict objectForKey:@"msgType"] isEqualToString:@"logger_close"]) {
            // 停止发送log信息
            [GrowingWSLogger sharedInstance].loggerBlock = nil;
        } else if ([[dict objectForKey:@"msgType"] isEqualToString:@"incompatible_version"]) {
            // 版本号不适配
            GrowingAlert *alert = [GrowingAlert createAlertWithStyle:UIAlertControllerStyleAlert
                                                               title:@"抱歉"
                                                             message:@"您使用的SDK版本号过低,请升级SDK后再使用"];
            [alert addOkWithTitle:@"知道了" handler:nil];
            [alert showAlertAnimated:NO];
            [self stop];
        } else if ([[dict objectForKey:@"msgType"] isEqualToString:@"quit"]) {
            // web端退出了调试
            self.isReady = NO;
            [self _stopWithError:@"当前设备已与Web端断开连接,如需继续调试请扫码重新连接。"];
        }
    }
}

#pragma mark 应用信息
- (NSDictionary *)userInfo {
    GrowingDeviceInfo *deviceInfo = [GrowingDeviceInfo currentDeviceInfo];
    NSDictionary *dict = @{
        @"msgType": @"client_info",
        @"sdkVersion": GrowingTrackerVersionName,
        @"data": @{
            @"os": @"iOS",
            @"appVersion": deviceInfo.appFullVersion,
            @"appChannel": @"App Store",
            @"osVersion": deviceInfo.platformVersion,
            @"deviceType": deviceInfo.deviceType,
            @"deviceBrand": deviceInfo.deviceBrand,
            @"deviceModel": deviceInfo.deviceModel
        }

    };

    return dict;
}

#pragma mark - websocket delegate

- (void)webSocketDidOpen:(id<GrowingWebSocketService>)webSocket {
    GIOLogDebug(@"websocket已连接");
    NSString *accountId = GrowingConfigurationManager.sharedInstance.trackConfiguration.accountId;
    NSDictionary *dict = @{
        @"projectId": accountId,
        @"msgType": @"ready",
        @"timestamp": @([GrowingULTimeUtil currentTimeMillis]),
        @"domain": [GrowingDeviceInfo currentDeviceInfo].bundleID,
        @"sdkVersion": GrowingTrackerVersionName,
        @"sdkVersionCode": [GrowingDeviceInfo currentDeviceInfo].appFullVersion,
        @"os": @"iOS",
        @"screenWidth": [NSNumber numberWithInteger:[GrowingDeviceInfo currentDeviceInfo].screenWidth],
        @"screenHeight": [NSNumber numberWithInteger:[GrowingDeviceInfo currentDeviceInfo].screenHeight],
        @"urlScheme": [GrowingDeviceInfo currentDeviceInfo].urlScheme
    };
    [self sendJson:dict];

    [self.screenshotProvider addSendEventSwizzle];
}

- (void)webSocket:(id<GrowingWebSocketService>)webSocket
    didCloseWithCode:(NSInteger)code
              reason:(NSString *)reason
            wasClean:(BOOL)wasClean {
    GIOLogDebug(@"已断开链接");
    _isReady = NO;
    if (code != GrowingWebSocketStatusCodeNormal) {
        [self _stopWithError:@"当前设备已与Web端断开连接,如需继续调试请扫码重新连接。"];
    }
}

- (void)webSocket:(id<GrowingWebSocketService>)webSocket didFailWithError:(NSError *)error {
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
