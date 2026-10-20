//
//  GrowingConfigurationManager.m
//  GrowingAnalytics
//
// Created by xiangyang on 2020/11/10.
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

#import "GrowingTrackerCore/Manager/GrowingConfigurationManager.h"

NSString *const GrowingRoutingErrorDomain = @"com.growing.routing";

static BOOL GrowingIsNonEmptyString(id value) {
    return [value isKindOfClass:NSString.class] && [(NSString *)value length] > 0;
}

/// 新系统默认会对非法字符做百分号编码后再解析，这里要求原样合法，非法时返回 nil
static NSURLComponents *GrowingStrictURLComponents(NSString *string) {
    if (@available(iOS 17.0, macCatalyst 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)) {
        return [NSURLComponents componentsWithString:string encodingInvalidCharacters:NO];
    }
    return [NSURLComponents componentsWithString:string];
}

/// 采集地址会与请求路径直接拼接，因此只接受 http(s) 地址，
/// 必须有 host，端口须合法，且不能带用户信息、query 或 fragment
static BOOL GrowingIsValidServerHost(id serverHost) {
    if (!GrowingIsNonEmptyString(serverHost)) {
        return NO;
    }
    NSURLComponents *components = GrowingStrictURLComponents(serverHost);
    NSString *scheme = components.scheme.lowercaseString;
    if (![scheme isEqualToString:@"http"] && ![scheme isEqualToString:@"https"]) {
        return NO;
    }
    if (components.host.length == 0) {
        return NO;
    }
    NSNumber *port = components.port;
    if (port && (port.integerValue < 1 || port.integerValue > 65535)) {
        return NO;
    }
    return !components.user && !components.password && !components.query && !components.fragment;
}

static void GrowingSetRoutingError(NSError **error, GrowingRoutingError code, NSString *description) {
    if (error) {
        *error = [NSError errorWithDomain:GrowingRoutingErrorDomain
                                     code:code
                                 userInfo:@{NSLocalizedDescriptionKey: description}];
    }
}

@implementation GrowingConfigurationManager

+ (instancetype)sharedInstance {
    static id _sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[self alloc] init];
    });

    return _sharedInstance;
}

+ (NSDictionary<NSString *, NSString *> *)validatedServerHostMappingForConfiguration:
                                              (GrowingTrackConfiguration *)configuration
                                                                               error:(NSError **)error {
    NSString *dataSourceId = configuration.dataSourceId;
    NSDictionary *input = configuration.serverHostMapping;
    // 只配置了 dataCollectionServerHost 时沿用旧行为、不校验地址格式，避免老用户升级后初始化抛异常
    BOOL isLegacyServerHost = input == nil;
    if (isLegacyServerHost && dataSourceId.length > 0 && configuration.dataCollectionServerHost.length > 0) {
        input = @{dataSourceId: configuration.dataCollectionServerHost};
    }
    if (![input isKindOfClass:NSDictionary.class] || dataSourceId.length == 0) {
        GrowingSetRoutingError(error,
                               GrowingRoutingErrorInvalidServerHostMapping,
                               @"Invalid data source or server host mapping");
        return nil;
    }

    NSMutableDictionary<NSString *, NSString *> *mapping = [NSMutableDictionary dictionaryWithCapacity:input.count];
    for (id key in input) {
        id serverHost = input[key];
        BOOL validServerHost =
            isLegacyServerHost ? GrowingIsNonEmptyString(serverHost) : GrowingIsValidServerHost(serverHost);
        if (!GrowingIsNonEmptyString(key) || !validServerHost) {
            GrowingSetRoutingError(
                error,
                GrowingRoutingErrorInvalidServerHostMapping,
                [NSString stringWithFormat:@"Invalid collection URL for data source %@: %@", key, serverHost]);
            return nil;
        }
        mapping[[key copy]] = [serverHost copy];
    }
    if (!mapping[dataSourceId]) {
        GrowingSetRoutingError(error,
                               GrowingRoutingErrorInvalidServerHostMapping,
                               @"The server host mapping does not contain the current data source");
        return nil;
    }

    return mapping.copy;
}

- (NSString *)serverHostForDataSourceId:(NSString *)dataSourceId {
    return dataSourceId.length ? self.trackConfiguration.serverHostMapping[dataSourceId] : nil;
}

- (BOOL)switchToDataSourceId:(NSString *)dataSourceId
    dataCollectionServerHost:(NSString *)serverHost
                       error:(NSError **)error {
    if (!GrowingIsNonEmptyString(dataSourceId) || (serverHost && !GrowingIsNonEmptyString(serverHost))) {
        GrowingSetRoutingError(error, GrowingRoutingErrorInvalidDataSource, @"Invalid data source or collection URL");
        return NO;
    }

    NSString *registeredServerHost = [self serverHostForDataSourceId:dataSourceId];
    if (registeredServerHost) {
        if (serverHost && ![serverHost isEqualToString:registeredServerHost]) {
            GrowingSetRoutingError(error,
                                   GrowingRoutingErrorConflictingServerHost,
                                   @"The data source already has a different collection URL");
            return NO;
        }
    } else if (!serverHost) {
        GrowingSetRoutingError(error,
                               GrowingRoutingErrorInvalidDataSource,
                               @"The data source is not registered and no collection URL is provided");
        return NO;
    } else if (!GrowingIsValidServerHost(serverHost)) {
        GrowingSetRoutingError(error,
                               GrowingRoutingErrorInvalidServerHost,
                               [NSString stringWithFormat:@"Invalid collection URL: %@", serverHost]);
        return NO;
    }

    GrowingTrackConfiguration *configuration = self.trackConfiguration;
    if ([dataSourceId isEqualToString:configuration.dataSourceId]) {
        return NO;
    }
    NSMutableDictionary<NSString *, NSString *> *mapping =
        configuration.serverHostMapping.mutableCopy ?: [NSMutableDictionary dictionary];
    mapping[dataSourceId] = registeredServerHost ?: serverHost;
    [configuration growing_updateDataSourceId:dataSourceId serverHostMapping:mapping];
    return YES;
}

@end
