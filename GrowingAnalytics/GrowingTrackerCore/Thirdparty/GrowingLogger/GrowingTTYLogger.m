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

#import "GrowingTTYLogger.h"

#import <sys/uio.h>

#if !__has_feature(objc_arc)
#error This file must be compiled with ARC. Use -fobjc-arc flag (or convert project to ARC).
#endif

// We probably shouldn't be using GrowingLog() statements within the GrowingLog implementation.
// But we still want to leave our log statements for any future debugging,
// and to allow other developers to trace the implementation (which is a great learning tool).
//
// So we use primitive logging macros around NSLog.
// We maintain the NS prefix on the macros to be explicit about the fact that we're using NSLog.

#ifndef Growing_NSLOG_LEVEL
    #define Growing_NSLOG_LEVEL 2
#endif

#define NSLogError(frmt, ...)    do{ if(Growing_NSLOG_LEVEL >= 1) NSLog((frmt), ##__VA_ARGS__); } while(0)
#define NSLogWarn(frmt, ...)     do{ if(Growing_NSLOG_LEVEL >= 2) NSLog((frmt), ##__VA_ARGS__); } while(0)
#define NSLogInfo(frmt, ...)     do{ if(Growing_NSLOG_LEVEL >= 3) NSLog((frmt), ##__VA_ARGS__); } while(0)
#define NSLogDebug(frmt, ...)    do{ if(Growing_NSLOG_LEVEL >= 4) NSLog((frmt), ##__VA_ARGS__); } while(0)
#define NSLogVerbose(frmt, ...)  do{ if(Growing_NSLOG_LEVEL >= 5) NSLog((frmt), ##__VA_ARGS__); } while(0)

// Xcode does NOT natively support colors in the Xcode debugging console.
// You'll need to install the XcodeColors plugin to see colors in the Xcode console.
// https://github.com/robbiehanson/XcodeColors
//
// The following is documentation from the XcodeColors project:
//
//
// How to apply color formatting to your log statements:
//
// To set the foreground color:
// Insert the ESCAPE_SEQ into your string, followed by "fg124,12,255;" where r=124, g=12, b=255.
//
// To set the background color:
// Insert the ESCAPE_SEQ into your string, followed by "bg12,24,36;" where r=12, g=24, b=36.
//
// To reset the foreground color (to default value):
// Insert the ESCAPE_SEQ into your string, followed by "fg;"
//
// To reset the background color (to default value):
// Insert the ESCAPE_SEQ into your string, followed by "bg;"
//
// To reset the foreground and background color (to default values) in one operation:
// Insert the ESCAPE_SEQ into your string, followed by ";"


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

@interface GrowingTTYLogger () {
    NSString *_appName;
    char *_app;
    size_t _appLen;
    
    NSString *_processID;
    char *_pid;
    size_t _pidLen;
    
}

@end


@implementation GrowingTTYLogger

static GrowingTTYLogger *sharedInstance;


+ (instancetype)sharedInstance {
    static dispatch_once_t GrowingTTYLoggerOnceToken;

    dispatch_once(&GrowingTTYLoggerOnceToken, ^{
        // Xcode does NOT natively support colors in the Xcode debugging console.
        // You'll need to install the XcodeColors plugin to see colors in the Xcode console.
        //
        // PS - Please read the header file before diving into the source code.

        sharedInstance = [[self alloc] init];
    });

    return sharedInstance;
}

- (instancetype)init {
    if (sharedInstance != nil) {
        return nil;
    }

    if (@available(iOS 10.0, macOS 10.12, tvOS 10.0, watchOS 3.0, *)) {
//        NSLogWarn(@"GrowingCocoaLumberjack: Warning: Usage of GrowingTTYLogger detected when GrowingOSLogger is available and can be used! Please consider migrating to GrowingOSLogger.");
    }

    if ((self = [super init])) {
        // Initialize 'app' variable (char *)

        _appName = [[NSProcessInfo processInfo] processName];

        _appLen = [_appName lengthOfBytesUsingEncoding:NSUTF8StringEncoding];

        if (_appLen == 0) {
            _appName = @"<UnnamedApp>";
            _appLen = [_appName lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
        }

        _app = (char *)calloc(_appLen + 1, sizeof(char));

        if (_app == NULL) {
            return nil;
        }

        BOOL processedAppName = [_appName getCString:_app maxLength:(_appLen + 1) encoding:NSUTF8StringEncoding];

        if (NO == processedAppName) {
            free(_app);
            return nil;
        }

        // Initialize 'pid' variable (char *)

        _processID = [NSString stringWithFormat:@"%i", (int)getpid()];

        _pidLen = [_processID lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
        _pid = (char *)calloc(_pidLen + 1, sizeof(char));

        if (_pid == NULL) {
            free(_app);
            return nil;
        }

        BOOL processedID = [_processID getCString:_pid maxLength:(_pidLen + 1) encoding:NSUTF8StringEncoding];

        if (NO == processedID) {
            free(_app);
            free(_pid);
            return nil;
        }
        _automaticallyAppendNewlineForCustomFormatters = YES;
    }

    return self;
}

- (GrowingLoggerName)loggerName {
    return GrowingLoggerNameTTY;
}

- (void)logMessage:(GrowingLogMessage *)logMessage {
    NSString *logMsg = logMessage->_message;
    BOOL isFormatted = NO;

    if (_logFormatter) {
        logMsg = [_logFormatter formatLogMessage:logMessage];
        isFormatted = logMsg != logMessage->_message;
    }

    if (logMsg) {
        // Search for a color profile associated with the log message
        // Convert log message to C string.
        //
        // We use the stack instead of the heap for speed if possible.
        // But we're extra cautious to avoid a stack overflow.

        NSUInteger msgLen = [logMsg lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
        const BOOL useStack = msgLen < (1024 * 4);

        char *msg;
        if (useStack) {
            msg = (char *)alloca(msgLen + 1);
        } else {
            msg = (char *)calloc(msgLen + 1, sizeof(char));
        }
        if (msg == NULL) {
            return;
        }

        BOOL logMsgEnc = [logMsg getCString:msg maxLength:(msgLen + 1) encoding:NSUTF8StringEncoding];
        if (!logMsgEnc) {
            if (!useStack) {
                free(msg);
            }

            return;
        }

        // Write the log message to STDERR

        if (isFormatted) {
            // The log message has already been formatted.
            const int iovec_len = (_automaticallyAppendNewlineForCustomFormatters) ? 5 : 4;
            struct iovec v[iovec_len];

            v[0].iov_base = "";
            v[0].iov_len = 0;

            v[1].iov_base = "";
            v[1].iov_len = 0;

            v[iovec_len - 1].iov_base = "";
            v[iovec_len - 1].iov_len = 0;

            v[2].iov_base = msg;
            v[2].iov_len = msgLen;

            if (iovec_len == 5) {
                v[3].iov_base = "\n";
                v[3].iov_len = (msg[msgLen] == '\n') ? 0 : 1;
            }

            writev(STDERR_FILENO, v, iovec_len);
        } else {
            // The log message is unformatted, so apply standard NSLog style formatting.

            int len;
            char ts[24] = "";
            size_t tsLen = 0;

            // Calculate timestamp.
            // The technique below is faster than using NSDateFormatter.
            if (logMessage->_timestamp) {
                NSTimeInterval epoch = [logMessage->_timestamp timeIntervalSince1970];
                struct tm tm;
                time_t time = (time_t)epoch;
                (void)localtime_r(&time, &tm);
                int milliseconds = (int)((epoch - floor(epoch)) * 1000.0);

                len = snprintf(ts, 24, "%04d-%02d-%02d %02d:%02d:%02d:%03d", // yyyy-MM-dd HH:mm:ss:SSS
                               tm.tm_year + 1900,
                               tm.tm_mon + 1,
                               tm.tm_mday,
                               tm.tm_hour,
                               tm.tm_min,
                               tm.tm_sec, milliseconds);

                tsLen = (NSUInteger)MAX(MIN(24 - 1, len), 0);
            }

            // Calculate thread ID
            //
            // How many characters do we need for the thread id?
            // logMessage->machThreadID is of type mach_port_t, which is an unsigned int.
            //
            // 1 hex char = 4 bits
            // 8 hex chars for 32 bit, plus ending '\0' = 9

            char tid[9];
            len = snprintf(tid, 9, "%s", [logMessage->_threadID cStringUsingEncoding:NSUTF8StringEncoding]);

            size_t tidLen = (NSUInteger)MAX(MIN(9 - 1, len), 0);

            // Here is our format: "%s %s[%i:%s] %s", timestamp, appName, processID, threadID, logMsg

            struct iovec v[13];

            v[0].iov_base = "";
            v[0].iov_len = 0;

            v[1].iov_base = "";
            v[1].iov_len = 0;

            v[12].iov_base = "";
            v[12].iov_len = 0;

            v[2].iov_base = ts;
            v[2].iov_len = tsLen;

            v[3].iov_base = " ";
            v[3].iov_len = 1;

            v[4].iov_base = _app;
            v[4].iov_len = _appLen;

            v[5].iov_base = "[";
            v[5].iov_len = 1;

            v[6].iov_base = _pid;
            v[6].iov_len = _pidLen;

            v[7].iov_base = ":";
            v[7].iov_len = 1;

            v[8].iov_base = tid;
            v[8].iov_len = MIN((size_t)8, tidLen); // snprintf doesn't return what you might think

            v[9].iov_base = "] ";
            v[9].iov_len = 2;

            v[10].iov_base = (char *)msg;
            v[10].iov_len = msgLen;

            v[11].iov_base = "\n";
            v[11].iov_len = (msg[msgLen] == '\n') ? 0 : 1;

            writev(STDERR_FILENO, v, 13);
        }

        if (!useStack) {
            free(msg);
        }
    }
}

@end

