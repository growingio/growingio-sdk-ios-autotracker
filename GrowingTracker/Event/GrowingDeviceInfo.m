//
//  GrowingDeviceInfo.m
//  GrowingTracker
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

#import "GrowingDeviceInfo.h"

#import <pthread.h>
#import <sys/utsname.h>

#import "GrowingCocoaLumberjack.h"
#import "GrowingDispatchManager.h"
#import "GrowingInstance.h"
#import "NSString+GrowingHelper.h"

static NSString *kGrowingUrlScheme = nil;

@import CoreTelephony;

@implementation GrowingDeviceInfo

static pthread_mutex_t _mutex;

@synthesize deviceIDString = _deviceIDString;

// keychain
- (NSMutableDictionary *)getKeychainQuery:(NSString *)key {
    return [NSMutableDictionary dictionaryWithObjectsAndKeys:(id)kSecClassGenericPassword, (id)kSecClass, key,
                                                             (id)kSecAttrService, key, (id)kSecAttrAccount,
                                                             (id)kSecAttrAccessibleAlwaysThisDeviceOnly,
                                                             (id)kSecAttrAccessible, nil];
}

- (void)setKeychainObject:(id)value forKey:(NSString *)service {
    // Get search dictionary
    NSMutableDictionary *keychainQuery = [self getKeychainQuery:service];

    // Delete old item before add new item
    SecItemDelete((CFDictionaryRef)keychainQuery);

    // Add new object to search dictionary(Attention:the data format)
    [keychainQuery setObject:[NSKeyedArchiver archivedDataWithRootObject:value] forKey:(id)kSecValueData];

    // Add item to keychain with the search dictionary
    SecItemAdd((CFDictionaryRef)keychainQuery, NULL);
}

- (id)keyChainObjectForKey:(NSString *)key {
    id ret = nil;
    NSMutableDictionary *keychainQuery = [self getKeychainQuery:key];
    // Configure the search setting
    // Since in our simple case we are expecting only a single attribute to be
    // returned (the password) we can set the attribute kSecReturnData to
    // kCFBooleanTrue
    [keychainQuery setObject:(id)kCFBooleanTrue forKey:(id)kSecReturnData];
    [keychainQuery setObject:(id)kSecMatchLimitOne forKey:(id)kSecMatchLimit];
    CFDataRef keyData = NULL;
    if (SecItemCopyMatching((CFDictionaryRef)keychainQuery, (CFTypeRef *)&keyData) == noErr) {
        @try {
            ret = [NSKeyedUnarchiver unarchiveObjectWithData:(__bridge NSData *)keyData];
        } @catch (NSException *e) {
            GIOLogError(@"GrowingIO Unarchive of %@ failed: %@", key, e);
        } @finally {
        }
    }
    if (keyData) CFRelease(keyData);
    return ret;
}

- (void)removeKeyChainObjectForKey:(NSString *)service {
    NSMutableDictionary *keychainQuery = [self getKeychainQuery:service];
    SecItemDelete((CFDictionaryRef)keychainQuery);
}

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
    pthread_mutex_lock(&_mutex);
    if (!_deviceIDString) {
        _deviceIDString = [self getDeviceIdString];
    }
    pthread_mutex_unlock(&_mutex);
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

        __weak typeof(self) wself = self;
        _deviceIDBlock = [^NSString * {
            NSString *idfaString = [wself getUserIdentifier];
            if (idfaString.growingHelper_isValidU) {
                return idfaString;
            } else {
                return [[[UIDevice currentDevice] identifierForVendor] UUIDString];
            }
        } copy];

        pthread_mutex_init(&_mutex, NULL);
        // @property (nonatomic, readonly) NSString *deviceID;
        // 重写getter
        _idfv = [self getVendorId];
        _idfa = [self getUserIdentifier];

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
        _systemName = @"iOS";  // [[UIDevice currentDevice] systemName];

        // @property (nonatomic, readonly) NSString *systemVersion;
        _systemVersion = [[UIDevice currentDevice] systemVersion];

        // @property (nonatomic, readonly) NSString *appFullVersion;
        _appFullVersion = infoDictionary[@"CFBundleVersion"];
        if (!_appFullVersion) {
            _appFullVersion = @"";
        }

        // @property (nonatomic, readonly) NSString *appShortVersion;
        _appShortVersion = infoDictionary[@"CFBundleShortVersionString"];

        // @property (nonatomic, readonly) NSString *urlScheme;
        NSString *urlScheme = kGrowingUrlScheme;
        _urlScheme = urlScheme ?: [self getCurrentUrlScheme];

        NSMutableDictionary *customDict = [[NSMutableDictionary alloc] init];
        [infoDictionary enumerateKeysAndObjectsUsingBlock:^(NSString *key, id obj, BOOL *_Nonnull stop) {
            if ([key isKindOfClass:[NSString class]]) {
                [customDict setValue:obj forKey:key.lowercaseString];
            }
        }];

        [self resetSessionID];
    }
    return self;
}

#define GROWINGIO_KEYCHAIN_KEY @"GROWINGIO_KEYCHAIN_KEY"
#define GROWINGIO_CUSTOM_U_KEY @"GROWINGIO_CUSTOM_U_KEY"

- (NSString *)getDeviceIdString {
    NSString *customDeviceIdString = [self keyChainObjectForKey:GROWINGIO_CUSTOM_U_KEY];
    // 如果取到有效u值，直接返回
    if ([customDeviceIdString growingHelper_isValidU]) {
        return customDeviceIdString;
    }

    NSString *deviceIdString = [self keyChainObjectForKey:GROWINGIO_KEYCHAIN_KEY];
    // 如果取到有效u值，直接返回
    if ([deviceIdString growingHelper_isValidU]) {
        return deviceIdString;
    }

    NSString *uuid = nil;

    // 尝试取block
    if (self.deviceIDBlock) {
        NSString *blockUUID = self.deviceIDBlock();
        if ([blockUUID isKindOfClass:[NSString class]] && blockUUID.length > 0 && blockUUID.length <= 64) {
            uuid = blockUUID;
        }
    }

    // 失败了随机生成
    if (!uuid.length || !uuid.growingHelper_isValidU) {
        uuid = [[NSUUID UUID] UUIDString];
    }
    // 保存
    [self setKeychainObject:uuid forKey:GROWINGIO_KEYCHAIN_KEY];

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

- (void)resetSessionID {
    _sessionID = [[NSUUID UUID] UUIDString];
}

- (NSString *)getVendorId {
    NSString *vendorId = nil;

    if (NSClassFromString(@"UIDevice")) {
        vendorId = [[UIDevice currentDevice].identifierForVendor UUIDString];
    }

    return vendorId;
}

+ (void)configUrlScheme:(NSString *)urlScheme {
    kGrowingUrlScheme = urlScheme;
}

- (NSString *)getUserIdentifier {
    NSString *uid = @"";
#if !defined(GROWINGIO_NO_IFA)
    Class ASIdentifierManagerClass = NSClassFromString(@"ASIdentifierManager");
    if (!ASIdentifierManagerClass) {
        return uid;
    }

    SEL sharedManagerSelector = NSSelectorFromString(@"sharedManager");
    id sharedManager = ((id(*)(id, SEL))[ASIdentifierManagerClass methodForSelector:sharedManagerSelector])(
        ASIdentifierManagerClass, sharedManagerSelector);

    SEL trackingEnabledSelector = NSSelectorFromString(@"isAdvertisingTrackingEnabled");
    BOOL trackingEnabled = ((BOOL(*)(id, SEL))[sharedManager methodForSelector:trackingEnabledSelector])(
        sharedManager, trackingEnabledSelector);

    // In iOS 10.0 and later, the value of advertisingIdentifier is all zeroes
    // when the user has limited ad tracking; So return @"";
    if (IOS10_PLUS && !trackingEnabled) {
        return uid;
    }

    SEL advertisingIdentifierSelector = NSSelectorFromString(@"advertisingIdentifier");

    NSUUID *uuid = ((NSUUID * (*)(id, SEL))[sharedManager methodForSelector:advertisingIdentifierSelector])(
        sharedManager, advertisingIdentifierSelector);
    uid = [uuid UUIDString];
#endif
    return uid;
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

+ (NSString *)deviceOrientation {
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    if (orientation != UIInterfaceOrientationUnknown) {
        return UIInterfaceOrientationIsPortrait(orientation) ? @"PORTRAIT" : @"LANDSCAPE";
    }
    return nil;
}

@end
