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

// Disable legacy macros
#ifndef Growing_LEGACY_MACROS
    #define Growing_LEGACY_MACROS 0
#endif

#import "GrowingTrackerCore/Thirdparty/Logger/GrowingLog.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * This class provides a logger for Terminal output or Xcode console output,
 * depending on where you are running your code.
 *
 * As described in the "Getting Started" page,
 * the traditional NSLog() function directs it's output to two places:
 *
 * - Apple System Log (so it shows up in Console.app)
 * - StdErr (if stderr is a TTY, so log statements show up in Xcode console)
 *
 * To duplicate NSLog() functionality you can simply add this logger and an asl logger.
 * However, if you instead choose to use file logging (for faster performance),
 * you may choose to use only a file logger and a tty logger.
 **/
@interface GrowingTTYLogger : GrowingAbstractLogger <GrowingLogger>

/**
 *  Singleton instance. Returns `nil` if the initialization of the GrowingTTYLogger fails.
 */
@property (nonatomic, class, readonly, strong) GrowingTTYLogger *sharedInstance;

/* Inherited from the GrowingLogger protocol:
 *
 * Formatters may optionally be added to any logger.
 *
 * If no formatter is set, the logger simply logs the message as it is given in logMessage,
 * or it may use its own built in formatting style.
 *
 * More information about formatters can be found here:
 * Documentation/CustomFormatters.md
 *
 * The actual implementation of these methods is inherited from GrowingAbstractLogger.

   - (id <GrowingLogFormatter>)logFormatter;
   - (void)setLogFormatter:(id <GrowingLogFormatter>)formatter;

 */
/**
 * When using a custom formatter you can set the `logMessage` method not to append
 * `\n` character after each output. This allows for some greater flexibility with
 * custom formatters. Default value is YES.
 **/
@property (nonatomic, readwrite, assign) BOOL automaticallyAppendNewlineForCustomFormatters;

/**
 Using this initializer is not supported. Please use `GrowingTTYLogger.sharedInstance`.
 **/
- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
