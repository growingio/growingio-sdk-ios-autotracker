//
//  GrowingAuthManager.m
//  GrowingTracker
//
//  Created by GrowingIO on 15/10/27.
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


#import "GrowingAuthManager.h"
#import "GrowingInstance.h"
#import "NSData+GrowingHelper.h"
#import "GrowingUserDefaults.h"
#import "GrowingDeviceInfo.h"
#import "GrowingLoginMenu.h"
#import "GrowingCocoaLumberjack.h"
#import "GrowingLoginRequest.h"
#import "GrowingNetworkManager.h"

NSString *GrowingDidLogin = @"GrowingDidLogin";
NSString *GrowingDidLogout = @"GrowingDidLogout";

@interface GrowingAuthManager()

@property (nonatomic, copy, readwrite) NSString * _Nullable userId;
@property (nonatomic, copy, readwrite) NSString * _Nullable token;
@property (nonatomic, copy, readwrite) NSString * _Nullable loginToken;
@property (nonatomic, copy, readwrite) NSString * _Nullable refreshToken;
@property (nonatomic, assign) BOOL isLogingIn;
@property (nonatomic, assign) BOOL remindMe;

@end

@implementation GrowingAuthManager

@synthesize token = _token;
@synthesize userId = _userId;
@synthesize refreshToken = _refreshToken;

static GrowingAuthManager *authManager = nil;
+ (instancetype)shareManager {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        authManager = [[GrowingAuthManager alloc] init];
    });
    return authManager;
}

- (instancetype)init {
    if (self = [super init]) {
        self.remindMe = YES;
        self.isLogingIn = NO;
    }
    return self;
}

- (NSDictionary *)buildAuthorityHeader {
    NSMutableDictionary *header = [NSMutableDictionary dictionary];
    if (self.token) {
        header[@"token"] = self.token;
    }
    
    NSString *ai = [GrowingInstance sharedInstance].projectID;

    if (ai.length) {
        header[@"accountId"] = ai;
    }
    
    return header;
}

- (BOOL)authorityErrorHandle:(void (^)(BOOL))finishBlock {
    [GrowingLoginMenu showWithSucceed:^{
        finishBlock(YES);
    } fail:^{
        [[GrowingAuthManager shareManager] logout];
        finishBlock(NO);
    }];
    return NO;
}

- (BOOL)isLogin {
    return self.token.length != 0;
}

- (void)logout {
    self.token = nil;
    self.userId = nil;
    [[NSNotificationCenter defaultCenter] postNotificationName:GrowingDidLogout object:self];
}

- (void)loginWithToken:(NSString*)aToken {
    [self loginWithToken:aToken andUserId:@""];
}

- (void)loginWithToken:(NSString*)aToken andUserId:(NSString*)userId {
    self.token  = aToken;
    self.userId = userId;
    [[NSNotificationCenter defaultCenter] postNotificationName:GrowingDidLogin object:self];
}

- (void)loginWithLoginToken:(NSString*)aToken
                    success:(void (^)(void))successBlock
                    failure:(void (^)(NSString * _Nullable))failBlock {
    
    if (aToken.length == 0) { return; }
    
    NSDictionary *params = @{@"grantType": @"login_token",
                             @"loginToken": aToken};
    
    [self loginWithParameters:params succeed:^{
        if (successBlock) { successBlock(); }
        
    } fail:^(NSString * _Nullable errorMessage) {
        if (failBlock) { failBlock(errorMessage); }
    }];
}

- (void)refreshLoginToken:(void (^)(BOOL success))finalBlock {
    if (self.refreshToken.length == 0) {
        if (finalBlock) { finalBlock(NO); }
        return;
    }
    
    NSDictionary *params = @{@"grantType": @"refresh_token",
                             @"refreshToken": self.refreshToken};
    
    [self loginWithParameters:params succeed:^{
        if (finalBlock) { finalBlock(YES); }
    } fail:^(NSString * _Nullable errorMessage) {
        if (finalBlock) { finalBlock(NO); }
    }];
}

- (void)loginByUserId:(NSString *)userId
             password:(NSString *)password
              succeed:(void (^)(void))succeedBlock
                 fail:(void (^)(NSString * _Nullable))failBlock {
    NSString *bundleID = [GrowingDeviceInfo currentDeviceInfo].bundleID;
    if (!userId.length || !password.length || !bundleID.length) {
        failBlock(@"参数错误");
        return;
    }
    
    NSDictionary *params = @{@"username": userId,
                             @"password": password,
                             @"grantType": @"password"
    };
    
    [self loginWithParameters:params succeed:succeedBlock fail:failBlock];
}

- (void)loginWithParameters:(NSDictionary *)params
                    succeed:(void (^)(void))succeedBlock
                       fail:(void (^)(NSString * _Nullable))failBlock {
    
    if (self.isLogingIn) { return; }
    
    self.isLogingIn = YES;
    
    NSDictionary *header = [self buildAuthorityHeader];
    GrowingLoginRequest *loginRequest = [GrowingLoginRequest loginRequestWithHeader:header
                                                                          parameter:params];
    
    [GrowingNetworkManager.shareManager sendRequest:loginRequest
                                            success:^(NSHTTPURLResponse * _Nonnull httpResponse, NSData * _Nonnull data) {
        
        self.isLogingIn = NO;
        NSDictionary *token = [data growingHelper_jsonObject];
        self.token  = token[@"accessToken"];
        self.userId = token[@"userId"];
        self.loginToken = token[@"loginToken"];
        self.refreshToken = token[@"refreshToken"];
        self.userId = token[@"userId"];
        [[NSNotificationCenter defaultCenter] postNotificationName:GrowingDidLogin object:self];
        
        if (succeedBlock) { succeedBlock(); }
        
    } failure:^(NSHTTPURLResponse * _Nonnull httpResponse, NSData * _Nonnull data, NSError * _Nonnull error) {
        self.isLogingIn = NO;
        [self logout];
        NSString *errorMsg = [[data growingHelper_dictionaryObject] valueForKey:@"error"];
        if (errorMsg.length == 0 && error != nil) {
            errorMsg = [NSString stringWithFormat:@"%@ (%@, code=%ld)", error.localizedDescription, error.domain, (long)error.code];
        }
        if (errorMsg.length == 0) {
            errorMsg = [NSString stringWithFormat:@"未知错误 (%ld)", (long)httpResponse.statusCode];
        }
        if (failBlock) {
            failBlock(errorMsg);
        }
    }];
    
}

- (NSString *)tokenKey {
    return @"token";
}

- (NSString *)userId {
    if (!_userId) {
        NSString *key = [[self tokenKey] stringByAppendingString:@"_userid"];
        _userId = [[GrowingUserDefaults shareInstance] valueForKey:key];
    }
    return _userId;
}

- (void)setUserId:(NSString *)userId {
    _userId = [userId copy];
    NSString *key = [[self tokenKey] stringByAppendingString:@"_userid"];
    if (self.remindMe || userId == nil)
    {
        [[GrowingUserDefaults shareInstance] setValue:userId forKey:key];
    }
}

- (NSString*)token {
    if (!_token) {
        _token = [[GrowingUserDefaults shareInstance] valueForKey:[self tokenKey]];
    }
    return _token;
    return nil;
}

- (void)setToken:(NSString *)token {
    _token = [token copy];
    if (self.remindMe || token == nil) {
        [[GrowingUserDefaults shareInstance] setValue:token forKey:[self tokenKey]];
    }
}

- (NSString*)refreshToken {
    if (!_refreshToken) {
        _refreshToken = [[GrowingUserDefaults shareInstance] valueForKey:@"_refreshToken"];
    }
    return _refreshToken;
    return nil;
}

- (void)setRefreshToken:(NSString *)token {
    _refreshToken = [token copy];
    if (self.remindMe || token == nil) {
        [[GrowingUserDefaults shareInstance] setValue:token forKey:@"_refreshToken"];
    }
}


@end
