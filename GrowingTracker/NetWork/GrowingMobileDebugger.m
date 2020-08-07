//
//  GrowingMobileDebugger.m
//  GrowingTracker
//
//  Created by GrowingIO on 2017/9/19.
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
#import "Growing3rdLibSRWebSocket.h"
#import "GrowingEventManager.h"
#import "GrowingStatusBar.h"
#import "GrowingInstance.h"
#import "GrowingAlertMenu.h"
#import "NSDictionary+GrowingHelper.h"
#import "UIWindow+GrowingHelper.h"
#import "UIApplication+GrowingHelper.h"
#import "GrowingDeviceInfo.h"
#import "UIImage+GrowingHelper.h"
#import "NSData+GrowingHelper.h"
#import "GrowingCustomField.h"
#import "GrowingNetworkConfig.h"
#import "NSURL+GrowingHelper.h"
#import "GrowingCocoaLumberjack.h"
#import "GrowingBroadcaster.h"

@GrowingBroadcasterRegister(GrowingApplicationMessage, GrowingMobileDebugger)
@interface GrowingMobileDebugger() <Growing3rdLibSRWebSocketDelegate, GrowingEventManagerObserver, CLLocationManagerDelegate, GrowingApplicationMessage>

@property (nonatomic, retain) NSTimer                   *keepAliveTimer;
@property (nonatomic, retain) Growing3rdLibSRWebSocket  *webSocket;
@property (nonatomic, retain) GrowingStatusBar          *statusWindow;
@property (nonatomic, strong) NSMutableArray            *cachedEvents;
@property (nonatomic, assign) BOOL                       cachedStatus;

//用户设置的页面信息
//页面级变量、应用级变量、转化变量或其它的值
@property(nonatomic, strong)NSMutableDictionary<NSString *, NSMutableDictionary *> *actionVar;

@end


@implementation GrowingMobileDebugger

static GrowingMobileDebugger *debugger = nil;

+ (instancetype)shareDebugger {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        debugger = [[GrowingMobileDebugger alloc] init];
    });
    return debugger;
}

//防止不小心利用alloc/init方式创建实例
+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        debugger = [super allocWithZone:zone];
        debugger.cachedEvents = [[NSMutableArray alloc] init];
    });
    return debugger;
}

#pragma mark - GrowingApplicationMessage

+ (void)applicationStateDidChangedWithUserInfo:(NSDictionary *)userInfo lifecycle:(GrowingApplicationLifecycle)lifecycle {
    
    if (lifecycle != GrowingApplicationDidFinishLaunching) { return; }
    
    if (userInfo.count == 0) { return; }
    
    BOOL fromMobileDebugger = [[GrowingMobileDebugger shareDebugger] isMobileDebuggerLaunching:userInfo];
    
    if (fromMobileDebugger) {
        [[GrowingMobileDebugger shareDebugger] performSelector:@selector(cacheEventStart)];
    }
}

- (BOOL)isMobileDebuggerLaunching:(NSDictionary *)launchOptions {
    if ([launchOptions objectForKey:UIApplicationLaunchOptionsSourceApplicationKey]) {
        //  必须是growingIO 的 debugger
        NSURL *url = [launchOptions objectForKey:UIApplicationLaunchOptionsURLKey];
        if(!url) {
            return NO;
        }
        // 检查是否是GrowingIO的业务URL
        if (![url.scheme hasPrefix:@"growing."] &&
            !([url.absoluteString rangeOfString:@"growingio.com"].location != NSNotFound ||
              [url.absoluteString rangeOfString:@"gio.ren"].location != NSNotFound)) {
            return NO;
        }
        
        // 分发
        if (![[url host] isEqualToString:@"growing"] &&
            !([url.absoluteString rangeOfString:@"growingio.com"].location != NSNotFound ||
              [url.absoluteString rangeOfString:@"gio.ren"].location != NSNotFound)) {
            return NO;
        }
        
        NSDictionary *params = url.growingHelper_queryDict;
        
        if (params[@"link_id"]) {
            return NO;
        }
        
        if (![[url path] isEqualToString:@"/oauth2/token"]) {
            return NO;
        }
        
        if ([params.allKeys containsObject:@"gtouchType"]) {
            return NO;
        }
        
        NSString *circleTypes = params[@"circleType"];
        NSString *dataCheckRoomNumber = params[@"dataCheckRoomNumber"];
        NSString *loginToken = [params[@"loginToken"] stringByRemovingPercentEncoding];
        if ((!circleTypes.length || !loginToken.length) && !dataCheckRoomNumber)
        {
            return NO;
        }
        
        NSMutableDictionary *circleTypeDict = nil;
        circleTypeDict = [[NSMutableDictionary alloc] init];
        NSArray *arr = [circleTypes componentsSeparatedByString:@","];
        for (NSString* type in arr)
        {
            [circleTypeDict setValue:@YES forKey:type];
        }
        
        if(circleTypeDict[@"debugger"] || dataCheckRoomNumber) {
            return YES;
        }
    }
    return NO;
}

- (void)cacheEventStart
{
    self.cachedStatus = YES;
    [[GrowingEventManager shareInstance] addObserver:self];
}

- (void)debugWithRoomNumber:(NSString *)roomNumber dataCheck:(BOOL)dataCheck {
    //扫二维码进入debug模式
    
    if (!self.webSocket) {
        [self cacheEventStart];

        [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
        if (!self.statusWindow) {
            self.statusWindow = [[GrowingStatusBar alloc] initWithFrame:[UIScreen mainScreen].bounds];
            self.statusWindow.hidden = NO;
            __weak __typeof__(self) weakSelf = self;
            self.statusWindow.onButtonClick = ^{
                GrowingMenuButton *btn_1 = [GrowingMenuButton buttonWithTitle:@"取消" block:nil];
                GrowingMenuButton *btn_2 = [GrowingMenuButton buttonWithTitle:@"退出" block:^{
                                                                            __strong __typeof__(weakSelf) strongSelf = weakSelf;
                                                                            [strongSelf stop];
                                                                        }];
                [GrowingAlertMenu alertWithTitle:@"Debug模式" text:@"是否退出" buttons:@[btn_1, btn_2]];
            };
        }
        NSString *endPoint = @"";
        if (dataCheck){
             endPoint = [GrowingNetworkConfig.sharedInstance dataCheckEndPoint];
        }else{
             endPoint = [GrowingNetworkConfig.sharedInstance wsEndPoint];
        }
        NSString *urlStr = [NSString stringWithFormat:endPoint, [GrowingInstance sharedInstance].projectID, roomNumber];
        self.webSocket = [[Growing3rdLibSRWebSocket alloc] initWithURLRequest: [NSURLRequest requestWithURL: [NSURL URLWithString:urlStr]]];
        self.webSocket.delegate = self;
        [self.webSocket open];
    }
}

+ (BOOL)isStart {
    if (debugger && [debugger.statusWindow.statusLable.text isEqualToString:@"Debug进行中..."]) {
        return YES;
    }
    return NO;
}

#pragma mark - websocket生命周期
- (void)stop {
    NSDictionary *dict = @{@"msgId": @"client_quit"};
    [self sendJson:dict];
    self.statusWindow.statusLable.text = @"正在关闭Debugger...";
    self.statusWindow.statusLable.textAlignment = NSTextAlignmentCenter ;
    [self _stopWithError:nil];
}

- (void)keepAlive {
    NSDictionary *dict = @{@"msgId":@"heartbeat"};
    [self sendJson:dict];
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

- (void)_stopWithError:(NSString*)error {
    self.cachedStatus = NO;
    [self.cachedEvents removeAllObjects];
    
    [[GrowingEventManager shareInstance] removeObserver:self];
    [self endKeepAlive];
    if (self.webSocket) {
        self.webSocket.delegate = nil;
        [self.webSocket close];
        self.webSocket = nil;
    }
    if (self.statusWindow) {
        self.statusWindow.hidden = YES;
        self.statusWindow = nil;
    }
    if (error.length) {
        [GrowingAlertMenu alertWithTitle:@"Debug结束"
                                    text:error
                                 buttons:@[[GrowingMenuButton buttonWithTitle:@"OK" block:nil]]];
    }
}

#pragma mark - 更新屏幕截图
+ (void)updateScreenshot {
    if (debugger.webSocket) {
        [NSObject cancelPreviousPerformRequestsWithTarget:debugger selector:@selector(sendScreenShot) object:nil];
        [debugger performSelector:@selector(sendScreenShot) withObject:nil afterDelay:1];
    }
}

- (void)sendScreenShot {
    UIImage *image = [self screenShot];
    NSData *data = [image growingHelper_JPEG:0.8];
    NSString *imgBase64Str = [data growingHelper_base64String];
    
    if(!data.length || !imgBase64Str.length) {
        return ;
    }
    
    NSDictionary *dict = @{@"msgId"             :@"screen_update",
                           @"screenshot"        :[@"data:image/jpeg;base64," stringByAppendingString:imgBase64Str],
                           @"screenshotWidth"   :@(image.size.width * image.scale),
                           @"screenshotHeight"  :@(image.size.height * image.scale)
                           };
    
    [self sendJson:dict];
}

- (UIImage *)screenShot {
    CGFloat scale = MIN([UIScreen mainScreen].scale, 2);
    NSArray *windows = [[UIApplication sharedApplication].growingHelper_allWindowsWithoutGrowingWindow
                        sortedArrayUsingComparator:^NSComparisonResult(UIWindow *obj1, UIWindow *obj2) {
        if (obj1.windowLevel == obj2.windowLevel) {
            return NSOrderedSame;
        }
        
        if (obj1.windowLevel > obj2.windowLevel) {
            return NSOrderedDescending;
        }
        return NSOrderedAscending;
    }];
    
    UIImage *image = [UIWindow growingHelper_screenshotWithWindows:windows
                                                       andMaxScale:scale
                                                             block:^(CGContextRef context) {
        
    }];
    return image;
}

#pragma mark - Growing3rdLibSRWebSocketDelegate delegate
- (void)webSocketDidOpen:(Growing3rdLibSRWebSocket *)webSocket {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary] ;
    dict[@"msgId"] = @"client_init" ;
    dict[@"tm"] = GROWGetTimestamp();
    [self sendJson:dict];
    [self beginKeepAlive];
}

- (void)webSocket:(Growing3rdLibSRWebSocket *)webSocket didReceiveMessage:(id)message {
    if ([[message growingHelper_jsonObject] isKindOfClass:[NSDictionary class]]) {
        [self sendJson:[self userInfo]];//发送用户行为信息
        [self sendScreenShot];
        //补发已缓存的事件
        self.cachedStatus = NO;
        if(self.cachedEvents.count != 0) {
            //读取数据前，设置不再缓存数据，防止数据发生错误
            for (GrowingEvent *event in _cachedEvents) {
                [self sendEventInfo:event];
            }
            [self.cachedEvents removeAllObjects];
        }
        
        self.statusWindow.statusLable.text = @"Debug进行中...";
        self.statusWindow.statusLable.textAlignment = NSTextAlignmentCenter ;
    }
}

- (void)webSocket:(Growing3rdLibSRWebSocket *)webSocket didFailWithError:(NSError *)error {
    GIOLogDebug(@"error : %@", error);
    [self _stopWithError:@"服务器链接失败"];
}

- (void)webSocket:(Growing3rdLibSRWebSocket *)webSocket
 didCloseWithCode:(NSInteger)code
           reason:(NSString *)reason
         wasClean:(BOOL)wasClean {
    
    NSString *message = nil;
    if (code != 1000) {
        message = @"已从服务器断开链接";
    }
    [self _stopWithError:message];
}

- (void)webSocket:(Growing3rdLibSRWebSocket *)webSocket didReceivePong:(NSData *)pongPayload {
    
}

- (void)sendJson:(id)json {
    if (self.webSocket.readyState == Growing3rdLib_SR_OPEN && ([json isKindOfClass:[NSDictionary class]] || [json isKindOfClass:[NSArray class]])) {
        NSString *jsonString = [json growingHelper_jsonString];
        [self.webSocket send:jsonString];
    }
}

#pragma mark - GrowingEventManagerObserver
- (void)growingEventManagerWillAddEvent:(GrowingEvent * _Nullable)event
                               thisNode:(id<GrowingNode> _Nullable)thisNode
                            triggerNode:(id<GrowingNode> _Nullable)triggerNode
                            withContext:(id<GrowingAddEventContext> _Nullable)context {
    //开始缓存事件
    if(self.cachedStatus) {
        [self.cachedEvents addObject:event];
    } else {
        [self sendEventInfo:event];
        
        // update screenshot when new event come
        [GrowingMobileDebugger updateScreenshot];
    }
}

- (BOOL)growingEventManagerShouldAddEvent:(GrowingEvent *)event
                                 thisNode:(id<GrowingNode>)thisNode
                              triggerNode:(id<GrowingNode>)triggerNode
                              withContext:(id<GrowingAddEventContext>)context {
    return YES;
}

#pragma mark debugger信息
- (NSMutableDictionary *)userInfo {
    
    GrowingDeviceInfo *deviceInfo = [GrowingDeviceInfo currentDeviceInfo];
    
    NSMutableDictionary *info = [[NSMutableDictionary alloc] initWithCapacity:7];
    
    //SDK版本、访问用户ID(deviceID／u)、登录用户ID（cs1）
    NSString *uesrId        = [GrowingCustomField shareInstance].userId;
    NSString *loginId       = deviceInfo.deviceIDString;//u
    NSString *sdkVersion    = [Growing getTrackVersion];
    
    [info setObject:@"client_info" forKey:@"msgId"];
    [info setObject:(uesrId? uesrId:@"") forKey:@"cs1"];
    [info setObject:(loginId? loginId:@"") forKey:@"u"];
    [info setObject:sdkVersion forKey:@"sdkVersion"];
    
    //地域信息
    //国家代码(CN)、国家名称(中国)、地区名称(北京)、城市名称(北京)
    NSString *countryCode = [[NSLocale currentLocale] objectForKey: NSLocaleCountryCode]?:@"";
    NSString *countryName = [[NSLocale currentLocale] displayNameForKey:NSLocaleCountryCode value:countryCode]?:@"";
    
    [info setObject:@{@"countryCode": countryCode,
                      @"country": countryName,
                      @"region": @"",
                      @"city": @""
                      } forKey:@"locate"];
    
    //设备信息
    //APP版本、APP渠道、屏幕大小、操作系统、操作系统版本、设备类型、设备型号、app版本
    CGRect screenRect = [UIScreen mainScreen].bounds;
    NSString    *w    = [NSString stringWithFormat:@"%f", screenRect.size.width];
    NSString    *h    = [NSString stringWithFormat:@"%f", screenRect.size.height];
    //生成uri
    NSNumber* stm = GROWGetTimestamp();
    [info setObject:@{@"deviceBrand": deviceInfo.deviceBrand,
                      @"appChannel" : @"App Store",
                      @"screenSize" : @{@"w":w, @"h":h},
                      @"os"         : deviceInfo.systemName,
                      @"osVersion"  : deviceInfo.systemVersion,
                      @"deviceType" : deviceInfo.deviceType,
                      @"deviceModel": deviceInfo.deviceModel,
                      @"appVersion" : deviceInfo.appFullVersion,
                      @"stm" : stm
                      } forKey:@"device"];
    
    //来自用户设置的信息
    if (self.actionVar.count != 0 ) {
        NSMutableDictionary *pvarDic = [[NSMutableDictionary alloc] init];
        for (NSString *key in self.actionVar.allKeys) {
            if([key isEqualToString:@"evar"] || [key isEqualToString:@"ppl"]) {
                [info setObject:self.actionVar[key] forKey:key];
            } else {
                [pvarDic setObject:self.actionVar[key] forKey:key];
                [info setObject:pvarDic forKey:@"pvar"];
            }
        }
    }
    return info;
}

- (void)cacheValue:(NSDictionary<NSString *, NSObject *> *)varDic ofType:(NSString *)type {
    if (!self.actionVar) {
        self.actionVar = [[NSMutableDictionary alloc] init];
    }
    __block BOOL isStored = NO;
    //判断是否存储过该页面变量
    [self.actionVar enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, NSMutableDictionary * _Nonnull obj, BOOL * _Nonnull stop) {
        if([key isEqualToString:type]){
            isStored = YES;
            *stop = YES;
        }
    }];
    
    if (!isStored) {
        [self.actionVar setValue:[varDic mutableCopy] forKey:type];
    }else{
        //添加过，则更新既有数据
        NSMutableDictionary *new = [self mergeDic:self.actionVar[type] and:varDic];
        [self.actionVar setValue:new forKey:type];
    }
}

- (NSMutableDictionary *)mergeDic:(NSDictionary *)dic and:(NSDictionary *)varDic {
    NSMutableDictionary *mergeDic = [NSMutableDictionary dictionaryWithDictionary:dic];
    [mergeDic addEntriesFromDictionary:varDic];
    return mergeDic;
}

- (void)sendEventInfo:(GrowingEvent * _Nullable)event {
    
    NSMutableDictionary *eventInfo = [NSMutableDictionary dictionaryWithDictionary:event.toDictionary];
    
    if (eventInfo == nil || eventInfo.count == 0) {
        return;
    }
    
    [eventInfo setValue:@"server_action" forKey:@"msgId"];
    
    //生成uri
    unsigned long long stm = GROWGetTimestamp().unsignedLongLongValue;
    NSString *urlTemplate = nil;
    NSString *eventType = event.eventTypeKey;
    
    if ([eventType isEqualToString:kEventTypeKeyVisit] || [eventType isEqualToString:kEventTypeKeyPage]){
        urlTemplate = kGrowingEventApiTemplate_PV;
        
    } else if([eventType isEqualToString:kEventTypeKeyCustom]
              || [eventType isEqualToString:kEventTypeKeyPageVariable]
              || [eventType isEqualToString:kEventTypeKeyConversionVariable]
              || [eventType isEqualToString:kEventTypeKeyPeopleVariable]
              || [eventType isEqualToString:kEventTypeKeyVisitor]) {
        urlTemplate = kGrowingEventApiTemplate_Custom;
        
    } else {
        urlTemplate = kGrowingEventApiTemplate_Other;
    }
    
    NSString *url = kGrowingEventApiV3(urlTemplate, [GrowingInstance sharedInstance].projectID, stm);
    
    if ([eventType isEqualToString:kEventTypeKeyReengage] ||
        [eventType isEqualToString:kEventTypeKeyActivate]) {
        
        urlTemplate = kGrowingEventApiTemplate_Activate;
        url = kGrowingReportApi(urlTemplate, [GrowingInstance sharedInstance].projectID, stm);
    }
    
    [eventInfo setValue:url forKey:@"uri"];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self sendJson:eventInfo];
    });
}

@end
