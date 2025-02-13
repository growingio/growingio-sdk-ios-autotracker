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
#import "GrowingTargetConditionals.h"

#import <pthread.h>
#import <sys/sysctl.h>
#import <sys/utsname.h>

#import "GrowingTrackerCore/Helpers/GrowingHelpers.h"
#import "GrowingTrackerCore/Manager/GrowingConfigurationManager.h"
#import "GrowingTrackerCore/Thirdparty/Logger/GrowingLogger.h"
#import "GrowingTrackerCore/Thread/GrowingDispatchManager.h"
#import "GrowingTrackerCore/Utils/GrowingInternalMacros.h"
#import "GrowingTrackerCore/Utils/GrowingKeyChainWrapper.h"
#import "GrowingTrackerCore/Utils/UserIdentifier/GrowingUserIdentifier.h"
#import "GrowingULAppLifecycle.h"
#import "GrowingULApplication.h"

NSString *const kGrowingKeychainUserIdKey = @"kGrowingIOKeychainUserIdKey";

@interface GrowingDeviceInfo () <GrowingULAppLifecycleDelegate>

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
@property (nonatomic, readwrite, assign) NSInteger timezoneOffset;
@property (nonatomic, readwrite, assign) BOOL isNewDevice;

@end

@implementation GrowingDeviceInfo {
    GROWING_LOCK_DECLARE(lock);
}

#pragma mark - Initialize

- (instancetype)init {
    if (self = [super init]) {
        GROWING_LOCK_INIT(lock);
        _infoDictionary = [[NSBundle mainBundle] infoDictionary];
        _deviceBrand = @"Apple";
        _appState = 0;
        _timezoneOffset = -([[NSTimeZone defaultTimeZone] secondsFromGMT] / 60);
        _isNewDevice = NO;

#if Growing_USE_APPKIT
        _screenWidth = NSScreen.mainScreen.frame.size.width;
        _screenHeight = NSScreen.mainScreen.frame.size.height;
#elif Growing_OS_IOS || Growing_OS_MACCATALYST || Growing_OS_TV
        UIScreen *screen = [UIScreen mainScreen];
        CGFloat width = screen.bounds.size.width * screen.scale;
        CGFloat height = screen.bounds.size.height * screen.scale;
        // make sure the size is in portrait to keep consistency
        _screenWidth = MIN(width, height);
        _screenHeight = MAX(width, height);
#elif Growing_USE_WATCHKIT
        _screenWidth = WKInterfaceDevice.currentDevice.screenBounds.size.width;
        _screenHeight = WKInterfaceDevice.currentDevice.screenBounds.size.height;
#else
        _screenWidth = 1;
        _screenHeight = 1;
#endif
        NSString *urlScheme = GrowingConfigurationManager.sharedInstance.trackConfiguration.urlScheme;
        _urlScheme = urlScheme.length > 0 ? urlScheme.copy : [self getCurrentUrlScheme];

        _deviceOrientation = @"PORTRAIT";
#if Growing_OS_PURE_IOS
        UIInterfaceOrientation orientation = [[GrowingULApplication sharedApplication] statusBarOrientation];
        if (orientation != UIInterfaceOrientationUnknown) {
            _deviceOrientation = UIInterfaceOrientationIsPortrait(orientation) ? @"PORTRAIT" : @"LANDSCAPE";
        }

        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(handleStatusBarOrientationChange:)
                                                     name:UIApplicationDidChangeStatusBarOrientationNotification
                                                   object:nil];
#endif
    }
    return self;
}

#pragma mark - Public Methods

+ (void)setup {
    // 初始化urlScheme、appState、deviceOrientation等等（需要保证在主线程执行）
    GrowingDeviceInfo *deviceInfo = [GrowingDeviceInfo currentDeviceInfo];
    [[GrowingULAppLifecycle sharedInstance] addAppLifecycleDelegate:deviceInfo];
}

+ (instancetype)currentDeviceInfo {
    static GrowingDeviceInfo *info = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        info = [[GrowingDeviceInfo alloc] init];
    });
    return info;
}

#pragma mark - Private Methods

- (NSString *)getCurrentUrlScheme {
    NSArray *urlTypes = _infoDictionary[@"CFBundleURLTypes"];
    for (NSDictionary *dic in urlTypes) {
        NSArray *schemes = dic[@"CFBundleURLSchemes"];
        for (NSString *urlScheme in schemes) {
            if ([urlScheme isKindOfClass:[NSString class]] && [urlScheme hasPrefix:@"growing."]) {
                return urlScheme;
            }
        }
    }
    return nil;
}

- (NSString *)getDeviceIdString {
#if Growing_OS_PURE_IOS || Growing_OS_WATCH || Growing_OS_VISION || Growing_OS_TV
    NSString *deviceIdString = [GrowingKeyChainWrapper keyChainObjectForKey:kGrowingKeychainUserIdKey];
    if ([deviceIdString growingHelper_isValidU]) {
        return deviceIdString;
    }
#endif

    NSString *uuid = [GrowingUserIdentifier getUserIdentifier];
#if Growing_OS_PURE_IOS || Growing_OS_WATCH || Growing_OS_VISION || Growing_OS_TV
    [GrowingKeyChainWrapper setKeychainObject:uuid forKey:kGrowingKeychainUserIdKey];
#endif
    _isNewDevice = YES;
    return uuid;
}

+ (NSString *)getSysInfoByName:(char *)name {
    size_t size;
    NSString *results = nil;
    if (sysctlbyname(name, NULL, &size, NULL, 0) == 0) {
        char *machine = calloc(1, size);
        if (sysctlbyname(name, machine, &size, NULL, 0) == 0) {
            results = [NSString stringWithCString:machine encoding:NSUTF8StringEncoding];
        }
        free(machine);
    }
    return results ?: @"";
}

#if Growing_OS_PURE_IOS
- (void)handleStatusBarOrientationChange:(NSNotification *)notification {
    UIInterfaceOrientation orientation = [[GrowingULApplication sharedApplication] statusBarOrientation];
    if (orientation != UIInterfaceOrientationUnknown) {
        _deviceOrientation = UIInterfaceOrientationIsPortrait(orientation) ? @"PORTRAIT" : @"LANDSCAPE";
    }
}
#endif

- (void)updateAppState {
    dispatch_block_t block = ^{
#if Growing_USE_APPKIT
        self->_appState = [[GrowingULApplication sharedApplication] isActive] ? 0 : 1;
#elif Growing_USE_UIKIT
        self->_appState =
            [[GrowingULApplication sharedApplication] applicationState] == UIApplicationStateActive ? 0 : 1;
#elif Growing_USE_WATCHKIT
        self->_appState = [WKApplication sharedApplication].applicationState == WKApplicationStateActive ? 0 : 1;
#endif
    };

#if !Growing_OS_OSX
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
    if (!_deviceIDString) {
        GROWING_LOCK(lock);
        // double checked locking
        if (!_deviceIDString) {
            _deviceIDString = [self getDeviceIdString];
        }
        GROWING_UNLOCK(lock);
    }
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
#if Growing_USE_APPKIT || Growing_OS_MACCATALYST
        _deviceModel = [GrowingDeviceInfo getSysInfoByName:(char *)"hw.model"];
#elif Growing_USE_UIKIT
        struct utsname systemInfo;
        uname(&systemInfo);
        _deviceModel = @(systemInfo.machine);
#elif Growing_USE_WATCHKIT
        _deviceModel = [GrowingDeviceInfo getSysInfoByName:(char *)"hw.machine"];
#else
        _deviceModel = @"Undefined";
#endif
    }
    return _deviceModel;
}

- (NSString *)deviceType {
    if (!_deviceType) {
#if Growing_USE_APPKIT || Growing_OS_MACCATALYST
        _deviceType = @"Mac";
#elif Growing_USE_UIKIT
        _deviceType = [UIDevice currentDevice].model;
#elif Growing_USE_WATCHKIT
        _deviceType = [WKInterfaceDevice currentDevice].model;
#else
        _deviceType = @"Undefined";
#endif
    }
    return _deviceType;
}

- (NSString *)platform {
    if (!_platform) {
#if Growing_OS_OSX
        _platform = @"macOS";
#elif Growing_OS_MACCATALYST
        _platform = @"MacCatalyst";
#elif Growing_OS_PURE_IOS
        _platform = @"iOS";
#elif Growing_OS_WATCH
        _platform = @"watchOS";
#elif Growing_OS_TV
        _platform = @"tvOS";
#elif Growing_OS_VISION
        _platform = @"visionOS";
#else
        _platform = @"Undefined";
#endif
    }
    return _platform;
}

- (NSString *)platformVersion {
    if (!_platformVersion) {
#if Growing_USE_APPKIT || Growing_OS_MACCATALYST
        NSDictionary *dic =
            [NSDictionary dictionaryWithContentsOfFile:@"/System/Library/CoreServices/SystemVersion.plist"];
        _platformVersion = dic[@"ProductVersion"];
#elif Growing_USE_UIKIT
        _platformVersion = [UIDevice currentDevice].systemVersion;
#elif Growing_USE_WATCHKIT
        _platformVersion = [WKInterfaceDevice currentDevice].systemVersion;
#else
        _platformVersion = @"1.0";
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

@end
