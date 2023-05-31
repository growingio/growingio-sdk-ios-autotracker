//
//  GrowingAsaFetcher.m
//  GrowingAnalytics
//
//  Created by YoloMao on 2022/8/29.
//  Copyright (C) 2022 Beijing Yishu Technology Co., Ltd.
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

#import "Modules/Advert/AppleSearchAds/GrowingAsaFetcher.h"
#import "Modules/Advert/Event/GrowingActivateEvent.h"
#import "Modules/Advert/Event/GrowingAdvertEventType.h"
#import "Modules/Advert/Public/GrowingAdvertising.h"
#import "Modules/Advert/Utils/GrowingAdUtils.h"

#import "GrowingTrackerCore/Event/GrowingEventManager.h"
#import "GrowingTrackerCore/Helpers/GrowingHelpers.h"
#import "GrowingTrackerCore/Manager/GrowingConfigurationManager.h"
#import "GrowingTrackerCore/Thirdparty/Logger/GrowingLogger.h"

#import <objc/runtime.h>
#import <pthread.h>

static NSErrorDomain const kGrowingAsaFetcherErrorDomain = @"GrowingAsaFetcherErrorDomain";
typedef NS_ERROR_ENUM(kGrowingAsaFetcherErrorDomain, GrowingAsaFetcherError){
    GrowingAsaFetcherErrorTrackingRestrictedOrDenied = 1,
    GrowingAsaFetcherErrorMissingData = 2,
    GrowingAsaFetcherErrorCorruptResponse = 3,
    GrowingAsaFetcherErrorRequestClientError = 4,
    GrowingAsaFetcherErrorRequestServerError = 5,
    GrowingAsaFetcherErrorRequestNetworkError = 6,
    GrowingAsaFetcherErrorUnsupportedPlatform = 7,
    GrowingAsaFetcherErrorTimedOut = 100,
    GrowingAsaFetcherErrorTokenInvalid = 101}; /* ADClientError */

CGFloat const GrowingAsaFetcherDefaultTimeOut = 15.0f;
static NSInteger const _retryCount = 3;
static CGFloat const _retryDelay = 5.0f;
static CGFloat const _eachRequestTimeOut = 5.0f;
static pthread_rwlock_t _lock = PTHREAD_RWLOCK_INITIALIZER;

@interface GrowingAsaFetcher () <GrowingEventInterceptor>

@property (nonatomic, assign) NSInteger retriesLeft;
@property (nonatomic, copy) NSString *token;
@property (nonatomic, weak) NSURLSessionDataTask *task;

@end

@implementation GrowingAsaFetcher

#pragma mark - Init

+ (instancetype)sharedInstance {
    static GrowingAsaFetcher *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[GrowingAsaFetcher alloc] init];
    });
    return instance;
}

#pragma mark - GrowingEventInterceptor

- (NSArray *)growingEventManagerEventsWillSend:(NSArray<id<GrowingEventPersistenceProtocol>> *)events
                                       channel:(GrowingEventChannel *)channel {
    if (channel.eventTypes.count == 0 || [channel.eventTypes indexOfObject:GrowingEventTypeActivate] == NSNotFound) {
        return events;
    }

    id<GrowingEventPersistenceProtocol> activate = nil;
    for (id<GrowingEventPersistenceProtocol> event in events) {
        if ([event.eventType isEqualToString:GrowingEventTypeActivate]) {
            id jsonObject = event.toJSONObject;
            if ([jsonObject isKindOfClass:[NSDictionary class]]) {
                NSDictionary *dic = (NSDictionary *)jsonObject;
                if (!dic[@"eventName"]  // 兼容旧版无 eventName
                    || [dic[@"eventName"] isEqualToString:GrowingAdvertEventNameActivate]) {
                    activate = event;
                    break;
                }
            }
        }
    }
    if (activate == nil) {
        if ([GrowingAdUtils isActivateWrote]) {
            // 已产生activate事件且已发送(数据库内无activate事件且isActivateWrote)
            // 一般发生于：activate事件发送之后，[GrowingAdUtils setActivateSent:YES]执行过程中，文件写入失败
            GrowingAsaFetcher.status = GrowingAsaFetcherStatusCompleted;
            [GrowingAdUtils setActivateSent:YES];

            dispatch_async(dispatch_get_main_queue(), ^{
                [[GrowingEventManager sharedInstance] removeInterceptor:self];
            });
        }
        return events;
    }

    if (GrowingAsaFetcher.status == GrowingAsaFetcherStatusFetching) {
        // AsaData 还在获取中，activate 需延迟上传
        NSMutableArray *array = [NSMutableArray arrayWithArray:events];
        [array removeObject:activate];
        return array;
    } else {
        if (GrowingAsaFetcher.asaData.allKeys.count > 0) {
            NSString *jsonString = [[NSString alloc] initWithJsonObject_growingHelper:GrowingAsaFetcher.asaData];
            [activate appendExtraParams:@{@"appleSearchAds": jsonString}];
        }

        if (GrowingAsaFetcher.status == GrowingAsaFetcherStatusFailure) {
            // AsaData 获取失败，上传 activate 的同时，再次尝试获取 AsaData
            [GrowingAsaFetcher retry];
        }
    }

    return events;
}

- (void)growingEventManagerEventsDidSend:(NSArray<id<GrowingEventPersistenceProtocol>> *)events
                                 channel:(GrowingEventChannel *)channel {
    for (id<GrowingEventPersistenceProtocol> event in events) {
        if ([event.eventType isEqualToString:GrowingEventTypeActivate]) {
            id jsonObject = event.toJSONObject;
            if ([jsonObject isKindOfClass:[NSDictionary class]]) {
                NSDictionary *dic = (NSDictionary *)jsonObject;
                if ([dic[@"eventName"] isEqualToString:GrowingAdvertEventNameActivate] ||
                    [dic[@"eventName"] isEqualToString:GrowingAdvertEventNameDefer]) {
                    // 普通激活和 defer 都可视为激活已发送
                    GrowingAsaFetcher.status = GrowingAsaFetcherStatusCompleted;
                    [GrowingAdUtils setActivateSent:YES];

                    dispatch_async(dispatch_get_main_queue(), ^{
                        [[GrowingEventManager sharedInstance] removeInterceptor:self];
                    });
                    break;
                }
            }
        }
    }
}

#pragma mark - Public Method

+ (void)startFetchWithTimeOut:(CGFloat)timeOut {
    if (self.status >= GrowingAsaFetcherStatusFetching) {
        return;
    }

    if ([GrowingAdUtils isActivateSent]) {
        /*
         * 1. isActivateWrote并不能正确代表activate事件已发送，只能代表已生成
         * 2. 因此这里使用isActivateSent来保证activate事件已发送
         *
         * ------------------------------------------------------------------------------
         * |       -          |  !isActivateWrote  |           isActivateWrote          |
         * | isActivateSent   |          -         |   已发送activate事件，不再获取AsaData  |
         * | !isActivateSent  |     首次安装App     |                 (4)                 |
         * ------------------------------------------------------------------------------
         * 场景[4]有2种情况：
         * (1)已产生activate事件，但尚未发送
         * (2)已产生activate事件且已发送，需要在事件上传时另做判断，如果数据库内无activate事件且isActivateWrote，
         *    则setActivateSent = YES，并setStatus = GrowingAsaFetcherStatusCompleted
         *    见 -[GrowingAsaFetcher growingEventManagerEventsWillSend:]
         */
        self.status = GrowingAsaFetcherStatusCompleted;
        return;
    }

    GrowingTrackConfiguration *trackConfiguration = GrowingConfigurationManager.sharedInstance.trackConfiguration;
    if (!trackConfiguration.dataCollectionEnabled) {
        GIOLogDebug(@"[GrowingAdvertising] AsaFetcher - dataCollectionEnabled is NO");
        self.status = GrowingAsaFetcherStatusDenied;
        return;
    }

    if (!trackConfiguration.ASAEnabled) {
        GIOLogDebug(@"[GrowingAdvertising] AsaFetcher - ASAEnabled is NO");
        self.status = GrowingAsaFetcherStatusDenied;
        return;
    }

    if (@available(iOS 14.3, *)) {
        Class cls = NSClassFromString(@"AAAttribution");
        if (cls == nil) {
            GIOLogDebug(@"[GrowingAdvertising] AsaFetcher - please integrate AdServices framework");
            self.status = GrowingAsaFetcherStatusDenied;
            return;
        }
    } else {
        Class cls = NSClassFromString(@"ADClient");
        if (cls == nil) {
            GIOLogDebug(@"[GrowingAdvertising] AsaFetcher - please integrate iAd framework");
            self.status = GrowingAsaFetcherStatusDenied;
            return;
        }
    }

    [[GrowingEventManager sharedInstance] addInterceptor:[GrowingAsaFetcher sharedInstance]];
    GIOLogDebug(@"[GrowingAdvertising] AsaFetcher start fetch with time out %.2f sec", timeOut);
    self.status = GrowingAsaFetcherStatusFetching;
    [GrowingAsaFetcher sharedInstance].retriesLeft = _retryCount;
    [[GrowingAsaFetcher sharedInstance] fetchAttribution];

    /*
     * 这里定义了2个超时：
     * 1. iAd.framework/AdServices.framework获取超时，每一次获取周期遵循_eachRequestTimeOut的超时限制
     * 2. startFetchWithTimeOut传入的超时限制，超过timeOut后，activate的发送不再等待AsaFetcher获取asaData
     */
    dispatch_time_t delayTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(timeOut * NSEC_PER_SEC));
    dispatch_after(delayTime, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if (self.status != GrowingAsaFetcherStatusFetching) {
            return;
        }

        [GrowingAsaFetcher sharedInstance].retriesLeft = 0;
        if (@available(iOS 14.3, *)) {
            if ([GrowingAsaFetcher sharedInstance].token.length > 0) {
                NSString *token = [GrowingAsaFetcher sharedInstance].token;
                GrowingAsaFetcher.asaData = [GrowingAsaFetcher mapDictionaryForUpload:@{@"token": token} isIAd:NO];
            }

            if ([GrowingAsaFetcher sharedInstance].task) {
                if ([GrowingAsaFetcher sharedInstance].task.state == NSURLSessionTaskStateRunning) {
                    [[GrowingAsaFetcher sharedInstance].task cancel];
                }
                [GrowingAsaFetcher sharedInstance].task = nil;
            }
        }
        GrowingAsaFetcher.status = GrowingAsaFetcherStatusFailure;
        GIOLogError(@"[GrowingAdvertising] AsaFetcher error: total time is out");
    });
}

+ (void)retry {
    if (self.status >= GrowingAsaFetcherStatusFetching) {
        return;
    }

    GIOLogDebug(@"[GrowingAdvertising] AsaFetcher begin retry");
    self.status = GrowingAsaFetcherStatusFetching;
    [GrowingAsaFetcher sharedInstance].retriesLeft = 1;  // only retry once time
    [[GrowingAsaFetcher sharedInstance] fetchAttribution];
}

#pragma mark - Private Method

- (void)fetchAttribution {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if (@available(iOS 14.3, *)) {
            if (self.token.length > 0) {
                [self attributionWithToken:self.token];
            } else {
                [self fetchFromAdServices];
            }
        } else {
            [self fetchFromIAd];
        }
    });
}

- (void)saveAttributionDetails:(NSDictionary *_Nullable)attributionDetails
                         isIAd:(BOOL)isIAd
                         error:(NSError *_Nullable)error {
    // async，需要确认 status 是否改变
    if (GrowingAsaFetcher.status != GrowingAsaFetcherStatusFetching) {
        return;
    }

    if (error) {
        GIOLogError(@"[GrowingAdvertising] AsaFetcher error: %@", error.description);
        switch (error.code) {
            case GrowingAsaFetcherErrorMissingData:
            case GrowingAsaFetcherErrorCorruptResponse:
            case GrowingAsaFetcherErrorRequestClientError:
            case GrowingAsaFetcherErrorRequestServerError:
            case GrowingAsaFetcherErrorRequestNetworkError: {
                if (self.retriesLeft <= 0) {
                    GrowingAsaFetcher.asaData = [GrowingAsaFetcher mapDictionaryForUpload:attributionDetails
                                                                                    isIAd:isIAd];
                    GrowingAsaFetcher.status = GrowingAsaFetcherStatusFailure;
                    return;
                }
                int64_t retryDelay = 0;
                self.retriesLeft--;
                switch (self.retriesLeft) {
                    case 2:
                        retryDelay = _retryDelay * NSEC_PER_SEC;
                        break;
                    default:
                        retryDelay = 2 * NSEC_PER_SEC;
                        break;
                }
                dispatch_time_t retryTime = dispatch_time(DISPATCH_TIME_NOW, retryDelay);
                dispatch_after(retryTime, dispatch_get_main_queue(), ^{
                    [self fetchAttribution];
                });
                return;
            }
            case GrowingAsaFetcherErrorTimedOut:
            case GrowingAsaFetcherErrorTokenInvalid: {
                if (self.retriesLeft <= 0) {
                    GrowingAsaFetcher.asaData = [GrowingAsaFetcher mapDictionaryForUpload:attributionDetails
                                                                                    isIAd:isIAd];
                    GrowingAsaFetcher.status = GrowingAsaFetcherStatusFailure;
                    return;
                }
                self.retriesLeft--;
                [self fetchAttribution];
            }
                return;
            case GrowingAsaFetcherErrorTrackingRestrictedOrDenied:
            case GrowingAsaFetcherErrorUnsupportedPlatform:
                GrowingAsaFetcher.status = GrowingAsaFetcherStatusDenied;
                return;
        }
    }

    GrowingAsaFetcher.asaData = [GrowingAsaFetcher mapDictionaryForUpload:attributionDetails isIAd:isIAd];
    GrowingAsaFetcher.status = GrowingAsaFetcherStatusSuccess;
}

+ (nullable NSDictionary *)mapDictionaryForUpload:(NSDictionary *)dic isIAd:(BOOL)isIAd {
    if (dic.allKeys.count == 0) {
        return nil;
    }
    NSMutableDictionary *result = [NSMutableDictionary dictionaryWithDictionary:dic];
    [result setObject:isIAd ? @"iad" : @"adss" forKey:@"src"];
    return result;
}

#pragma mark iAd.framework

- (void)fetchFromIAd {
    Class cls = NSClassFromString(@"ADClient");
    if (cls == nil) {
        GrowingAsaFetcher.status = GrowingAsaFetcherStatusDenied;
        return;
    }

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    SEL sel = NSSelectorFromString(@"sharedClient");
    if (![cls respondsToSelector:sel]) {
        GrowingAsaFetcher.status = GrowingAsaFetcherStatusDenied;
        return;
    }

    id instance = [cls performSelector:sel];
    if (instance == nil) {
        GrowingAsaFetcher.status = GrowingAsaFetcherStatusDenied;
        return;
    }

    SEL iAdDetailSelector = NSSelectorFromString(@"requestAttributionDetailsWithBlock:");
    if (![instance respondsToSelector:iAdDetailSelector]) {
        GrowingAsaFetcher.status = GrowingAsaFetcherStatusDenied;
        return;
    }

    __block Class lock = [GrowingAsaFetcher class];
    __block BOOL completed = NO;
    [instance performSelector:iAdDetailSelector
                   withObject:^(NSDictionary *attributionDetails, NSError *error) {
                       @synchronized(lock) {
                           if (completed) {
                               return;
                           } else {
                               completed = YES;
                           }
                       }
                       [self saveAttributionDetails:attributionDetails isIAd:YES error:error];
                   }];

    dispatch_time_t delayTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(_eachRequestTimeOut * NSEC_PER_SEC));
    dispatch_after(delayTime, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        @synchronized(lock) {
            if (completed) {
                return;
            } else {
                completed = YES;
            }
        }
        [self saveAttributionDetails:nil
                               isIAd:YES
                               error:[NSError errorWithDomain:kGrowingAsaFetcherErrorDomain
                                                         code:GrowingAsaFetcherErrorTimedOut
                                                     userInfo:@{NSLocalizedDescriptionKey: @"time is out"}]];
    });
#pragma clang diagnostic pop
}

#pragma mark AdServices.framework

- (void)fetchFromAdServices {
    Class cls = NSClassFromString(@"AAAttribution");
    if (cls == nil) {
        GrowingAsaFetcher.status = GrowingAsaFetcherStatusDenied;
        return;
    }

    SEL sel = NSSelectorFromString(@"attributionTokenWithError:");
    if (![cls respondsToSelector:sel]) {
        GrowingAsaFetcher.status = GrowingAsaFetcherStatusDenied;
        return;
    }

    NSMethodSignature *methodSignature = [cls methodSignatureForSelector:sel];
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:methodSignature];
    [invocation setSelector:sel];
    [invocation setTarget:cls];
    __autoreleasing NSError *error;
    __autoreleasing NSError **errorPointer = &error;
    [invocation setArgument:&errorPointer atIndex:2];
    [invocation invoke];

    if (error) {
        GIOLogError(@"[GrowingAdvertising] AsaFetcher error: request token error");
        switch (error.code) {
            case 1 /* AAAttributionErrorCodeNetworkError */:
            case 2 /* AAAttributionErrorCodeInternalError */: {
                NSDictionary *userInfo = @{NSLocalizedDescriptionKey: @"request token failed"};
                [self saveAttributionDetails:nil
                                       isIAd:NO
                                       error:[NSError errorWithDomain:kGrowingAsaFetcherErrorDomain
                                                                 code:GrowingAsaFetcherErrorTokenInvalid
                                                             userInfo:userInfo]];
            }
                return;
            case 3 /* AAAttributionErrorCodePlatformNotSupported */:
                GrowingAsaFetcher.status = GrowingAsaFetcherStatusDenied;
                return;
            default:
                GrowingAsaFetcher.status = GrowingAsaFetcherStatusDenied;
                return;
        }
    }

    NSString *__unsafe_unretained tmpToken = nil;
    [invocation getReturnValue:&tmpToken];
    NSString *token = tmpToken;
    GIOLogDebug(@"[GrowingAdvertising] AsaFetcher request token succeed, token = %@", token);
    [self attributionWithToken:token];
}

- (void)attributionWithToken:(NSString *)token {
    self.token = token;

    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];
    NSURL *url = [NSURL URLWithString:@"https://api-adservices.apple.com/api/v1/"];
    if (!url) {
        return;
    }
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:_eachRequestTimeOut];
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPMethod:@"POST"];
    NSData *postData = [token dataUsingEncoding:NSUTF8StringEncoding];
    [request setHTTPBody:postData];
    NSURLSessionDataTask *task = [session
        dataTaskWithRequest:request
          completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
              if (error) {
                  if (error.code == NSURLErrorCancelled) {
                      return;
                  }
                  GrowingAsaFetcherError code = error.code == NSURLErrorTimedOut
                                                    ? GrowingAsaFetcherErrorTimedOut
                                                    : GrowingAsaFetcherErrorRequestNetworkError;
                  [self saveAttributionDetails:@{@"token": token}
                                         isIAd:NO
                                         error:[NSError errorWithDomain:kGrowingAsaFetcherErrorDomain
                                                                   code:code
                                                               userInfo:error.userInfo]];
                  return;
              }

              if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
                  NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
                  NSInteger statusCode = httpResponse.statusCode;
                  if (statusCode == 200) {
                      NSError *resError;
                      NSDictionary *resDic = [NSJSONSerialization JSONObjectWithData:data
                                                                             options:kNilOptions
                                                                               error:&resError];
                      if (resError || resDic == nil) {
                          [self saveAttributionDetails:@{@"token": token}
                                                 isIAd:NO
                                                 error:[NSError errorWithDomain:kGrowingAsaFetcherErrorDomain
                                                                           code:GrowingAsaFetcherErrorCorruptResponse
                                                                       userInfo:resError.userInfo]];
                          return;
                      }

                      NSMutableDictionary *details = [NSMutableDictionary dictionaryWithDictionary:resDic];
                      details[@"token"] = token;
                      [self saveAttributionDetails:details isIAd:NO error:nil];
                  } else if (statusCode == 400 || statusCode == 404) {
                      // The token is invalid, or the API is unable to retrieve the requested attribution record.
                      self.token = nil;
                      NSDictionary *userInfo = @{NSLocalizedDescriptionKey: @"The token is invalid"};
                      [self saveAttributionDetails:nil
                                             isIAd:NO
                                             error:[NSError errorWithDomain:kGrowingAsaFetcherErrorDomain
                                                                       code:GrowingAsaFetcherErrorTokenInvalid
                                                                   userInfo:userInfo]];
                  } else {
                      NSDictionary *userInfo = @{
                          NSLocalizedDescriptionKey:
                              @"The server is temporarily down or not reachable."
                              @"The request may be valid, but you need to retry the request at a later point."
                      };
                      [self saveAttributionDetails:@{@"token": token}
                                             isIAd:NO
                                             error:[NSError errorWithDomain:kGrowingAsaFetcherErrorDomain
                                                                       code:GrowingAsaFetcherErrorRequestNetworkError
                                                                   userInfo:userInfo]];
                  }
              }
          }];
    [task resume];
    self.task = task;
}

#pragma mark - Setter & Getter

+ (GrowingAsaFetcherStatus)status {
    pthread_rwlock_rdlock(&_lock);
    int status = ((NSNumber *)objc_getAssociatedObject(self, _cmd)).intValue;
    pthread_rwlock_unlock(&_lock);
    return status;
}

+ (void)setStatus:(GrowingAsaFetcherStatus)status {
    if (self.status == status) {
        return;
    }

    pthread_rwlock_wrlock(&_lock);
    objc_setAssociatedObject(self, @selector(status), @(status), OBJC_ASSOCIATION_ASSIGN);
    pthread_rwlock_unlock(&_lock);
    GIOLogDebug(@"[GrowingAdvertising] AsaFetcher fetch status change to %@", [self statusDescription]);
}

+ (NSString *)statusDescription {
    switch (self.status) {
        case GrowingAsaFetcherStatusDenied:
            return @"denied";
        case GrowingAsaFetcherStatusFetching:
            return @"fetching";
        case GrowingAsaFetcherStatusSuccess:
            return @"success";
        case GrowingAsaFetcherStatusFailure:
            return @"failure";
        case GrowingAsaFetcherStatusCompleted:
            return @"completed";
        default:
            return @"";
    }
}

+ (NSDictionary *)asaData {
    return objc_getAssociatedObject(self, _cmd) ?: [NSDictionary dictionary];
}

+ (void)setAsaData:(NSDictionary *)asaData {
    objc_setAssociatedObject(self, @selector(asaData), asaData, OBJC_ASSOCIATION_COPY_NONATOMIC);
    GIOLogDebug(@"[GrowingAdvertising] AsaFetcher set ASA data = %@", asaData);
}

- (void)setRetriesLeft:(NSInteger)retriesLeft {
    _retriesLeft = retriesLeft;
    GIOLogDebug(@"[GrowingAdvertising] AsaFetcher retry left %ld", (long)_retriesLeft);
}

@end
