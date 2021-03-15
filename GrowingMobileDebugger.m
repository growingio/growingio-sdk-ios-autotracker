//
//  GrowingMobileDebugger.m
//  Growing
//
//  Created by GIO on 2017/9/19.
//  Copyright © 2017年 GrowingIO. All rights reserved.
//
#import "GrowingMobileDebugger.h"
#import "Growing3rdLibSRWebSocket.h"
#import "GrowingEventManager.h"
#import "GrowingStatusBar.h"
//#import "GrowingInstance.h"
#import "GrowingAlert.h"
#import "NSDictionary+GrowingHelper.h"
#import "UIWindow+GrowingHelper.h"
#import "UIApplication+GrowingHelper.h"
#import "GrowingDeviceInfo.h"//
#import "UIImage+GrowingHelper.h"
#import "NSData+GrowingHelper.h"
//#import "GrowingCustomField.h"
#import "GrowingNetworkConfig.h"//
#import "NSURL+GrowingHelper.h"
//#import "GrowingEBApplicationEvent.h"

@interface GrowingMobileDebugger() <Growing3rdLibSRWebSocketDelegate, GrowingEventInterceptor/*GrowingEventManagerObserver, CLLocationManagerDelegate*/>

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

//subscribe
//+ (void)didfinishLauching:(GrowingEBApplicationEvent *)event
//{
//    if (event.lifeType != GrowingApplicationDidFinishLaunching) {
//        return;
//    }
//
//    if (event.dataDict.count == 0) {
//        return;
//    }
//
//    BOOL fromMobileDebugger = [self isMobileDebuggerLaunching:event.dataDict[@"data"]];
//
//    if (fromMobileDebugger) {
//        [[GrowingMobileDebugger shareDebugger] performSelector:@selector(cacheEventStart)];
//    }
//}

+ (BOOL)isMobileDebuggerLaunching:(NSDictionary *)launchOptions
{
    if ([launchOptions objectForKey:UIApplicationLaunchOptionsSourceApplicationKey]) {
        //  必须是growingIO 的 debugger
        NSURL *url = [launchOptions objectForKey:UIApplicationLaunchOptionsURLKey];
        if(!url)
        {
            return NO;
        }
        // 检查是否是GrowingIO的业务URL
        if (![url.scheme hasPrefix:@"growing."] && !([url.absoluteString rangeOfString:@"growingio.com"].location != NSNotFound || [url.absoluteString rangeOfString:@"gio.ren"].location != NSNotFound))
        {
            return NO;
        }
        
        // 分发
        if (![[url host] isEqualToString:@"growing"] && !([url.absoluteString rangeOfString:@"growingio.com"].location != NSNotFound || [url.absoluteString rangeOfString:@"gio.ren"].location != NSNotFound))
        {
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
//                GrowingMenuButton *btn_1 = [GrowingMenuButton buttonWithTitle:@"取消" block:nil];
//                GrowingMenuButton *btn_2 = [GrowingMenuButton buttonWithTitle:@"退出" block:^{
//                                                                            __strong __typeof__(weakSelf) strongSelf = weakSelf;
//                                                                            [strongSelf stop];
//                                                                        }];
//                [GrowingAlertMenu alertWithTitle:@"Debug模式" text:@"是否退出" buttons:@[btn_1, btn_2]];
            };
        }
        NSString *endPoint = @"";
        if (dataCheck){
             endPoint = [GrowingNetworkConfig.sharedInstance dataCheckEndPoint];
        }else{
             endPoint = [GrowingNetworkConfig.sharedInstance wsEndPoint];
        }
        NSString *urlStr = [NSString stringWithFormat:endPoint, [GrowingInstance sharedInstance].accountID, roomNumber];
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
    [[GrowingEventManager shareInstance] removeObserver:self ];
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
//        [GrowingAlertMenu alertWithTitle:@"Debug结束"
//                                    text:error
//                                 buttons:@[[GrowingMenuButton buttonWithTitle:@"OK" block:nil]]];
        GrowingAlert *alert = [GrowingAlert createAlertWithStyle:UIAlertControllerStyleAlert
                                                           title:@"Debug结束"
                                                         message:error];
        [alert addOkWithTitle:@"OK"
                      handler:^(UIAlertAction * _Nonnull action, NSArray<UITextField *> * _Nonnull textFields) {
            NSLog(@"aciton = %@, textFields = %@", action, textFields);
        }];
        
        [alert showAlertAnimated:YES];
        
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
    GIOLogError(@"error : %@", error);//GROWLog(@"error : %@", error);
    [self _stopWithError:@"服务器链接失败"];
}

- (void)webSocket:(Growing3rdLibSRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean {
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
//////////////////////
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
    }
}

- (BOOL)growingEventManagerShouldAddEvent:(GrowingEvent *)event thisNode:(id<GrowingNode>)thisNode triggerNode:(id<GrowingNode>)triggerNode withContext:(id<GrowingAddEventContext>)context {
    
    if ([event.dataDict[@"t"] isEqualToString:@"imp"]) {
        return NO;
    }
    
    return YES;
}

#pragma mark debugger信息
- (NSMutableDictionary *)userInfo {
    
    GrowingDeviceInfo *deviceInfo = [GrowingDeviceInfo currentDeviceInfo];
    
    NSMutableDictionary *info = [[NSMutableDictionary alloc] initWithCapacity:7];
    
    //SDK版本、访问用户ID(deviceID／u)、登录用户ID（cs1）
    NSString *uesrId        = [GrowingCustomField shareInstance].cs1;
    NSString *loginId       = deviceInfo.deviceIDString;//u
    NSString *sdkVersion    = deviceInfo.appVersion//[Growing sdkVersion];
    
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
            }else {
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
    NSMutableDictionary *eventInfo = event.dataDict;
    if (eventInfo == nil || eventInfo.count == 0) {
        return;
    }
    [eventInfo setValue:@"server_action" forKey:@"msgId"];
    
    //生成uri
    unsigned long long stm = GROWGetTimestamp().unsignedLongLongValue;
    NSString *urlTemplate = nil;
    if([eventInfo[@"t"] isEqualToString:@"imp"]){
        urlTemplate = kGrowingEventApiTemplate_Imp;
    }else if([eventInfo[@"t"] isEqualToString:@"vst"]
             ||[eventInfo[@"t"] isEqualToString:@"page"]){
        urlTemplate = kGrowingEventApiTemplate_PV;
    }else if([eventInfo[@"t"] isEqualToString:@"cstm"]
             ||[eventInfo[@"t"] isEqualToString:@"pvar"]
             ||[eventInfo[@"t"] isEqualToString:@"evar"]
             ||[eventInfo[@"t"] isEqualToString:@"ppl"]
             ||[eventInfo[@"t"] isEqualToString:@"vstr"]){
        urlTemplate = kGrowingEventApiTemplate_Custom;
    }else {
        urlTemplate = kGrowingEventApiTemplate_Other;
    }
    NSString *url = kGrowingEventApiV3(urlTemplate, [GrowingInstance sharedInstance].accountID, stm);
    [eventInfo setValue:url forKey:@"uri"];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self sendJson:eventInfo];
    });
}

@end
