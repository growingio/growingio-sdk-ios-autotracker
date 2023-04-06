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

#if __has_include(<UIKit/UIKit.h>)
#import <UIKit/UIKit.h>
#endif

#if __has_include(<AppKit/AppKit.h>)
#import <AppKit/AppKit.h>
#endif

#import <CoreTelephony/CTCarrier.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <pthread.h>
#import <sys/utsname.h>
#include <sys/sysctl.h>

#import "GrowingTrackerCore/Thirdparty/Logger/GrowingLogger.h"
#import "GrowingTrackerCore/Thread/GrowingDispatchManager.h"
#import "GrowingTrackerCore/Utils/GrowingKeyChainWrapper.h"
#import "GrowingTrackerCore/Utils/UserIdentifier/GrowingUserIdentifier.h"
#import "GrowingTrackerCore/Helpers/GrowingHelpers.h"
#import "GrowingULAppLifecycle.h"

#define LOCK(...)                                                \
    dispatch_semaphore_wait(self->_lock, DISPATCH_TIME_FOREVER); \
    __VA_ARGS__;                                                 \
    dispatch_semaphore_signal(self->_lock);

static NSString *kGrowingUrlScheme = nil;
NSString *const kGrowingKeychainUserIdKey = @"kGrowingIOKeychainUserIdKey";

@interface GrowingDeviceInfo () <GrowingULAppLifecycleDelegate> {
    dispatch_semaphore_t _lock;
}

@property (nonatomic, readwrite, copy) NSDictionary *infoDictionary;
@property (nonatomic, readwrite, copy) NSString *deviceIDString;
@property (nonatomic, readwrite, copy) NSString *bundleID;
@property (nonatomic, readwrite, copy) NSString *displayName;
@property (nonatomic, readwrite, copy) NSString *language;
@property (nonatomic, readwrite, copy) NSString *deviceModel;
@property (nonatomic, readwrite, copy) NSString *deviceBrand;
@property (nonatomic, readwrite, copy) NSString *deviceType;
@property (nonatomic, readwrite, copy) NSString *platform;
@property (nonatomic, readwrite, copy) NSString *platformVersion;
@property (nonatomic, readwrite, copy) NSString *appFullVersion;
@property (nonatomic, readwrite, copy) NSString *appVersion;
@property (nonatomic, readwrite, copy) NSString *urlScheme;
@property (nonatomic, readwrite, copy) NSString *deviceOrientation;
@property (nonatomic, readwrite, copy) NSString *idfv;
@property (nonatomic, readwrite, copy) NSString *idfa;
@property (nonatomic, readwrite, assign) int appState;
@property (nonatomic, readwrite, assign) CGFloat screenWidth;
@property (nonatomic, readwrite, assign) CGFloat screenHeight;

@end

@implementation GrowingDeviceInfo

#pragma mark - Initialize

- (instancetype)init {
    if (self = [super init]) {
        _lock = dispatch_semaphore_create(1);
        _infoDictionary = [[NSBundle mainBundle] infoDictionary];
        _deviceBrand = @"Apple";
        _appState = 0;
        
        [[GrowingULAppLifecycle sharedInstance] addAppLifecycleDelegate:self];
        
#if TARGET_OS_IOS && !TARGET_OS_MACCATALYST
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(handleStatusBarOrientationChange:)
                                                     name:UIApplicationDidChangeStatusBarOrientationNotification
                                                   object:nil];
#endif
    }
    return self;
}

#pragma mark - Public Methods

+ (instancetype)currentDeviceInfo {
    static GrowingDeviceInfo *info = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        info = [[GrowingDeviceInfo alloc] init];
    });
    return info;
}

+ (void)configUrlScheme:(NSString *)urlScheme {
    kGrowingUrlScheme = urlScheme;
}

#pragma mark - Private Methods

- (NSString *)getCurrentUrlScheme {
    for (NSDictionary *dic in _infoDictionary[@"CFBundleURLTypes"]) {
        NSArray *shemes = dic[@"CFBundleURLSchemes"];
        for (NSString *urlScheme in shemes) {
            if ([urlScheme isKindOfClass:[NSString class]] && [urlScheme hasPrefix:@"growing."]) {
                return urlScheme;
            }
        }
    }
    return nil;
}

- (NSString *)getDeviceIdString {
#if TARGET_OS_IOS && !TARGET_OS_MACCATALYST
    NSString *deviceIdString = [GrowingKeyChainWrapper keyChainObjectForKey:kGrowingKeychainUserIdKey];
    if ([deviceIdString growingHelper_isValidU]) {
        return deviceIdString;
    }
#endif

    NSString *uuid = [GrowingUserIdentifier getUserIdentifier];
#if TARGET_OS_IOS && !TARGET_OS_MACCATALYST
    [GrowingKeyChainWrapper setKeychainObject:uuid forKey:kGrowingKeychainUserIdKey];
#endif
    return uuid;
}

+ (NSString *)getSysInfoByName:(char *)typeSpeifier {
    size_t size;
    sysctlbyname(typeSpeifier, NULL, &size, NULL, 0);
    char *answer = (char *)malloc(size);
    sysctlbyname(typeSpeifier, answer, &size, NULL, 0);
    NSString *results = [NSString stringWithCString:answer encoding:NSUTF8StringEncoding];
    if (results == nil) {
        results = @"";
    }
    free(answer);
    return results;
}

#if TARGET_OS_IOS && !TARGET_OS_MACCATALYST
- (void)handleStatusBarOrientationChange:(NSNotification *)notification {
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    if (orientation != UIInterfaceOrientationUnknown) {
        LOCK(_deviceOrientation = UIInterfaceOrientationIsPortrait(orientation) ? @"PORTRAIT" : @"LANDSCAPE";)
    }
}
#endif

- (void)updateAppState {
    dispatch_block_t block = ^{
#if TARGET_OS_OSX
        self->_appState = [NSApplication sharedApplication].isActive ? 0 : 1;
#else
        self->_appState = [UIApplication sharedApplication].applicationState == UIApplicationStateActive ? 0 : 1;
#endif
    };
    
#if !TARGET_OS_OSX
    if (@available(iOS 13.0, *)) {
        // iOS 13当收到UISceneWillDeactivateNotification/UISceneDidActivateNotification时，applicationState并未转换
        NSDictionary *sceneManifestDict = _infoDictionary[@"UIApplicationSceneManifest"];
        if (sceneManifestDict) {
            dispatch_async(dispatch_get_main_queue(), ^{
                block();
            });
            return;
        }
    }
#endif
    
    if ([NSThread isMainThread]) {
        block();
    } else {
        dispatch_sync(dispatch_get_main_queue(), ^{
            block();
        });
    }
}

#pragma mark - GrowingULAppLifecycleDelegate

- (void)applicationDidBecomeActive {
    [self updateAppState];
}

- (void)applicationWillResignActive {
    [self updateAppState];
}

#pragma mark - Getter & Setter

- (NSString *)deviceIDString {
    LOCK(
         if (!_deviceIDString) _deviceIDString = [self getDeviceIdString];
    )
    return _deviceIDString;
}

- (NSString *)bundleID {
    if (!_bundleID) {
        _bundleID = _infoDictionary[@"CFBundleIdentifier"];
    }
    return _bundleID;
}

- (NSString *)displayName {
    if (!_displayName) {
        _displayName = _infoDictionary[@"CFBundleDisplayName"] ?: (_infoDictionary[@"CFBundleName"] ?: @"");
    }
    return _displayName;
}

- (NSString *)language {
    if (!_language) {
        _language = [NSLocale preferredLanguages].firstObject ?: @"";
    }
    return _language;
}

- (NSString *)deviceModel {
    if (!_deviceModel) {
#if TARGET_OS_OSX || TARGET_OS_MACCATALYST
        _deviceModel = [GrowingDeviceInfo getSysInfoByName:(char *)"hw.model"];
#else
        struct utsname systemInfo;
        uname(&systemInfo);
        _deviceModel = @(systemInfo.machine);
#endif
    }
    return _deviceModel;
}

- (NSString *)deviceType {
    if (!_deviceType) {
#if TARGET_OS_OSX || TARGET_OS_MACCATALYST
        _deviceType = @"Mac";
#elif TARGET_OS_IOS
        _deviceType = [UIDevice currentDevice].model;
#endif
    }
    return _deviceType;
}

- (NSString *)platform {
    if (!_platform) {
#if TARGET_OS_OSX
        _platform = @"macOS";
#elif TARGET_OS_MACCATALYST
        _platform = @"MacCatalyst";
#elif TARGET_OS_IOS
        _platform = @"iOS";
#endif
    }
    return _platform;
}

- (NSString *)platformVersion {
    if (!_platformVersion) {
#if !TARGET_OS_OSX
        _platformVersion = [UIDevice currentDevice].systemVersion;
#else
        NSDictionary *dic = [NSDictionary dictionaryWithContentsOfFile:@"/System/Library/CoreServices/SystemVersion.plist"];
        _platformVersion = dic[@"ProductVersion"];
#endif
    }
    return _platformVersion;
}

- (NSString *)appFullVersion {
    if (!_appFullVersion) {
        _appFullVersion = _infoDictionary[@"CFBundleVersion"] ?: @"";
    }
    return _appFullVersion;
}

- (NSString *)appVersion {
    if (!_appVersion) {
        _appVersion = _infoDictionary[@"CFBundleShortVersionString"];
    }
    return _appVersion;
}

- (NSString *)urlScheme {
    if (!_urlScheme) {
        _urlScheme = kGrowingUrlScheme ?: [self getCurrentUrlScheme];
    }
    return _urlScheme;
}

- (NSString *)deviceOrientation {
    if (!_deviceOrientation) {
#if TARGET_OS_OSX || TARGET_OS_MACCATALYST
        _deviceOrientation = @"PORTRAIT";
#elif TARGET_OS_IOS
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
#endif
    }
    return _deviceOrientation;
}

- (NSString *)idfv {
    if (!_idfv) {
        _idfv = [GrowingUserIdentifier idfv];
    }
    return _idfv;
}

- (NSString *)idfa {
    if (!_idfa) {
        _idfa = [GrowingUserIdentifier idfa];
    }
    return _idfa;
}

- (CGFloat)screenWidth {
    if (!_screenWidth) {
#if !TARGET_OS_OSX
        UIScreen *screen = [UIScreen mainScreen];
        CGFloat width = screen.bounds.size.width * screen.scale;
        CGFloat height = screen.bounds.size.height * screen.scale;
        // make sure the size is in portrait to keep consistency
        _screenWidth = MIN(width, height);
#else
        _screenWidth = NSScreen.mainScreen.frame.size.width;
#endif
    }
    return _screenWidth;
}

- (CGFloat)screenHeight {
    if (!_screenHeight) {
#if !TARGET_OS_OSX
        UIScreen *screen = [UIScreen mainScreen];
        CGFloat width = screen.bounds.size.width * screen.scale;
        CGFloat height = screen.bounds.size.height * screen.scale;
        // make sure the size is in portrait to keep consistency
        _screenHeight = MAX(width, height);
#else
        _screenHeight = NSScreen.mainScreen.frame.size.height;
#endif
    }
    return _screenHeight;
}

@end
