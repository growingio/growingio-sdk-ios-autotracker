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

/**
 * The constant/variable/method responsible for controlling the current log level.
 **/
#ifndef GIO_LOG_LEVEL_DEF
    #define GIO_LOG_LEVEL_DEF gioLogLevel
#endif

/**
 * Whether async should be used by log messages, excluding error messages that are always sent sync.
 **/
#ifndef LOG_ASYNC_ENABLED
    #define LOG_ASYNC_ENABLED YES
#endif

/**
 * These are the two macros that all other macros below compile into.
 * These big multiline macros makes all the other macros easier to read.
 **/
#define GIO_LOG_MACRO(isAsynchronous, lvl, flg, ctx, atag, fnct, frmt, ...) \
        [GrowingLog log : isAsynchronous                                     \
             level : lvl                                                \
              flag : flg                                                \
           context : ctx                                                \
              file : __FILE__                                           \
          function : fnct                                               \
              line : __LINE__                                           \
               tag : atag                                               \
            format : (frmt), ## __VA_ARGS__]
/**
 * Define version of the macro that only execute if the log level is above the threshold.
 * The compiled versions essentially look like this:
 *
 * if (logFlagForThisLogMsg & gioLogLevel) { execute log message }
 *
 * When LOG_LEVEL_DEF is defined as gioLogLevel.
 *
 * As shown further below, Lumberjack actually uses a bitmask as opposed to primitive log levels.
 * This allows for a great amount of flexibility and some pretty advanced fine grained logging techniques.
 *
 * Note that when compiler optimizations are enabled (as they are for your release builds),
 * the log messages above your logging threshold will automatically be compiled out.
 *
 * (If the compiler sees LOG_LEVEL_DEF/gioLogLevel declared as a constant, the compiler simply checks to see
 *  if the 'if' statement would execute, and if not it strips it from the binary.)
 *
 * We also define shorthand versions for asynchronous and synchronous logging.
 **/
#define GIO_LOG_MAYBE(async, lvl, flg, ctx, tag, fnct, frmt, ...) \
        do { if(lvl & flg) GIO_LOG_MACRO(async, lvl, flg, ctx, tag, fnct, frmt, ##__VA_ARGS__); } while(0)

/**
 * Ready to use log macros with no context or tag.
 **/
#define GIOLogError(frmt, ...)   GIO_LOG_MAYBE(LOG_ASYNC_ENABLED, GIO_LOG_LEVEL_DEF, GrowingLogFlagError,   0, nil, __PRETTY_FUNCTION__, frmt, ##__VA_ARGS__)
#define GIOLogWarn(frmt, ...)    GIO_LOG_MAYBE(LOG_ASYNC_ENABLED, GIO_LOG_LEVEL_DEF, GrowingLogFlagWarning, 0, nil, __PRETTY_FUNCTION__, frmt, ##__VA_ARGS__)
#define GIOLogInfo(frmt, ...)    GIO_LOG_MAYBE(LOG_ASYNC_ENABLED, GIO_LOG_LEVEL_DEF, GrowingLogFlagInfo,    0, nil, __PRETTY_FUNCTION__, frmt, ##__VA_ARGS__)
#define GIOLogDebug(frmt, ...)   GIO_LOG_MAYBE(LOG_ASYNC_ENABLED, GIO_LOG_LEVEL_DEF, GrowingLogFlagDebug,   0, nil, __PRETTY_FUNCTION__, frmt, ##__VA_ARGS__)
#define GIOLogVerbose(frmt, ...) GIO_LOG_MAYBE(LOG_ASYNC_ENABLED, GIO_LOG_LEVEL_DEF, GrowingLogFlagVerbose, 0, nil, __PRETTY_FUNCTION__, frmt, ##__VA_ARGS__)
