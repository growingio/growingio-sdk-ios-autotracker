//
//  GrowingLoginModel.m
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


#import "GrowingLoginModel.h"
#import "GrowingInstance.h"
#import "NSData+GrowingHelper.h"
#import "GrowingUserDefaults.h"
#import "GrowingDeviceInfo.h"
#import "GrowingLoginMenu.h"
#import "GrowingCocoaLumberjack.h"

NSString *GrowingDidLogin = @"GrowingDidLogin";
NSString *GrowingDidLogout = @"GrowingDidLogout";

@interface GrowingLoginModel()
@property (nonatomic, readwrite) NSString * _Nullable userId;
@property (nonatomic, readwrite) NSString * _Nullable token;
@property (nonatomic, readwrite) NSString * _Nullable loginToken;
@property (nonatomic, readwrite) NSString * _Nullable refreshToken;
@property (nonatomic, assign) BOOL isLogingIn;
@property (nonatomic, assign) BOOL remindMe;
@end

@implementation GrowingLoginModel

@synthesize token = _token;
@synthesize userId = _userId;
@synthesize refreshToken = _refreshToken;

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        self.remindMe = YES;
        self.isLogingIn = NO;
    }
    return self;
}

- (void)authorityVerification:(NSMutableURLRequest *)request
{
    switch (self.modelType) {
        case GrowingModelTypeSDKCircle:
        {
            if ([GrowingLoginModel sdkInstance].token)
            {
                [request setValue:[GrowingLoginModel sdkInstance].token
               forHTTPHeaderField:@"token"];
            }
            NSString *ai = [GrowingInstance sharedInstance].projectID;
            if (ai.length)
            {
                [request setValue:ai forHTTPHeaderField:@"accountId"];
            }
        }
            break;
        default:
            break;
    }
}

- (BOOL)authorityErrorHandle:(void (^)(BOOL))finishBlock
{
    switch (self.modelType)
    {
        case GrowingModelTypeSDKCircle:
        {
            [GrowingLoginMenu showWithSucceed:^{
                finishBlock(YES);
            } fail:^{
                [[GrowingLoginModel sdkInstance] logout];
                finishBlock(NO);
            }];
        }
            return YES;
        default:
            finishBlock = nil;
            return NO;
    }
}

- (BOOL)isLogin
{
    return self.token.length != 0;
}

- (void)logout
{
    self.token = nil;
    self.userId = nil;
    [[NSNotificationCenter defaultCenter] postNotificationName:GrowingDidLogout object:self];
}

- (void)loginWithToken:(NSString*)aToken
{
    [self loginWithToken:aToken andUserId:@""];
}

- (void)loginWithToken:(NSString*)aToken andUserId:(NSString*)userId
{
    self.token  = aToken;
    self.userId = userId;
    [[NSNotificationCenter defaultCenter] postNotificationName:GrowingDidLogin object:self];
}

- (void)loginWithLoginToken:(NSString*)aToken success:(void (^)(void))successBlock failure:(void (^)(NSString * _Nullable))failBlock
{
    if (aToken.length == 0)
    {
        return;
    }
    else
    {
        NSDictionary *params = @{@"grantType":@"login_token",
                                 @"loginToken":aToken};
        [self loginWithURL:kGrowingLoginApiV2
                parameters:params
                   succeed:^() {
                       GIOLogDebug(@"Activated from GrowingIO App");
                       if (successBlock != nil)
                       {
                           successBlock();
                       }
                   }
                      fail:^(NSString * _Nullable errorMessage) {
                          if (failBlock != nil)
                          {
                              failBlock(errorMessage);
                          }
                      }];
    }
}

- (void)refreshLoginToken:(void (^)(BOOL success))finalBlock
{
    if (self.refreshToken.length == 0)
    {
        if (finalBlock != nil)
        {
            finalBlock(NO);
        }
    }
    else
    {
        NSDictionary *params = @{@"grantType":@"refresh_token",
                                 @"refreshToken":self.refreshToken};
        [self loginWithURL:kGrowingLoginApiV2
                parameters:params
                   succeed:^{
                       if (finalBlock != nil)
                       {
                           finalBlock(YES);
                       }
                   }
                      fail:^(NSString * _Nullable errorMessage) {
                          if (finalBlock != nil)
                          {
                              finalBlock(NO);
                          }
                      }];
    }
}

- (void)loginByUserId:(NSString *)userId
             password:(NSString *)password
              succeed:(void (^)(void))succeedBlock
                 fail:(void (^)(NSString * _Nullable))failBlock
{
    NSString *bundleID = [GrowingDeviceInfo currentDeviceInfo].bundleID;
    if (!userId.length || !password.length || !bundleID.length)
    {
        failBlock(@"参数错误");
        return;
    }
    
    NSDictionary *params = nil;
    NSString * loginUrl = nil;
    /*
    if (self.modelType == GrowingModelTypeSDKCircle)
    {
        NSString *apiKey = [GrowingInstance sharedInstance].accountID;
        if (!apiKey.length)
        {
            failBlock(@"sdk未加载");
            return;
        }
        params = @{@"email": userId,
                   @"password": password,
                   @"accountId": apiKey,
                   @"spn":bundleID
                   };
        loginUrl = kGrowingLoginApi;
    }
    else
     */
    // all logins go to login v2 interface
    {
        params = @{@"username": userId,
                   @"password": password,
                   @"grantType": @"password"
                   };
        loginUrl = kGrowingLoginApiV2;
    }
    
    [self loginWithURL:loginUrl parameters:params succeed:succeedBlock fail:failBlock];
}

- (void)loginWithURL:(NSString *)loginUrl
          parameters:(NSDictionary *)params
             succeed:(void (^)(void))succeedBlock
                fail:(void (^)(NSString * _Nullable))failBlock
{
    __weak GrowingLoginModel *wself = self;
    if (self.isLogingIn)
    {
        return;
    }
    self.isLogingIn = YES;
    [self startTaskWithURL:loginUrl
                httpMethod:@"POST"
                parameters:params
                   success:^(NSHTTPURLResponse *httpResponse, NSData *data) {
                       self.isLogingIn = NO;
                       NSDictionary *token = [data growingHelper_jsonObject];
                       self.token  = token[@"accessToken"];
                       self.userId = token[@"userId"];
                       self.loginToken = token[@"loginToken"];
                       self.refreshToken = token[@"refreshToken"];
                       self.userId = token[@"userId"];
                       [[NSNotificationCenter defaultCenter] postNotificationName:GrowingDidLogin object:self];
                       if (succeedBlock)
                       {
                           succeedBlock();
                       }
                   }
                   failure:^(NSHTTPURLResponse *httpResponse, NSData *data, NSError *error) {
                       self.isLogingIn = NO;
                       [wself logout];
                       NSString *errorMsg = [[data growingHelper_dictionaryObject] valueForKey:@"error"];
                       if (errorMsg.length == 0 && error != nil)
                       {
                           errorMsg = [NSString stringWithFormat:@"%@ (%@, code=%ld)", error.localizedDescription, error.domain, (long)error.code];
                       }
                       if (errorMsg.length == 0)
                       {
                           errorMsg = [NSString stringWithFormat:@"未知错误 (%ld)", (long)httpResponse.statusCode];
                       }
                       if (failBlock)
                       {
                           failBlock(errorMsg);
                       }
                   }];
}

- (NSString*)tokenKey
{
    if (self.modelType == GrowingModelTypeSDKCircle)
    {
        return @"token";
    }
    else
    {
        return @"app_token";
    }
}

- (NSString*)userId
{
    if (!_userId)
    {
        NSString *key = [[self tokenKey] stringByAppendingString:@"_userid"];
        _userId = [[GrowingUserDefaults shareInstance] valueForKey:key];
    }
    return _userId;
}

- (void)setUserId:(NSString *)userId
{
    _userId = [userId copy];
    NSString *key = [[self tokenKey] stringByAppendingString:@"_userid"];
    if (self.remindMe || userId == nil)
    {
        [[GrowingUserDefaults shareInstance] setValue:userId forKey:key];
    }
}

- (NSString*)token
{
    if (!_token)
    {
        _token = [[GrowingUserDefaults shareInstance] valueForKey:[self tokenKey]];
    }
    return _token;
}

- (void)setToken:(NSString *)token
{
    _token = [token copy];
    if (self.remindMe || token == nil)
    {
        [[GrowingUserDefaults shareInstance] setValue:token forKey:[self tokenKey]];
    }
}

- (NSString*)refreshToken
{
    if (!_refreshToken)
    {
        _refreshToken = [[GrowingUserDefaults shareInstance] valueForKey:@"_refreshToken"];
    }
    return _refreshToken;
}

- (void)setRefreshToken:(NSString *)token
{
    _refreshToken = [token copy];
    if (self.remindMe || token == nil)
    {
        [[GrowingUserDefaults shareInstance] setValue:token forKey:@"_refreshToken"];
    }
}


@end
