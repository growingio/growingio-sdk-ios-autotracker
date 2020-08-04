// Software License Agreement (BSD License)
//
// Copyright (c) 2010-2020, Deusty, LLC
// All rights reserved.
//
// Redistribution and use of this software in source and binary forms,
// with or without modification, are permitted provided that the following conditions are met:
//
// * Redistributions of source code must retain the above copyright notice,
//   this list of conditions and the following disclaimer.
//
// * Neither the name of Deusty nor the names of its contributors may be used
//   to endorse or promote products derived from this software without specific
//   prior written permission of Deusty, LLC.

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NSString *GrowingLoggerName NS_TYPED_EXTENSIBLE_ENUM;

FOUNDATION_EXPORT GrowingLoggerName const GrowingLoggerNameOS NS_SWIFT_NAME(GrowingLoggerName.os); // GrowingOSLogger
FOUNDATION_EXPORT GrowingLoggerName const GrowingLoggerNameFile NS_SWIFT_NAME(GrowingLoggerName.file); // GrowingFileLogger

FOUNDATION_EXPORT GrowingLoggerName const GrowingLoggerNameTTY NS_SWIFT_NAME(GrowingLoggerName.tty); // GrowingTTYLogger

API_DEPRECATED("Use GrowingOSLogger instead", macosx(10.4, 10.12), ios(2.0, 10.0), watchos(2.0, 3.0), tvos(9.0, 10.0))
FOUNDATION_EXPORT GrowingLoggerName const GrowingLoggerNameASL NS_SWIFT_NAME(GrowingLoggerName.asl); // GrowingASLLogger

FOUNDATION_EXPORT GrowingLoggerName const GrowingLoggerNameWS NS_SWIFT_NAME(GrowingLoggerName.ws); // GrowingWSLogger

NS_ASSUME_NONNULL_END
