//
// GrowingOSLogger.h
// Pods
//
//  Created by YoloMao on 2021/8/10.
//  Copyright (C) 2017 Beijing Yishu Technology Co., Ltd.
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

#import <Foundation/Foundation.h>

// Disable legacy macros
#ifndef Growing_LEGACY_MACROS
    #define Growing_LEGACY_MACROS 0
#endif

#import "GrowingLog.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * This class provides a logger for the Apple os_log facility.
 **/
API_AVAILABLE(macos(10.12), ios(10.0), watchos(3.0), tvos(10.0))
@interface GrowingOSLogger : GrowingAbstractLogger <GrowingLogger>

/**
 *  Singleton method
 *
 *  @return the shared instance with OS_LOG_DEFAULT.
 */
@property (nonatomic, class, readonly, strong) GrowingOSLogger *sharedInstance;

/**
 Designated initializer
 
 @param subsystem Desired subsystem in log. E.g. "org.example"
 @param category Desired category in log. E.g. "Point of interests."
 @return New instance of GrowingOSLogger.
 
 @discussion This method requires either both or no parameter to be set. Much like `(String, String)?` in Swift.
 If both parameters are nil, this method will return a logger configured with `OS_LOG_DEFAULT`.
 If both parameters are non-nil, it will return a logger configured with `os_log_create(subsystem, category)`
 */
- (instancetype)initWithSubsystem:(nullable NSString *)subsystem category:(nullable NSString *)category NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
