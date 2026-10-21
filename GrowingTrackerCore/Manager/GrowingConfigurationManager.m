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

static BOOL GrowingIsValidRoute(id route) {
    if (![route isKindOfClass:GrowingDataSourceRoute.class]) {
        return NO;
    }
    GrowingDataSourceRoute *candidate = (GrowingDataSourceRoute *)route;
    return GrowingIsNonEmptyString(candidate.accountId) && GrowingIsNonEmptyString(candidate.dataSourceId) &&
           GrowingIsValidServerHost(candidate.dataCollectionServerHost);
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

+ (NSArray<GrowingDataSourceRoute *> *)validatedRoutesForConfiguration:(GrowingTrackConfiguration *)configuration
                                                                 error:(NSError **)error {
    NSString *accountId = configuration.accountId;
    NSString *dataSourceId = configuration.dataSourceId;
    if (!GrowingIsNonEmptyString(accountId) || !GrowingIsNonEmptyString(dataSourceId)) {
        GrowingSetRoutingError(error, GrowingRoutingErrorInvalidRoutes, @"accountId and dataSourceId are required");
        return nil;
    }

    NSArray *input = configuration.dataSourceRoutes;
    if (!input) {
        // 只配置了 dataCollectionServerHost 时沿用旧行为、不校验地址格式，避免老用户升级后初始化抛异常
        NSString *serverHost = configuration.dataCollectionServerHost;
        if (!GrowingIsNonEmptyString(serverHost)) {
            GrowingSetRoutingError(error, GrowingRoutingErrorInvalidRoutes, @"dataCollectionServerHost is required");
            return nil;
        }
        return @[[GrowingDataSourceRoute routeWithAccountId:accountId
                                               dataSourceId:dataSourceId
                                   dataCollectionServerHost:serverHost]];
    }
    if (![input isKindOfClass:NSArray.class]) {
        GrowingSetRoutingError(error, GrowingRoutingErrorInvalidRoutes, @"dataSourceRoutes must be an array");
        return nil;
    }

    NSMutableArray<GrowingDataSourceRoute *> *routes = [NSMutableArray arrayWithCapacity:input.count];
    NSMutableDictionary<NSString *, GrowingDataSourceRoute *> *routesByDataSourceId =
        [NSMutableDictionary dictionaryWithCapacity:input.count];
    for (id item in input) {
        if (!GrowingIsValidRoute(item)) {
            GrowingSetRoutingError(error,
                                   GrowingRoutingErrorInvalidRoutes,
                                   [NSString stringWithFormat:@"Invalid data source route: %@", item]);
            return nil;
        }
        GrowingDataSourceRoute *route = (GrowingDataSourceRoute *)item;
        GrowingDataSourceRoute *existing = routesByDataSourceId[route.dataSourceId];
        if (existing) {
            if (![existing isEqual:route]) {
                GrowingSetRoutingError(
                    error,
                    GrowingRoutingErrorInvalidRoutes,
                    [NSString stringWithFormat:@"Conflicting routes for data source %@", route.dataSourceId]);
                return nil;
            }
            continue;
        }
        routesByDataSourceId[route.dataSourceId] = route;
        [routes addObject:route];
    }

    if (![routesByDataSourceId[dataSourceId].accountId isEqualToString:accountId]) {
        GrowingSetRoutingError(error,
                               GrowingRoutingErrorInvalidRoutes,
                               @"dataSourceRoutes must contain the configured accountId and dataSourceId");
        return nil;
    }

    return routes.copy;
}

- (GrowingDataSourceRoute *)routeForDataSourceId:(NSString *)dataSourceId {
    return [self.trackConfiguration growing_routeForDataSourceId:dataSourceId];
}

- (BOOL)switchToAccountId:(NSString *)accountId
                dataSourceId:(NSString *)dataSourceId
    dataCollectionServerHost:(NSString *)serverHost
                       error:(NSError **)error {
    if (!GrowingIsNonEmptyString(dataSourceId)) {
        GrowingSetRoutingError(error, GrowingRoutingErrorInvalidDataSource, @"Invalid data source");
        return NO;
    }

    GrowingTrackConfiguration *configuration = self.trackConfiguration;
    GrowingDataSourceRoute *route = [configuration growing_routeForDataSourceId:dataSourceId];
    BOOL isRegistering = accountId != nil || serverHost != nil;
    if (isRegistering) {
        GrowingDataSourceRoute *candidate = [GrowingDataSourceRoute routeWithAccountId:accountId
                                                                          dataSourceId:dataSourceId
                                                              dataCollectionServerHost:serverHost];
        if (route) {
            if (![route isEqual:candidate]) {
                GrowingSetRoutingError(error,
                                       GrowingRoutingErrorConflictingRoute,
                                       @"The data source is already registered with a different route");
                return NO;
            }
        } else if (!GrowingIsValidRoute(candidate)) {
            GrowingSetRoutingError(error,
                                   GrowingRoutingErrorInvalidRoute,
                                   [NSString stringWithFormat:@"Invalid data source route: %@", candidate]);
            return NO;
        } else {
            route = candidate;
        }
    } else if (!route) {
        GrowingSetRoutingError(error, GrowingRoutingErrorInvalidDataSource, @"The data source is not registered");
        return NO;
    }

    if ([dataSourceId isEqualToString:configuration.dataSourceId]) {
        return NO;
    }
    NSArray<GrowingDataSourceRoute *> *routes = configuration.dataSourceRoutes ?: @[];
    if (![routes containsObject:route]) {
        routes = [routes arrayByAddingObject:route];
    }
    [configuration growing_activateRoute:route withRoutes:routes];
    return YES;
}

@end
