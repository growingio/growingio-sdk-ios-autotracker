//
//  FIRApp.m
//  GrowingAnalytics
//
//  Created by YoloMao on 2022/5/23.
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

#import "FIRApp.h"

@implementation FIRApp

+ (void)configure {
    
}

+ (void)configureWithOptions:(FIROptions *)options NS_SWIFT_NAME(configure(options:)) {
    
}

+ (void)configureWithName:(NSString *)name
                  options:(FIROptions *)options NS_SWIFT_NAME(configure(name:options:)) {
    
}

+ (nullable FIRApp *)defaultApp NS_SWIFT_NAME(app()) {
    return nil;
}

+ (nullable FIRApp *)appNamed:(NSString *)name NS_SWIFT_NAME(app(name:)) {
    return nil;
}

+ (nullable NSDictionary<NSString *, FIRApp *> *)allApps {
    return nil;
}

- (void)deleteApp:(void (^)(BOOL success))completion {
    
}

@end
