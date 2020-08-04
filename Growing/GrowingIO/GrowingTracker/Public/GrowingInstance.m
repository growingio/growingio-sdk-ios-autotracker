//
//  GrowingInstance.m
//  GrowingTracker
//
//  Created by GrowingIO on 6/3/15.
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


#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "GrowingInstance.h"
#import "GrowingMediator.h"
#import "GrowingDeviceInfo.h"
#import "NSString+GrowingHelper.h"
#import "NSData+GrowingHelper.h"
#import "GrowingGlobal.h"
#import "GrowingCustomField.h"
#import "GrowingNetworkConfig.h"
#import "GrowingMobileDebugger.h"
#import "GrowingDeepLinkModel.h"
#import "NSDictionary+GrowingHelper.h"
#import "NSURL+GrowingHelper.h"
#import "GrowingMediator+GrowingDeepLink.h"
#import "GrowingDispatchManager.h"
#import "GrowingReengageEvent.h"
#import "GrowingActivateEvent.h"
#import "GrowingAppLifecycle.h"
#import "GrowingCocoaLumberjack.h"

static BOOL checkUUIDwithSampling(NSUUID *uuid, CGFloat sampling)
{
    // 理论上 idfv是一定有的  但是万一没有就发吧
    if (!uuid)
    {
        return YES;
    }
    
    if (sampling <= 0)
    {
        return NO;
    }
    if (sampling >= 0.9999)
    {
        return YES;
    }
    
    unsigned char md5[16];
    [[[uuid UUIDString] growingHelper_uft8Data] growingHelper_md5value:md5];
    
    unsigned long bar = 100000;
    unsigned long rightValue = (sampling + 1.0f / bar) * bar;
    unsigned long value = 1;
    for (int i = 15; i >=0 ; i --)
    {
        unsigned char n = md5[i];
        value = ((value * 256) + n ) % bar;
    }
    if (value < rightValue)
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

@interface GrowingInstance ()

@property (nonatomic, strong) WKWebView *wkWebView;
@property (nonatomic, copy) NSString *userAgent;

// 剪切板deeplink存值
@property (nonatomic, copy) NSString *link_id;
@property (nonatomic, copy) NSString *click_id;
@property (nonatomic, copy) NSString *tm_click;
@property (nonatomic, copy) NSString *cl;

@property (nonatomic, strong) GrowingAppLifecycle *appLifecycle;

@end


@implementation GrowingInstance

static GrowingInstance *instance = nil;

+ (instancetype)sharedInstance {
    return instance;
}

+ (void)startWithConfiguration:(GrowingConfiguration *)configuration {
    if (instance) {
        return;
    }
    instance = [[self alloc] initWithConfiguration:configuration];
}

- (instancetype)initWithConfiguration:(GrowingConfiguration * _Nonnull)configuration {
    if (self = [self init]) {
        
        _configuration = [configuration copy];
        _projectID = [configuration.projectId copy];
        
        [self updateSampling:[_configuration samplingRate]];
        [self.appLifecycle setupAppStateNotification];
        
        self.gpsLocation = nil;
        
        [self handleDeeplinkWithConfig:_configuration];
    }
    return self;
}

- (GrowingAppLifecycle *)appLifecycle {
    if (!_appLifecycle) {
        _appLifecycle = [[GrowingAppLifecycle alloc] init];
    }
    return _appLifecycle;
}

static BOOL isGrowingDeeplink = NO;

- (void)handleDeeplinkWithConfig:(GrowingConfiguration *)configuration {
        
    isGrowingDeeplink = [self isGrowingDeeplink:configuration.launchOptions];
   
    [self runPastedDeeplink:^{
        if ([GrowingDeviceInfo currentDeviceInfo].isNewInstall) {
            [self reportInstallSoucreWithDelayInSecond:1];
        }
    }];
}

- (BOOL)isGrowingDeeplink:(NSDictionary *)launchOptions {
    
    if (launchOptions.count == 0) { return NO; }
    NSURL *url;
    NSURL *schemeUrl = [launchOptions objectForKey:UIApplicationLaunchOptionsURLKey];
    if (schemeUrl) {
        url = schemeUrl;
    } else {
        if (@available(iOS 8.0, *)) {
            NSUserActivity *act = [[launchOptions objectForKey:UIApplicationLaunchOptionsUserActivityDictionaryKey] objectForKey:@"UIApplicationLaunchOptionsUserActivityKey"];
            url = act.webpageURL;
        }
    }
   
    if (![[GrowingMediator sharedInstance] isGrowingIOUrl:url]) {
        return NO;
    }
        
    // 是否是短链deeplink
    BOOL isShortChainUlink = [[GrowingMediator sharedInstance] isShortChainUlink:url];
    
    if (isShortChainUlink) {
        // 处理广告
        return YES;
    }
    
    if ([[GrowingMediator sharedInstance] isLongChainDeeplink:url]) {
        // 处理广告
        return YES;
    }

    return NO;
}

- (void)runPastedDeeplink:(void (^)(void))finishBlock {
    if (SDKDoNotTrack()) {
        finishBlock();
        return;
    }
    
    if (![GrowingDeviceInfo currentDeviceInfo].isNewInstall) {
        finishBlock();
        return;
    }
    
    if ([GrowingDeviceInfo currentDeviceInfo].isPastedDeeplinkCallback) {
        finishBlock();
        return;
    }
    
    if (isGrowingDeeplink) {
        finishBlock();
        return;
    }
    
    NSDate *startDate = [NSDate date];
    
    NSString *pasteString = [UIPasteboard generalPasteboard].string;

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSDictionary *callbackDict = [self convertPastedboardString:pasteString];
        
        if (callbackDict.count == 0) {
            finishBlock();
            return;
        }
        
        if (![callbackDict[@"typ"] isEqualToString:@"gads"] || ![callbackDict[@"scheme"] isEqualToString:[GrowingDeviceInfo currentDeviceInfo].urlScheme]) {
            finishBlock();
            return;
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self.link_id = callbackDict[@"link_id"];
            self.click_id = callbackDict[@"click_id"];
            self.tm_click = callbackDict[@"tm_click"];
            self.cl = @"defer";
            
            NSString *jsonStr = [self URLDecodedString:callbackDict[@"v1"][@"custom_params"]?:@""];
            NSData *data = [jsonStr dataUsingEncoding:NSUTF8StringEncoding];
            NSError *cusErr = nil;
            NSDictionary *custom_params = [NSJSONSerialization JSONObjectWithData:data options:0 error:&cusErr];
            NSMutableDictionary *dictInfo = [NSMutableDictionary dictionaryWithDictionary:custom_params];
            if ([dictInfo objectForKey:@"_gio_var"]) {
                [dictInfo removeObjectForKey:@"_gio_var"];
            }
            
            NSError *err = nil;
            if (custom_params.count == 0) {
                // 默认错误
                err = [NSError errorWithDomain:@"com.growingio.deeplink" code:1 userInfo:@{@"error" : @"no custom_params"}];
            }
            
            NSDate *endDate = [NSDate date];
            NSTimeInterval processTime = [endDate timeIntervalSinceDate:startDate];

            if (GrowingInstance.deeplinkHandler) {
                GrowingInstance.deeplinkHandler(dictInfo, processTime, err);
            }
            
            if ([[UIPasteboard generalPasteboard].string isEqualToString:pasteString]) {
                [UIPasteboard generalPasteboard].string = @"";
            }
            
            [[GrowingDeviceInfo currentDeviceInfo] pasteboardDeeplinkReported];
            finishBlock();
        });
    });
    
}


- (NSDictionary *)convertPastedboardString:(NSString *)clipboardString {
    if (clipboardString.length > 2000 * 16) {
        return nil;
    }
    
    NSString *binaryList = @"";
    
    for (int i = 0; i < clipboardString.length; i++) {
        char a = [clipboardString characterAtIndex:i];
        NSString *charString = @"";
        if (a == (char)020014) {
            charString = @"0";
        } else {
            charString = @"1";
        }
        binaryList = [binaryList stringByAppendingString:charString];
    }
    
    NSInteger binaryListLength = binaryList.length;
    
    NSInteger SINGLE_CHAR_LENGTH = 16;
    
    if (binaryListLength % SINGLE_CHAR_LENGTH != 0) {
        return nil;
    }
    
    NSMutableArray *bs = [NSMutableArray array];
    
    int i = 0;
    while (i < binaryListLength) {
        [bs addObject:[binaryList substringWithRange:NSMakeRange(i, SINGLE_CHAR_LENGTH)]];
        i += SINGLE_CHAR_LENGTH;
    }
    
    NSString *listString = @"";
    
    for (int i = 0; i < bs.count; i++) {
        NSString *partString = bs[i];
        long long part = [partString longLongValue];
        int partInt = [self convertBinaryToDecimal:part];
        listString = [listString stringByAppendingString:[NSString stringWithFormat:@"%C", (unichar)partInt]];
    }
    NSDictionary *dict = listString.growingHelper_jsonObject;
    return [dict isKindOfClass:[NSDictionary class]] ? dict : nil;
}

- (int)convertBinaryToDecimal:(long long)n {
    int decimalNumber = 0, i = 0, remainder;
    while (n != 0) {
        remainder = n%10;
        n /= 10;
        decimalNumber += remainder*pow(2,i);
        ++i;
    }
    return decimalNumber;
}

- (void)_reportInstallSoucre {
    if (SDKDoNotTrack()) {
        return;
    }

    [self loadUserAgentWithCompletion:^(NSString *ua) {
    
        NSMutableDictionary *queryDict = [NSMutableDictionary dictionary];
        
        if (self.link_id.length) { queryDict[@"link_id"] = [self encodedString:self.link_id]; }
        if (self.click_id.length) { queryDict[@"click_id"] = [self encodedString:self.click_id]; }
        if (self.tm_click.length) { queryDict[@"tm_click"] = [self encodedString:self.tm_click]; }
        if (self.cl.length) { queryDict[@"cl"] = self.cl; }
        if (ua.length) { queryDict[@"ua"] = ua; }
        
        GrowingDeeplinkInfo *info = [[GrowingDeeplinkInfo alloc] initWithQueryDict:queryDict];
        [GrowingActivateEvent sendEventWithDeeplinkInfo:info];
        [[GrowingDeviceInfo currentDeviceInfo] deviceInfoReported];
    }];
}

+ (void)reportGIODeeplink:(NSURL *)linkURL {
    [[self sharedInstance] reportGIODeeplink:linkURL];
}

+ (void)reportShortChainDeeplink:(NSURL *)linkURL
{
    [[self sharedInstance] reportShortChainDeeplink:linkURL isManual:NO callback:nil];
}

static GrowingDeeplinkHandler deeplinkHandler;
+ (void)setDeeplinkHandler:(GrowingDeeplinkHandler)handler {
    deeplinkHandler = handler;
}

+ (GrowingDeeplinkHandler)deeplinkHandler {
    return deeplinkHandler;
}

- (NSString *)URLDecode:(NSString *)source {
    if (!source || source.length == 0) {
        // 空或者空串直接返回原值
        return source;
    }
    
    NSString *resultString = [source stringByReplacingOccurrencesOfString:@"&amp;" withString:@"&"];
    resultString = [resultString stringByReplacingOccurrencesOfString:@"&apos;" withString:@"\'"];
    resultString = [resultString stringByReplacingOccurrencesOfString:@"&gt;" withString:@">"];
    resultString = [resultString stringByReplacingOccurrencesOfString:@"&lt;" withString:@"<"];
    resultString = [resultString stringByReplacingOccurrencesOfString:@"&quot;" withString:@"\""];
    
    return resultString;
}

- (NSString *)encodedString:(NSString *)urlString {
    NSString *encodedString = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                                                                    (CFStringRef)urlString,
                                                                                                    (CFStringRef)@"!$&'()*+,-./:;=?@_~%#[]",
                                                                                                    NULL,
                                                                                                    kCFStringEncodingUTF8));
    return encodedString;
}

- (NSString *)URLDecodedString:(NSString *)urlString {
    urlString = [urlString
    stringByReplacingOccurrencesOfString:@"+" withString:@" "];
    NSString *decodedString = (__bridge_transfer NSString *)CFURLCreateStringByReplacingPercentEscapesUsingEncoding(NULL,
                                                                                                                    (__bridge CFStringRef)urlString,
                                                                                                                    CFSTR(""),
                                                                                                                    CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding));
    return decodedString;
}

+ (BOOL)doDeeplinkByUrl:(NSURL *)url callback:(void(^)(NSDictionary *params, NSTimeInterval processTime, NSError *error))callback {
    BOOL isShortChainUlink = [[GrowingMediator sharedInstance] isShortChainUlink:url];
    
    if (isShortChainUlink) {
        [GrowingDispatchManager dispatchInMainThread:^{
            [[self sharedInstance] reportShortChainDeeplink:url isManual:YES callback:callback];
        }];
    }
    
    return isShortChainUlink;
}

- (void)reportGIODeeplink:(NSURL *)linkURL {
    if (SDKDoNotTrack()) {
        return;
    }
    NSString *renngageMechanism;
    
    if ([linkURL.scheme hasPrefix:@"growing."] ) {
        renngageMechanism = @"url_scheme";
    } else {
        renngageMechanism = @"universal_link";
    }
    
    [self loadUserAgentWithCompletion:^(NSString *ua) {
        
        NSMutableDictionary *queryParams = [NSMutableDictionary dictionaryWithDictionary:linkURL.growingHelper_queryDict];

        __block NSString *cstm_params = nil ;
        
        [[[self URLDecode:linkURL.query] componentsSeparatedByString:@"&"] enumerateObjectsUsingBlock:^(NSString *_Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj hasPrefix:@"custom_params"]) {
                NSArray *pair = [obj componentsSeparatedByString:@"="];
                if (pair.count > 1) {
                    cstm_params = pair[1];
                    [queryParams removeObjectForKey:@"custom_params"];
                }
            }
        }];
        
        queryParams[@"rngg_mch"] = renngageMechanism;
        queryParams[@"ua"] = ua;
        
        NSString *jsonCustomStr = [self URLDecodedString:cstm_params];
        NSDictionary *customParams = [jsonCustomStr growingHelper_dictionaryObject];
            
        GrowingDeeplinkInfo *linkInfo = [[GrowingDeeplinkInfo alloc] initWithQueryDict:queryParams];
        linkInfo.customParams = customParams;
        [GrowingReengageEvent sendEventWithDeeplinkInfo:linkInfo];
        
    }];
    
    if (!GrowingInstance.deeplinkHandler) {
        return;
    }
    
    // 处理参数回调
    NSString *encodeQuery = linkURL.query;
    NSString *query = [self URLDecode:encodeQuery];
    NSArray *items = [query componentsSeparatedByString:@"&"];
    __block NSDictionary *info = nil;
    __block NSError *err = nil;
    [items enumerateObjectsUsingBlock:^(NSString *_Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj hasPrefix:@"custom_params"]) {
            NSArray *pair = [obj componentsSeparatedByString:@"="];
            if (pair.count > 1) {
                NSString *encodeJsonStr = pair[1];
                if (encodeJsonStr.length > 0) {
                    NSString *jsonStr = [self URLDecodedString:encodeJsonStr];
                    NSData *data = [jsonStr dataUsingEncoding:NSUTF8StringEncoding];
                    info = [NSJSONSerialization JSONObjectWithData:data options:0 error:&err];
                    NSMutableDictionary *dicInfo  = [NSMutableDictionary dictionaryWithDictionary:info] ;
                    if ([dicInfo objectForKey:@"_gio_var"]) {
                        [dicInfo removeObjectForKey:@"_gio_var"];
                    }
                    if (![dicInfo objectForKey:@"+deeplink_mechanism"]) {
                        [dicInfo setObject:renngageMechanism forKey:@"+deeplink_mechanism"];
                    }
                    info = dicInfo ;
                    if (!info) {
                        GIOLogError(@"error = %@", err);
                    }
                }
            }
            *stop = YES;
        }
    }];
    
    if (!info && !err) {
        // 默认错误
        err = [NSError errorWithDomain:@"com.growingio.deeplink" code:1 userInfo:@{@"error" : @"no custom_params"}];
    }
    
    if (GrowingInstance.deeplinkHandler) {
        GrowingInstance.deeplinkHandler(info, 0.0, err);
    }
}

- (void)reportShortChainDeeplink:(NSURL *)linkURL
                        isManual:(BOOL)isManual
                        callback:(void(^)(NSDictionary *params, NSTimeInterval processTime, NSError *error))callback {
    if (SDKDoNotTrack()) {
        return;
    }
    
    NSDate *startData = [NSDate date];
    NSString *renngageMechanism = @"universal_link";
    NSString *hashId = [linkURL.path componentsSeparatedByString:@"/"].lastObject;
    
    [self loadUserAgentWithCompletion:^(NSString * ua) {
        
        GrowingDeepLinkModel *deepLinkModel = [[GrowingDeepLinkModel alloc] init];
        
        [deepLinkModel getParamByHashId:hashId query:linkURL.query
                                     ua:ua
                                 manual:isManual
                                succeed:^(NSHTTPURLResponse *httpResponse, NSData *data) {
            
            NSDictionary *responseDict = [data growingHelper_dictionaryObject];
            NSNumber *statusNumber = responseDict[@"code"];
            NSString *message = responseDict[@"msg"] ? : @"";
            
            NSDictionary *dataDict = responseDict[@"data"];
            
            if (statusNumber.intValue != 200) {
                NSError *err = [NSError errorWithDomain:@"com.growingio.deeplink" code:statusNumber.integerValue userInfo:@{@"error" : message}];
                NSDate *endTime = [NSDate date];
                NSTimeInterval processTime = [endTime timeIntervalSinceDate:startData];
                if (callback) {
                    callback(nil, processTime, err);
                } else if (GrowingInstance.deeplinkHandler) {
                    GrowingInstance.deeplinkHandler(nil, processTime, err);
                }
                return;
            }
            
            NSString *link_id = [dataDict objectForKey:@"link_id"];
            NSString *click_id = [dataDict objectForKey:@"click_id"];
            NSNumber *tm_click = [dataDict objectForKey:@"tm_click"];
            NSDictionary *custom_params = [dataDict objectForKey:@"custom_params"];
            
            if (!isManual) {
                [self reportReengageWithCustomParams:custom_params
                                                  ua:ua
                                   renngageMechanism:renngageMechanism
                                             link_id:link_id
                                            click_id:click_id
                                            tm_click:tm_click];
            }
            
            if (!GrowingInstance.deeplinkHandler && !callback) {
                return;
            }
            
            // 处理参数回调
            NSMutableDictionary *dictInfo = [NSMutableDictionary dictionaryWithDictionary:custom_params];
            if ([dictInfo objectForKey:@"_gio_var"]) {
                [dictInfo removeObjectForKey:@"_gio_var"];
            }
            if (![dictInfo objectForKey:@"+deeplink_mechanism"]) {
                [dictInfo setObject:renngageMechanism forKey:@"+deeplink_mechanism"];
            }
            
            NSError *err = nil;
            if (custom_params.count == 0) {
                // 默认错误
                err = [NSError errorWithDomain:@"com.growingio.deeplink" code:1 userInfo:@{@"error" : @"no custom_params"}];
            }
            
            NSDate *endDate = [NSDate date];
            NSTimeInterval processTime = [endDate timeIntervalSinceDate:startData];
            
            if (callback) {
                callback(dictInfo, processTime, err);
            } else if (GrowingInstance.deeplinkHandler) {
                GrowingInstance.deeplinkHandler(dictInfo, processTime, err);
            }
            
        } fail:^(NSHTTPURLResponse *httpResponse, NSData *data, NSError *error) {
            
            NSDate *endTime = [NSDate date];
            NSTimeInterval processTime = [endTime timeIntervalSinceDate:startData];
            
            if (callback) {
                callback(nil, processTime, error);
            } else if (GrowingInstance.deeplinkHandler) {
                GrowingInstance.deeplinkHandler(nil, processTime, error);
            }
        }];
        
    }];
}

- (void)reportReengageWithCustomParams:(NSDictionary *)customParams
                                    ua:(NSString *)ua
                     renngageMechanism:(NSString *)renngageMechanism
                               link_id:(NSString *)link_id
                              click_id:(NSString *)click_id
                              tm_click:(NSNumber *)tm_click {
    
    NSMutableDictionary *queryParams = [NSMutableDictionary dictionary];
    if (ua.length) { queryParams[@"ua"] = ua; }
    if (renngageMechanism.length) { queryParams[@"rngg_mch"] = renngageMechanism; }
    if (link_id.length) { queryParams[@"link_id"] = [self encodedString:link_id]; }
    if (click_id.length) { queryParams[@"click_id"] = [self encodedString:click_id]; }
    if (tm_click) { queryParams[@"tm_click"] = [self encodedString:tm_click.stringValue]; }
        
    GrowingDeeplinkInfo *linkInfo = [[GrowingDeeplinkInfo alloc] initWithQueryDict:queryParams];
    linkInfo.customParams = customParams;
    [GrowingReengageEvent sendEventWithDeeplinkInfo:linkInfo];
}

- (void)loadUserAgentWithCompletion:(void (^)(NSString *))completion {
    if (self.userAgent) {
        return completion(self.userAgent);
    }

    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        
        self.wkWebView = [[WKWebView alloc] initWithFrame:CGRectZero];
        [self.wkWebView evaluateJavaScript:@"navigator.userAgent" completionHandler:^(id _Nullable response, NSError *_Nullable error) {
            if (error || !response) {
                GIOLogError(@"WKWebView evaluateJavaScript load UA error:%@", error);
                completion(nil);
            } else {
                weakSelf.userAgent = response;
                completion(weakSelf.userAgent);
            }
            weakSelf.wkWebView = nil;
        }];
    });
}

- (void)reportInstallSoucreWithDelayInSecond:(NSInteger)delaySeconds {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delaySeconds * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self _reportInstallSoucre];
    });
}

+ (void)updateSampling:(CGFloat)sampling {
    [[self sharedInstance] updateSampling:sampling];
}

- (void)updateSampling:(CGFloat)sampling {
    NSUUID *idfv = [[UIDevice currentDevice] identifierForVendor];
    [Growing setDataCollectionEnabled:checkUUIDwithSampling(idfv, sampling)];
}

@end

