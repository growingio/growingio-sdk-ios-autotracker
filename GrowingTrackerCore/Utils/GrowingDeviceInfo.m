//
//  GrowingDeviceInfo.m
//  GrowingAnalytics
//
//  Created by GrowingIO on 15/11/19.
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

#import "GrowingTrackerCore/Utils/GrowingDeviceInfo.h"

#import <CoreTelephony/CTCarrier.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <pthread.h>
#import <sys/utsname.h>

#import "GrowingAppLifecycle.h"
#import "GrowingTrackerCore/Thirdparty/Logger/GrowingLogger.h"
#import "GrowingTrackerCore/Thread/GrowingDispatchManager.h"
#import "GrowingTrackerCore/Utils/GrowingKeyChainWrapper.h"
#import "GrowingTrackerCore/Utils/UserIdentifier/GrowingUserIdentifier.h"
#import "GrowingTrackerCore/Helpers/NSString+GrowingHelper.h"

#define LOCK(...)                                                \
    dispatch_semaphore_wait(self->_lock, DISPATCH_TIME_FOREVER); \
    __VA_ARGS__;                                                 \
    dispatch_semaphore_signal(self->_lock);

static NSString *kGrowingUrlScheme = nil;
NSString *const kGrowingKeychainUserIdKey = @"kGrowingIOKeychainUserIdKey";

@interface GrowingDeviceInfo () <GrowingAppLifecycleDelegate>
@property (nonatomic, copy) NSString *deviceOrientation;
@end

@implementation GrowingDeviceInfo {
    dispatch_semaphore_t _lock;
}

@synthesize deviceIDString = _deviceIDString;
@synthesize idfv = _idfv;
@synthesize idfa = _idfa;


- (NSString *)getCurrentUrlScheme {
    NSArray *urlSchemeGroup = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleURLTypes"];

    for (NSDictionary *dic in urlSchemeGroup) {
        NSArray *shemes = [dic objectForKey:@"CFBundleURLSchemes"];
        for (NSString *urlScheme in shemes) {
            if ([urlScheme isKindOfClass:[NSString class]] && [urlScheme hasPrefix:@"growing."]) {
                return urlScheme;
            }
        }
    }
    return nil;
}

- (NSString *)deviceIDString {
    LOCK(if (!_deviceIDString) _deviceIDString = [self getDeviceIdString];)
    return _deviceIDString;
}

- (BOOL)isNewInstall {
    return ![self isSentDeviceInfoBefore];
}

- (BOOL)isPastedDeeplinkCallback {
    return [self isPasteboardDeeplinkCallBack];
}

- (instancetype)init {
    if (self = [super init]) {
        NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];

        _deviceStorage = [[GrowingFileStorage alloc] initWithName:@"config"];
        _lock = dispatch_semaphore_create(1);
        _bundleID = infoDictionary[@"CFBundleIdentifier"];

        // @property (nonatomic, readonly) NSString *displayName;
        _displayName = infoDictionary[@"CFBundleDisplayName"] ?: infoDictionary[@"CFBundleName"];
        if (!_displayName) {
            _displayName = @"";
        }

        // @property (nonatomic, readonly) NSString *language;
        _language = [NSLocale preferredLanguages].firstObject ?: @"";

        // @property (nonatomic, readonly) NSString *deviceModel;
        struct utsname systemInfo;
        uname(&systemInfo);
        _deviceModel = @(systemInfo.machine);

        //@property (nonatomic, readonly) NSString *deviceBrand;
        _deviceBrand = @"Apple";

        // @property (nonatomic, readonly) NSString *deviceType;
        _deviceType = [UIDevice currentDevice].model;

        //@property (nonatomic, readonly) NSNumber *isPhone;
        _isPhone = [[_deviceType lowercaseString] rangeOfString:@"ipad"].length ? @0 : @1;

        // @property (nonatomic, readonly) NSString *systemName;
        _platform = @"iOS";  // [[UIDevice currentDevice] systemName];

        // @property (nonatomic, readonly) NSString *systemVersion;
        _platformVersion = [[UIDevice currentDevice] systemVersion];

        // @property (nonatomic, readonly) NSString *appFullVersion;
        _appFullVersion = infoDictionary[@"CFBundleVersion"];
        if (!_appFullVersion) {
            _appFullVersion = @"";
        }

        // @property (nonatomic, readonly) NSString *appShortVersion;
        _appVersion = infoDictionary[@"CFBundleShortVersionString"];

        // @property (nonatomic, readonly) NSString *urlScheme;
        NSString *urlScheme = kGrowingUrlScheme;
        _urlScheme = urlScheme ?: [self getCurrentUrlScheme];

        NSMutableDictionary *customDict = [[NSMutableDictionary alloc] init];
        [infoDictionary enumerateKeysAndObjectsUsingBlock:^(NSString *key, id obj, BOOL *_Nonnull stop) {
            if ([key isKindOfClass:[NSString class]]) {
                [customDict setValue:obj forKey:key.lowercaseString];
            }
        }];

        [[GrowingAppLifecycle sharedInstance] addAppLifecycleDelegate:self];

        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(handleStatusBarOrientationChange:)
                                                     name:UIApplicationDidChangeStatusBarOrientationNotification
                                                   object:nil];
    }
    return self;
}

- (NSString *)idfv {
    if (!_idfv) {
        _idfv = [GrowingUserIdentifier idfv];
    }
    return _idfv;
}

- (NSString *)idfa {
    if (!_idfa) {
        // 必须每次获取idfa，以防idfa变动
        _idfa = [GrowingUserIdentifier idfa];
    }
    return _idfa;
}

- (NSString *)getDeviceIdString {
    NSString *deviceIdString = [GrowingKeyChainWrapper keyChainObjectForKey:kGrowingKeychainUserIdKey];
    // 如果取到有效u值，直接返回
    if ([deviceIdString growingHelper_isValidU]) {
        return deviceIdString;
    }

    NSString *uuid = [GrowingUserIdentifier getUserIdentifier];
    // 保存
    [GrowingKeyChainWrapper setKeychainObject:uuid forKey:kGrowingKeychainUserIdKey];

    return uuid;
}

- (BOOL)isSentDeviceInfoBefore {
    NSString *isSentDeviceInfoStateString = [self.deviceStorage stringForKey:@"isSentDeviceInfoBefore"];
    return isSentDeviceInfoStateString != nil;
}

- (BOOL)isPasteboardDeeplinkCallBack {
    NSString *isPasteboardDeeplinkCallBack = [self.deviceStorage stringForKey:@"isPasteboardDeeplinkCallBack"];
    return isPasteboardDeeplinkCallBack.length > 0;
}

- (void)deviceInfoReported {
    [GrowingDispatchManager dispatchInLowThread:^{
        [self.deviceStorage setString:@"hasSent" forKey:@"isSentDeviceInfoBefore"];
    }];
}

- (void)pasteboardDeeplinkReported {
    [GrowingDispatchManager dispatchInLowThread:^{
        [self.deviceStorage setString:@"yes" forKey:@"isPasteboardDeeplinkCallBack"];
    }];
}

+ (instancetype)currentDeviceInfo {
    static GrowingDeviceInfo *info = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        info = [[GrowingDeviceInfo alloc] init];
    });
    return info;
}

- (NSString *)carrier {
    CTTelephonyNetworkInfo *netinfo = [[CTTelephonyNetworkInfo alloc] init];
    CTCarrier *carrier = [netinfo subscriberCellularProvider];
    if (carrier) {
        return [NSString stringWithFormat:@"%@-%@", carrier.mobileCountryCode, carrier.mobileNetworkCode];
    } else {
        return @"unknown";
    }
}


+ (void)configUrlScheme:(NSString *)urlScheme {
    kGrowingUrlScheme = urlScheme;
}

+ (CGSize)deviceScreenSize {
    CGSize size = [UIScreen mainScreen].bounds.size;
    CGFloat scale = [UIScreen mainScreen].scale;

    if (size.height < size.width) {
        // make sure the size is in portrait to keep consistency
        CGFloat temp = size.width;
        size.width = size.height;
        size.height = temp;
    }

    size.width *= scale;
    size.height *= scale;

    //    size.width += 0.5f;
    //    size.height += 0.5f;

    return size;
}

#pragma mark - status bar

- (NSString *)deviceOrientation {
    if (!_deviceOrientation) {
        dispatch_block_t block = ^{
            UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
            if (orientation != UIInterfaceOrientationUnknown) {
                LOCK(self->_deviceOrientation =
                         UIInterfaceOrientationIsPortrait(orientation) ? @"PORTRAIT" : @"LANDSCAPE";)
            }
        };
        if ([NSThread isMainThread]) {
            block();
        } else {
            dispatch_sync(dispatch_get_main_queue(), ^{
                block();
            });
        }
    }
    return _deviceOrientation;
}

- (void)handleStatusBarOrientationChange:(NSNotification *)notification {
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    if (orientation != UIInterfaceOrientationUnknown) {
        LOCK(_deviceOrientation = UIInterfaceOrientationIsPortrait(orientation) ? @"PORTRAIT" : @"LANDSCAPE";)
    }
}

#pragma mark - appLifeCycle

- (void)applicationDidBecomeActive {
    [self updateAppState];
}

- (void)applicationWillResignActive {
    [self updateAppState];
}

- (void)updateAppState {
    dispatch_block_t block = ^{
        self->_appState = [UIApplication sharedApplication].applicationState == UIApplicationStateActive ? 0 : 1;
    };
    
    if (@available(iOS 13.0, *)) {
        // iOS 13当收到UISceneWillDeactivateNotification/UISceneDidActivateNotification时，applicationState并未转换
        NSDictionary *sceneManifestDict = [[NSBundle mainBundle] infoDictionary][@"UIApplicationSceneManifest"];
        if (sceneManifestDict) {
            dispatch_async(dispatch_get_main_queue(), ^{
                block();
            });
            return;
        }
    }
    
    if ([NSThread isMainThread]) {
        block();
    } else {
        dispatch_sync(dispatch_get_main_queue(), ^{
            block();
        });
    }
}

@end
