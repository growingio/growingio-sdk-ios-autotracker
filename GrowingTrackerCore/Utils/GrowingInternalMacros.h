//  Copyright (c) 2009-2020 Olivier Poitrey rs@dailymotion.com
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is furnished
//  to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//
//  GrowingInternalMacros.h
//  GrowingAnalytics
//
//  Created by YoloMao on 2023/5/17.
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

//  from https://github.com/SDWebImage/SDWebImage/blob/master/SDWebImage/Private/SDInternalMacros.h

#import <os/lock.h>
#import <libkern/OSAtomic.h>

#define GROWING_USE_OS_UNFAIR_LOCK TARGET_OS_MACCATALYST ||\
    (__IPHONE_OS_VERSION_MIN_REQUIRED >= __IPHONE_10_0) ||\
    (__MAC_OS_X_VERSION_MIN_REQUIRED >= __MAC_10_12) ||\
    (__TV_OS_VERSION_MIN_REQUIRED >= __TVOS_10_0) ||\
    (__WATCH_OS_VERSION_MIN_REQUIRED >= __WATCHOS_3_0)

#ifndef GROWING_LOCK_DECLARE
#if GROWING_USE_OS_UNFAIR_LOCK
#define GROWING_LOCK_DECLARE(lock) os_unfair_lock lock
#else
#define GROWING_LOCK_DECLARE(lock) os_unfair_lock lock API_AVAILABLE(ios(10.0), tvos(10), watchos(3), macos(10.12)); \
OSSpinLock lock##_deprecated;
#endif
#endif

#ifndef GROWING_LOCK_DECLARE_STATIC
#if GROWING_USE_OS_UNFAIR_LOCK
#define GROWING_LOCK_DECLARE_STATIC(lock) static os_unfair_lock lock
#else
#define GROWING_LOCK_DECLARE_STATIC(lock) static os_unfair_lock lock API_AVAILABLE(ios(10.0), tvos(10), watchos(3), macos(10.12)); \
static OSSpinLock lock##_deprecated;
#endif
#endif

#ifndef GROWING_LOCK_INIT
#if GROWING_USE_OS_UNFAIR_LOCK
#define GROWING_LOCK_INIT(lock) lock = OS_UNFAIR_LOCK_INIT
#else
#define GROWING_LOCK_INIT(lock) if (@available(iOS 10, tvOS 10, watchOS 3, macOS 10.12, *)) lock = OS_UNFAIR_LOCK_INIT; \
else lock##_deprecated = OS_SPINLOCK_INIT;
#endif
#endif

#ifndef GROWING_LOCK
#if GROWING_USE_OS_UNFAIR_LOCK
#define GROWING_LOCK(lock) os_unfair_lock_lock(&lock)
#else
#define GROWING_LOCK(lock) if (@available(iOS 10, tvOS 10, watchOS 3, macOS 10.12, *)) os_unfair_lock_lock(&lock); \
else OSSpinLockLock(&lock##_deprecated);
#endif
#endif

#ifndef GROWING_UNLOCK
#if GROWING_USE_OS_UNFAIR_LOCK
#define GROWING_UNLOCK(lock) os_unfair_lock_unlock(&lock)
#else
#define GROWING_UNLOCK(lock) if (@available(iOS 10, tvOS 10, watchOS 3, macOS 10.12, *)) os_unfair_lock_unlock(&lock); \
else OSSpinLockUnlock(&lock##_deprecated);
#endif
#endif
