// Software License Agreement (BSD License)
//
// Copyright (c) 2010-2020, Deusty, LLC
// All rights reserved.
//
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

#import <pthread.h>
#import <objc/runtime.h>
#import <sys/qos.h>

#if TARGET_OS_IOS
    #import <UIKit/UIDevice.h>
    #import <UIKit/UIApplication.h>
#elif !defined(Growing_CLI) && __has_include(<AppKit/NSApplication.h>)
    #import <AppKit/NSApplication.h>
#endif


#if !__has_feature(objc_arc)
#error This file must be compiled with ARC. Use -fobjc-arc flag (or convert project to ARC).
#endif

// We probably shouldn't be using GrowingLog() statements within the GrowingLog implementation.
// But we still want to leave our log statements for any future debugging,
// and to allow other developers to trace the implementation (which is a great learning tool).
//
// So we use a primitive logging macro around NSLog.
// We maintain the NS prefix on the macros to be explicit about the fact that we're using NSLog.

#ifndef Growing_DEBUG
    #define Growing_DEBUG 0
#endif

#define NSLogDebug(frmt, ...) do{ if(Growing_DEBUG) NSLog((frmt), ##__VA_ARGS__); } while(0)

// The "global logging queue" refers to [GrowingLog loggingQueue].
// It is the queue that all log statements go through.
//
// The logging queue sets a flag via dispatch_queue_set_specific using this key.
// We can check for this key via dispatch_get_specific() to see if we're on the "global logging queue".

static void *const GlobalLoggingQueueIdentityKey = (void *)&GlobalLoggingQueueIdentityKey;

@interface GrowingLoggerNode : NSObject
{
    // Direct accessors to be used only for performance
    @public
    id <GrowingLogger> _logger;
    GrowingLogLevel _level;
    dispatch_queue_t _loggerQueue;
}

@property (nonatomic, readonly) id <GrowingLogger> logger;
@property (nonatomic, readonly) GrowingLogLevel level;
@property (nonatomic, readonly) dispatch_queue_t loggerQueue;

+ (instancetype)nodeWithLogger:(id <GrowingLogger>)logger
                   loggerQueue:(dispatch_queue_t)loggerQueue
                         level:(GrowingLogLevel)level;

@end


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

@interface GrowingLog ()

// An array used to manage all the individual loggers.
// The array is only modified on the loggingQueue/loggingThread.
@property (nonatomic, strong) NSMutableArray *_loggers;

@end

@implementation GrowingLog

// All logging statements are added to the same queue to ensure FIFO operation.
static dispatch_queue_t _loggingQueue;

// Individual loggers are executed concurrently per log statement.
// Each logger has it's own associated queue, and a dispatch group is used for synchronization.
static dispatch_group_t _loggingGroup;

// Minor optimization for uniprocessor machines
static NSUInteger _numProcessors;

/**
 *  Returns the singleton `GrowingLog`.
 *  The instance is used by `GrowingLog` class methods.
 *
 *  @return The singleton `GrowingLog`.
 */
+ (instancetype)sharedInstance {
    static id sharedInstance = nil;

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });

    return sharedInstance;
}

/**
 * The runtime sends initialize to each class in a program exactly one time just before the class,
 * or any class that inherits from it, is sent its first message from within the program. (Thus the
 * method may never be invoked if the class is not used.) The runtime sends the initialize message to
 * classes in a thread-safe manner. Superclasses receive this message before their subclasses.
 *
 * This method may also be called directly, hence the safety mechanism.
 **/
+ (void)initialize {
    static dispatch_once_t GrowingLogOnceToken;

    dispatch_once(&GrowingLogOnceToken, ^{
        NSLogDebug(@"GrowingLog: Using grand central dispatch");

        _loggingQueue = dispatch_queue_create("growing.cocoaLumberjack", NULL);
        _loggingGroup = dispatch_group_create();

        void *nonNullValue = GlobalLoggingQueueIdentityKey; // Whatever, just not null
        dispatch_queue_set_specific(_loggingQueue, GlobalLoggingQueueIdentityKey, nonNullValue, NULL);

        // Figure out how many processors are available.
        // This may be used later for an optimization on uniprocessor machines.

        _numProcessors = MAX([NSProcessInfo processInfo].processorCount, (NSUInteger) 1);

        NSLogDebug(@"GrowingLog: numProcessors = %@", @(_numProcessors));
    });
}

/**
 *  The `GrowingLog` initializer.
 *  Static variables are set only once.
 *
 *  @return An initialized `GrowingLog` instance.
 */
- (instancetype)init {
    self = [super init];

    if (self) {
        self._loggers = [[NSMutableArray alloc] initWithCapacity:4];

#if TARGET_OS_IOS
        NSString *notificationName = UIApplicationWillTerminateNotification;
#else
        NSString *notificationName = nil;

        // On Command Line Tool apps AppKit may not be available
#if !defined(Growing_CLI) && __has_include(<AppKit/NSApplication.h>)
        if (NSApp) {
            notificationName = NSApplicationWillTerminateNotification;
        }
#endif

        if (!notificationName) {
            // If there is no NSApp -> we are running Command Line Tool app.
            // In this case terminate notification wouldn't be fired, so we use workaround.
            __weak __auto_type weakSelf = self;
            atexit_b (^{
                [weakSelf applicationWillTerminate:nil];
            });
        }

#endif /* if TARGET_OS_IOS */

        if (notificationName) {
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(applicationWillTerminate:)
                                                         name:notificationName
                                                       object:nil];
        }
    }

    return self;
}

/**
 * Provides access to the logging queue.
 **/
+ (dispatch_queue_t)loggingQueue {
    return _loggingQueue;
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Notifications
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)applicationWillTerminate:(NSNotification * __attribute__((unused)))notification {
    [self flushLog];
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Logger Management
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

+ (void)addLogger:(id <GrowingLogger>)logger {
    [self.sharedInstance addLogger:logger];
}

- (void)addLogger:(id <GrowingLogger>)logger {
    [self addLogger:logger withLevel:GrowingLogLevelAll]; // GrowingLogLevelAll has all bits set
}

+ (void)addLogger:(id <GrowingLogger>)logger withLevel:(GrowingLogLevel)level {
    [self.sharedInstance addLogger:logger withLevel:level];
}

- (void)addLogger:(id <GrowingLogger>)logger withLevel:(GrowingLogLevel)level {
    if (!logger) {
        return;
    }

    dispatch_async(_loggingQueue, ^{ @autoreleasepool {
        [self lt_addLogger:logger level:level];
    } });
}

+ (void)removeLogger:(id <GrowingLogger>)logger {
    [self.sharedInstance removeLogger:logger];
}

- (void)removeLogger:(id <GrowingLogger>)logger {
    if (!logger) {
        return;
    }

    dispatch_async(_loggingQueue, ^{ @autoreleasepool {
        [self lt_removeLogger:logger];
    } });
}

+ (void)removeAllLoggers {
    [self.sharedInstance removeAllLoggers];
}

- (void)removeAllLoggers {
    dispatch_async(_loggingQueue, ^{ @autoreleasepool {
        [self lt_removeAllLoggers];
    } });
}

+ (NSArray<id<GrowingLogger>> *)allLoggers {
    return [self.sharedInstance allLoggers];
}

- (NSArray<id<GrowingLogger>> *)allLoggers {
    __block NSArray *theLoggers;

    dispatch_sync(_loggingQueue, ^{ @autoreleasepool {
        theLoggers = [self lt_allLoggers];
    } });

    return theLoggers;
}

+ (NSArray<GrowingLoggerInformation *> *)allLoggersWithLevel {
    return [self.sharedInstance allLoggersWithLevel];
}

- (NSArray<GrowingLoggerInformation *> *)allLoggersWithLevel {
    __block NSArray *theLoggersWithLevel;

    dispatch_sync(_loggingQueue, ^{ @autoreleasepool {
        theLoggersWithLevel = [self lt_allLoggersWithLevel];
    } });

    return theLoggersWithLevel;
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Master Logging
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)queueLogMessage:(GrowingLogMessage *)logMessage asynchronously:(BOOL)asyncFlag {
    // We have a tricky situation here...
    //
    // In the common case, when the queueSize is below the maximumQueueSize,
    // we want to simply enqueue the logMessage. And we want to do this as fast as possible,
    // which means we don't want to block and we don't want to use any locks.
    //
    // However, if the queueSize gets too big, we want to block.
    // But we have very strict requirements as to when we block, and how long we block.
    //
    // The following example should help illustrate our requirements:
    //
    // Imagine that the maximum queue size is configured to be 5,
    // and that there are already 5 log messages queued.
    // Let us call these 5 queued log messages A, B, C, D, and E. (A is next to be executed)
    //
    // Now if our thread issues a log statement (let us call the log message F),
    // it should block before the message is added to the queue.
    // Furthermore, it should be unblocked immediately after A has been unqueued.
    //
    // The requirements are strict in this manner so that we block only as long as necessary,
    // and so that blocked threads are unblocked in the order in which they were blocked.
    //
    // Returning to our previous example, let us assume that log messages A through E are still queued.
    // Our aforementioned thread is blocked attempting to queue log message F.
    // Now assume we have another separate thread that attempts to issue log message G.
    // It should block until log messages A and B have been unqueued.


    dispatch_block_t logBlock = ^{
        // We're now sure we won't overflow the queue.
        // It is time to queue our log message.
        @autoreleasepool {
            [self lt_log:logMessage];
        }
    };

    if (asyncFlag) {
        dispatch_async(_loggingQueue, logBlock);
    } else if (dispatch_get_specific(GlobalLoggingQueueIdentityKey)) {
        // We've logged an error message while on the logging queue...
        logBlock();
    } else {
        dispatch_sync(_loggingQueue, logBlock);
    }
}

+ (void)log:(BOOL)asynchronous
      level:(GrowingLogLevel)level
       flag:(GrowingLogFlag)flag
    context:(NSInteger)context
       file:(const char *)file
   function:(const char *)function
       line:(NSUInteger)line
        tag:(id)tag
     format:(NSString *)format, ... {
    va_list args;

    if (format) {
        va_start(args, format);

        NSString *message = [[NSString alloc] initWithFormat:format arguments:args];

        va_end(args);

        va_start(args, format);

        [self log:asynchronous
          message:message
            level:level
             flag:flag
          context:context
             file:file
         function:function
             line:line
              tag:tag];

        va_end(args);
    }
}

- (void)log:(BOOL)asynchronous
      level:(GrowingLogLevel)level
       flag:(GrowingLogFlag)flag
    context:(NSInteger)context
       file:(const char *)file
   function:(const char *)function
       line:(NSUInteger)line
        tag:(id)tag
     format:(NSString *)format, ... {
    va_list args;

    if (format) {
        va_start(args, format);

        NSString *message = [[NSString alloc] initWithFormat:format arguments:args];

        va_end(args);

        va_start(args, format);

        [self log:asynchronous
          message:message
            level:level
             flag:flag
          context:context
             file:file
         function:function
             line:line
              tag:tag];

        va_end(args);
    }
}

+ (void)log:(BOOL)asynchronous
      level:(GrowingLogLevel)level
       flag:(GrowingLogFlag)flag
    context:(NSInteger)context
       file:(const char *)file
   function:(const char *)function
       line:(NSUInteger)line
        tag:(id)tag
     format:(NSString *)format
       args:(va_list)args {
    [self.sharedInstance log:asynchronous level:level flag:flag context:context file:file function:function line:line tag:tag format:format args:args];
}

- (void)log:(BOOL)asynchronous
      level:(GrowingLogLevel)level
       flag:(GrowingLogFlag)flag
    context:(NSInteger)context
       file:(const char *)file
   function:(const char *)function
       line:(NSUInteger)line
        tag:(id)tag
     format:(NSString *)format
       args:(va_list)args {
    if (format) {
        NSString *message = [[NSString alloc] initWithFormat:format arguments:args];
        [self log:asynchronous
          message:message
            level:level
             flag:flag
          context:context
             file:file
         function:function
             line:line
              tag:tag];
    }
}

+ (void)log:(BOOL)asynchronous
    message:(NSString *)message
      level:(GrowingLogLevel)level
       flag:(GrowingLogFlag)flag
    context:(NSInteger)context
       file:(const char *)file
   function:(const char *)function
       line:(NSUInteger)line
        tag:(id)tag {
    [self.sharedInstance log:asynchronous message:message level:level flag:flag context:context file:file function:function line:line tag:tag];
}

- (void)log:(BOOL)asynchronous
    message:(NSString *)message
      level:(GrowingLogLevel)level
       flag:(GrowingLogFlag)flag
    context:(NSInteger)context
       file:(const char *)file
   function:(const char *)function
       line:(NSUInteger)line
        tag:(id)tag {
    GrowingLogMessage *logMessage = [[GrowingLogMessage alloc] initWithMessage:[NSString stringWithFormat:@"[GrowingAnalytics] %@", message]
                                                               level:level
                                                                flag:flag
                                                             context:context
                                                                file:[NSString stringWithFormat:@"%s", file]
                                                            function:[NSString stringWithFormat:@"%s", function]
                                                                line:line
                                                                 tag:tag
                                                             options:(GrowingLogMessageOptions)0
                                                           timestamp:nil];

    [self queueLogMessage:logMessage asynchronously:asynchronous];
}

+ (void)log:(BOOL)asynchronous message:(GrowingLogMessage *)logMessage {
    [self.sharedInstance log:asynchronous message:logMessage];
}

- (void)log:(BOOL)asynchronous message:(GrowingLogMessage *)logMessage {
    [self queueLogMessage:logMessage asynchronously:asynchronous];
}

+ (void)flushLog {
    [self.sharedInstance flushLog];
}

- (void)flushLog {
    dispatch_sync(_loggingQueue, ^{ @autoreleasepool {
        [self lt_flush];
    } });
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Registered Dynamic Logging
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

+ (BOOL)isRegisteredClass:(Class)class {
    SEL getterSel = @selector(gioLogLevel);
    SEL setterSel = @selector(gioSetLogLevel:);

#if TARGET_OS_IPHONE && !TARGET_OS_SIMULATOR

    // Issue #6 (GoogleCode) - Crashes on iOS 4.2.1 and iPhone 4
    //
    // Crash caused by class_getClassMethod(2).
    //
    //     "It's a bug with UIAccessibilitySafeCategory__NSObject so it didn't pop up until
    //      users had VoiceOver enabled [...]. I was able to work around it by searching the
    //      result of class_copyMethodList() instead of calling class_getClassMethod()"

    BOOL result = NO;

    unsigned int methodCount, i;
    Method *methodList = class_copyMethodList(object_getClass(class), &methodCount);

    if (methodList != NULL) {
        BOOL getterFound = NO;
        BOOL setterFound = NO;

        for (i = 0; i < methodCount; ++i) {
            SEL currentSel = method_getName(methodList[i]);

            if (currentSel == getterSel) {
                getterFound = YES;
            } else if (currentSel == setterSel) {
                setterFound = YES;
            }

            if (getterFound && setterFound) {
                result = YES;
                break;
            }
        }

        free(methodList);
    }

    return result;

#else /* if TARGET_OS_IPHONE && !TARGET_OS_SIMULATOR */

    // Issue #24 (GitHub) - Crashing in in ARC+Simulator
    //
    // The method +[GrowingLog isRegisteredClass] will crash a project when using it with ARC + Simulator.
    // For running in the Simulator, it needs to execute the non-iOS code.

    Method getter = class_getClassMethod(class, getterSel);
    Method setter = class_getClassMethod(class, setterSel);

    if ((getter != NULL) && (setter != NULL)) {
        return YES;
    }

    return NO;

#endif /* if TARGET_OS_IPHONE && !TARGET_OS_SIMULATOR */
}

+ (NSArray *)registeredClasses {

    // We're going to get the list of all registered classes.
    // The Objective-C runtime library automatically registers all the classes defined in your source code.
    //
    // To do this we use the following method (documented in the Objective-C Runtime Reference):
    //
    // int objc_getClassList(Class *buffer, int bufferLen)
    //
    // We can pass (NULL, 0) to obtain the total number of
    // registered class definitions without actually retrieving any class definitions.
    // This allows us to allocate the minimum amount of memory needed for the application.

    NSUInteger numClasses = 0;
    Class *classes = NULL;

    while (numClasses == 0) {

        numClasses = (NSUInteger)MAX(objc_getClassList(NULL, 0), 0);

        // numClasses now tells us how many classes we have (but it might change)
        // So we can allocate our buffer, and get pointers to all the class definitions.

        NSUInteger bufferSize = numClasses;

        classes = numClasses ? (Class *)calloc(bufferSize, sizeof(Class)) : NULL;
        if (classes == NULL) {
            return @[]; //no memory or classes?
        }

        numClasses = (NSUInteger)MAX(objc_getClassList(classes, (int)bufferSize),0);

        if (numClasses > bufferSize || numClasses == 0) {
            //apparently more classes added between calls (or a problem); try again
            free(classes);
            classes = NULL;
            numClasses = 0;
        }
    }

    // We can now loop through the classes, and test each one to see if it is a GrowingLogging class.

    NSMutableArray *result = [NSMutableArray arrayWithCapacity:numClasses];

    for (NSUInteger i = 0; i < numClasses; i++) {
        Class class = classes[i];

        if ([self isRegisteredClass:class]) {
            [result addObject:class];
        }
    }

    free(classes);

    return result;
}

+ (NSArray *)registeredClassNames {
    NSArray *registeredClasses = [self registeredClasses];
    NSMutableArray *result = [NSMutableArray arrayWithCapacity:[registeredClasses count]];

    for (Class class in registeredClasses) {
        [result addObject:NSStringFromClass(class)];
    }
    return result;
}

+ (GrowingLogLevel)levelForClass:(Class)aClass {
    if ([self isRegisteredClass:aClass]) {
        return [aClass gioLogLevel];
    }
    return (GrowingLogLevel)-1;
}

+ (GrowingLogLevel)levelForClassWithName:(NSString *)aClassName {
    Class aClass = NSClassFromString(aClassName);

    return [self levelForClass:aClass];
}

+ (void)setLevel:(GrowingLogLevel)level forClass:(Class)aClass {
    if ([self isRegisteredClass:aClass]) {
        [aClass gioSetLogLevel:level];
    }
}

+ (void)setLevel:(GrowingLogLevel)level forClassWithName:(NSString *)aClassName {
    Class aClass = NSClassFromString(aClassName);
    if (aClass) {
        [self setLevel:level forClass:aClass];
    }
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Logging Thread
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)lt_addLogger:(id <GrowingLogger>)logger level:(GrowingLogLevel)level {
    // Add to loggers array.
    // Need to create loggerQueue if loggerNode doesn't provide one.

    for (GrowingLoggerNode *node in self._loggers) {
        if (node->_logger == logger
            && node->_level == level) {
            // Exactly same logger already added, exit
            return;
        }
    }

    NSAssert(dispatch_get_specific(GlobalLoggingQueueIdentityKey),
             @"This method should only be run on the logging thread/queue");

    dispatch_queue_t loggerQueue = NULL;
    if ([logger respondsToSelector:@selector(loggerQueue)]) {
        // Logger may be providing its own queue
        loggerQueue = logger.loggerQueue;
    }

    if (loggerQueue == nil) {
        // Automatically create queue for the logger.
        // Use the logger name as the queue name if possible.
        const char *loggerQueueName = NULL;

        if ([logger respondsToSelector:@selector(loggerName)]) {
            loggerQueueName = logger.loggerName.UTF8String;
        }

        loggerQueue = dispatch_queue_create(loggerQueueName, NULL);
    }

    GrowingLoggerNode *loggerNode = [GrowingLoggerNode nodeWithLogger:logger loggerQueue:loggerQueue level:level];
    [self._loggers addObject:loggerNode];

    if ([logger respondsToSelector:@selector(didAddLoggerInQueue:)]) {
        dispatch_async(loggerNode->_loggerQueue, ^{ @autoreleasepool {
            [logger didAddLoggerInQueue:loggerNode->_loggerQueue];
        } });
    } else if ([logger respondsToSelector:@selector(didAddLogger)]) {
        dispatch_async(loggerNode->_loggerQueue, ^{ @autoreleasepool {
            [logger didAddLogger];
        } });
    }
}

- (void)lt_removeLogger:(id <GrowingLogger>)logger {
    // Find associated loggerNode in list of added loggers

    NSAssert(dispatch_get_specific(GlobalLoggingQueueIdentityKey),
             @"This method should only be run on the logging thread/queue");

    GrowingLoggerNode *loggerNode = nil;

    for (GrowingLoggerNode *node in self._loggers) {
        if (node->_logger == logger) {
            loggerNode = node;
            break;
        }
    }

    if (loggerNode == nil) {
        NSLogDebug(@"GrowingLog: Request to remove logger which wasn't added");
        return;
    }

    // Notify logger
    if ([logger respondsToSelector:@selector(willRemoveLogger)]) {
        dispatch_async(loggerNode->_loggerQueue, ^{ @autoreleasepool {
            [logger willRemoveLogger];
        } });
    }

    // Remove from loggers array
    [self._loggers removeObject:loggerNode];
}

- (void)lt_removeAllLoggers {
    NSAssert(dispatch_get_specific(GlobalLoggingQueueIdentityKey),
             @"This method should only be run on the logging thread/queue");

    // Notify all loggers
    for (GrowingLoggerNode *loggerNode in self._loggers) {
        if ([loggerNode->_logger respondsToSelector:@selector(willRemoveLogger)]) {
            dispatch_async(loggerNode->_loggerQueue, ^{ @autoreleasepool {
                [loggerNode->_logger willRemoveLogger];
            } });
        }
    }

    // Remove all loggers from array

    [self._loggers removeAllObjects];
}

- (NSArray *)lt_allLoggers {
    NSAssert(dispatch_get_specific(GlobalLoggingQueueIdentityKey),
             @"This method should only be run on the logging thread/queue");

    NSMutableArray *theLoggers = [NSMutableArray new];

    for (GrowingLoggerNode *loggerNode in self._loggers) {
        [theLoggers addObject:loggerNode->_logger];
    }

    return [theLoggers copy];
}

- (NSArray *)lt_allLoggersWithLevel {
    NSAssert(dispatch_get_specific(GlobalLoggingQueueIdentityKey),
             @"This method should only be run on the logging thread/queue");

    NSMutableArray *theLoggersWithLevel = [NSMutableArray new];

    for (GrowingLoggerNode *loggerNode in self._loggers) {
        [theLoggersWithLevel addObject:[GrowingLoggerInformation informationWithLogger:loggerNode->_logger
                                                                         andLevel:loggerNode->_level]];
    }

    return [theLoggersWithLevel copy];
}

- (void)lt_log:(GrowingLogMessage *)logMessage {
    // Execute the given log message on each of our loggers.

    NSAssert(dispatch_get_specific(GlobalLoggingQueueIdentityKey),
             @"This method should only be run on the logging thread/queue");

    if (_numProcessors > 1) {
        // Execute each logger concurrently, each within its own queue.
        // All blocks are added to same group.
        // After each block has been queued, wait on group.
        //
        // The waiting ensures that a slow logger doesn't end up with a large queue of pending log messages.
        // This would defeat the purpose of the efforts we made earlier to restrict the max queue size.

        for (GrowingLoggerNode *loggerNode in self._loggers) {
            // skip the loggers that shouldn't write this message based on the log level

            if (!(logMessage->_flag & loggerNode->_level)) {
                continue;
            }

            dispatch_group_async(_loggingGroup, loggerNode->_loggerQueue, ^{ @autoreleasepool {
                [loggerNode->_logger logMessage:logMessage];
            } });
        }

        dispatch_group_wait(_loggingGroup, DISPATCH_TIME_FOREVER);
    } else {
        // Execute each logger serially, each within its own queue.

        for (GrowingLoggerNode *loggerNode in self._loggers) {
            // skip the loggers that shouldn't write this message based on the log level

            if (!(logMessage->_flag & loggerNode->_level)) {
                continue;
            }

#if Growing_DEBUG
            // we must assure that we aren not on loggerNode->_loggerQueue.
            if (loggerNode->_loggerQueue == NULL) {
              // tell that we can't dispatch logger node on queue that is NULL.
              NSLogDebug(@"GrowingLog: current node has loggerQueue == NULL");
            }
            else {
              dispatch_async(loggerNode->_loggerQueue, ^{
                if (dispatch_get_specific(GlobalLoggingQueueIdentityKey)) {
                  // tell that we somehow on logging queue?
                  NSLogDebug(@"GrowingLog: current node has loggerQueue == globalLoggingQueue");
                }
              });
            }
#endif
            // next, we must check that node is OK.
            dispatch_sync(loggerNode->_loggerQueue, ^{ @autoreleasepool {
                [loggerNode->_logger logMessage:logMessage];
            } });
        }
    }
}

- (void)lt_flush {
    // All log statements issued before the flush method was invoked have now been executed.
    //
    // Now we need to propagate the flush request to any loggers that implement the flush method.
    // This is designed for loggers that buffer IO.

    NSAssert(dispatch_get_specific(GlobalLoggingQueueIdentityKey),
             @"This method should only be run on the logging thread/queue");

    for (GrowingLoggerNode *loggerNode in self._loggers) {
        if ([loggerNode->_logger respondsToSelector:@selector(flush)]) {
            dispatch_group_async(_loggingGroup, loggerNode->_loggerQueue, ^{ @autoreleasepool {
                [loggerNode->_logger flush];
            } });
        }
    }

    dispatch_group_wait(_loggingGroup, DISPATCH_TIME_FOREVER);
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Utilities
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

NSString * __nullable GrowingExtractFileNameWithoutExtension(const char *filePath, BOOL copy) {
    if (filePath == NULL) {
        return nil;
    }

    char *lastSlash = NULL;
    char *lastDot = NULL;

    char *p = (char *)filePath;

    while (*p != '\0') {
        if (*p == '/') {
            lastSlash = p;
        } else if (*p == '.') {
            lastDot = p;
        }

        p++;
    }

    char *subStr;
    NSUInteger subLen;

    if (lastSlash) {
        if (lastDot) {
            // lastSlash -> lastDot
            subStr = lastSlash + 1;
            subLen = (NSUInteger)(lastDot - subStr);
        } else {
            // lastSlash -> endOfString
            subStr = lastSlash + 1;
            subLen = (NSUInteger)(p - subStr);
        }
    } else {
        if (lastDot) {
            // startOfString -> lastDot
            subStr = (char *)filePath;
            subLen = (NSUInteger)(lastDot - subStr);
        } else {
            // startOfString -> endOfString
            subStr = (char *)filePath;
            subLen = (NSUInteger)(p - subStr);
        }
    }

    if (copy) {
        return [[NSString alloc] initWithBytes:subStr
                                        length:subLen
                                      encoding:NSUTF8StringEncoding];
    } else {
        // We can take advantage of the fact that __FILE__ is a string literal.
        // Specifically, we don't need to waste time copying the string.
        // We can just tell NSString to point to a range within the string literal.

        return [[NSString alloc] initWithBytesNoCopy:subStr
                                              length:subLen
                                            encoding:NSUTF8StringEncoding
                                        freeWhenDone:NO];
    }
}

@end

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

@implementation GrowingLoggerNode

- (instancetype)initWithLogger:(id <GrowingLogger>)logger loggerQueue:(dispatch_queue_t)loggerQueue level:(GrowingLogLevel)level {
    if ((self = [super init])) {
        _logger = logger;

        if (loggerQueue) {
            _loggerQueue = loggerQueue;
            #if !OS_OBJECT_USE_OBJC
            dispatch_retain(loggerQueue);
            #endif
        }

        _level = level;
    }
    return self;
}

+ (instancetype)nodeWithLogger:(id <GrowingLogger>)logger loggerQueue:(dispatch_queue_t)loggerQueue level:(GrowingLogLevel)level {
    return [[self alloc] initWithLogger:logger loggerQueue:loggerQueue level:level];
}

- (void)dealloc {
    #if !OS_OBJECT_USE_OBJC
    if (_loggerQueue) {
        dispatch_release(_loggerQueue);
    }
    #endif
}

@end

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

@implementation GrowingLogMessage

- (instancetype)init {
    self = [super init];
    return self;
}

- (instancetype)initWithMessage:(NSString *)message
                          level:(GrowingLogLevel)level
                           flag:(GrowingLogFlag)flag
                        context:(NSInteger)context
                           file:(NSString *)file
                       function:(NSString *)function
                           line:(NSUInteger)line
                            tag:(id)tag
                        options:(GrowingLogMessageOptions)options
                      timestamp:(NSDate *)timestamp {
    if ((self = [super init])) {
        BOOL copyMessage = (options & GrowingLogMessageDontCopyMessage) == 0;
        _message      = copyMessage ? [message copy] : message;
        _level        = level;
        _flag         = flag;
        _context      = context;

        BOOL copyFile = (options & GrowingLogMessageCopyFile) != 0;
        _file = copyFile ? [file copy] : file;

        BOOL copyFunction = (options & GrowingLogMessageCopyFunction) != 0;
        _function = copyFunction ? [function copy] : function;

        _line         = line;
        _tag          = tag;
        _options      = options;
        _timestamp    = timestamp ?: [NSDate new];

        __uint64_t tid;
        if (pthread_threadid_np(NULL, &tid) == 0) {
            _threadID = [[NSString alloc] initWithFormat:@"%llu", tid];
        } else {
            _threadID = @"missing threadId";
        }
        _threadName   = NSThread.currentThread.name;

        // Get the file name without extension
        _fileName = [_file lastPathComponent];
        NSUInteger dotLocation = [_fileName rangeOfString:@"." options:NSBackwardsSearch].location;
        if (dotLocation != NSNotFound)
        {
            _fileName = [_fileName substringToIndex:dotLocation];
        }

        // Try to get the current queue's label
        _queueLabel = [[NSString alloc] initWithFormat:@"%s", dispatch_queue_get_label(DISPATCH_CURRENT_QUEUE_LABEL)];

        if (@available(macOS 10.10, iOS 8.0, *))
            _qos = (NSUInteger) qos_class_self();
    }
    return self;
}

- (id)copyWithZone:(NSZone * __attribute__((unused)))zone {
    GrowingLogMessage *newMessage = [GrowingLogMessage new];

    newMessage->_message = _message;
    newMessage->_level = _level;
    newMessage->_flag = _flag;
    newMessage->_context = _context;
    newMessage->_file = _file;
    newMessage->_fileName = _fileName;
    newMessage->_function = _function;
    newMessage->_line = _line;
    newMessage->_tag = _tag;
    newMessage->_options = _options;
    newMessage->_timestamp = _timestamp;
    newMessage->_threadID = _threadID;
    newMessage->_threadName = _threadName;
    newMessage->_queueLabel = _queueLabel;
    newMessage->_qos = _qos;

    return newMessage;
}

@end


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

@implementation GrowingAbstractLogger

- (instancetype)init {
    if ((self = [super init])) {
        const char *loggerQueueName = NULL;

        if ([self respondsToSelector:@selector(loggerName)]) {
            loggerQueueName = self.loggerName.UTF8String;
        }

        _loggerQueue = dispatch_queue_create(loggerQueueName, NULL);

        // We're going to use dispatch_queue_set_specific() to "mark" our loggerQueue.
        // Later we can use dispatch_get_specific() to determine if we're executing on our loggerQueue.
        // The documentation states:
        //
        // > Keys are only compared as pointers and are never dereferenced.
        // > Thus, you can use a pointer to a static variable for a specific subsystem or
        // > any other value that allows you to identify the value uniquely.
        // > Specifying a pointer to a string constant is not recommended.
        //
        // So we're going to use the very convenient key of "self",
        // which also works when multiple logger classes extend this class, as each will have a different "self" key.
        //
        // This is used primarily for thread-safety assertions (via the isOnInternalLoggerQueue method below).

        void *key = (__bridge void *)self;
        void *nonNullValue = (__bridge void *)self;

        dispatch_queue_set_specific(_loggerQueue, key, nonNullValue, NULL);
    }

    return self;
}

- (void)dealloc {
    #if !OS_OBJECT_USE_OBJC

    if (_loggerQueue) {
        dispatch_release(_loggerQueue);
    }

    #endif
}

- (void)logMessage:(GrowingLogMessage * __attribute__((unused)))logMessage {
    // Override me
}

- (id <GrowingLogFormatter>)logFormatter {
    // This method must be thread safe and intuitive.
    // Therefore if somebody executes the following code:
    //
    // [logger setLogFormatter:myFormatter];
    // formatter = [logger logFormatter];
    //
    // They would expect formatter to equal myFormatter.
    // This functionality must be ensured by the getter and setter method.
    //
    // The thread safety must not come at a cost to the performance of the logMessage method.
    // This method is likely called sporadically, while the logMessage method is called repeatedly.
    // This means, the implementation of this method:
    // - Must NOT require the logMessage method to acquire a lock.
    // - Must NOT require the logMessage method to access an atomic property (also a lock of sorts).
    //
    // Thread safety is ensured by executing access to the formatter variable on the loggerQueue.
    // This is the same queue that the logMessage method operates on.
    //
    // Note: The last time I benchmarked the performance of direct access vs atomic property access,
    // direct access was over twice as fast on the desktop and over 6 times as fast on the iPhone.
    //
    // Furthermore, consider the following code:
    //
    // GrowingLogVerbose(@"log msg 1");
    // GrowingLogVerbose(@"log msg 2");
    // [logger setFormatter:myFormatter];
    // GrowingLogVerbose(@"log msg 3");
    //
    // Our intuitive requirement means that the new formatter will only apply to the 3rd log message.
    // This must remain true even when using asynchronous logging.
    // We must keep in mind the various queue's that are in play here:
    //
    // loggerQueue : Our own private internal queue that the logMessage method runs on.
    //               Operations are added to this queue from the global loggingQueue.
    //
    // globalLoggingQueue : The queue that all log messages go through before they arrive in our loggerQueue.
    //
    // All log statements go through the serial globalLoggingQueue before they arrive at our loggerQueue.
    // Thus this method also goes through the serial globalLoggingQueue to ensure intuitive operation.

    // IMPORTANT NOTE:
    //
    // Methods within the GrowingLogger implementation MUST access the formatter ivar directly.
    // This method is designed explicitly for external access.
    //
    // Using "self." syntax to go through this method will cause immediate deadlock.
    // This is the intended result. Fix it by accessing the ivar directly.
    // Great strides have been take to ensure this is safe to do. Plus it's MUCH faster.

    NSAssert(![self isOnGlobalLoggingQueue], @"Core architecture requirement failure");
    NSAssert(![self isOnInternalLoggerQueue], @"MUST access ivar directly, NOT via self.* syntax.");

    dispatch_queue_t globalLoggingQueue = [GrowingLog loggingQueue];

    __block id <GrowingLogFormatter> result;

    dispatch_sync(globalLoggingQueue, ^{
        dispatch_sync(self->_loggerQueue, ^{
            result = self->_logFormatter;
        });
    });

    return result;
}

- (void)setLogFormatter:(id <GrowingLogFormatter>)logFormatter {
    // The design of this method is documented extensively in the logFormatter message (above in code).

    NSAssert(![self isOnGlobalLoggingQueue], @"Core architecture requirement failure");
    NSAssert(![self isOnInternalLoggerQueue], @"MUST access ivar directly, NOT via self.* syntax.");

    dispatch_block_t block = ^{
        @autoreleasepool {
            if (self->_logFormatter != logFormatter) {
                if ([self->_logFormatter respondsToSelector:@selector(willRemoveFromLogger:)]) {
                    [self->_logFormatter willRemoveFromLogger:self];
                }

                self->_logFormatter = logFormatter;

                if ([self->_logFormatter respondsToSelector:@selector(didAddToLogger:inQueue:)]) {
                    [self->_logFormatter didAddToLogger:self inQueue:self->_loggerQueue];
                } else if ([self->_logFormatter respondsToSelector:@selector(didAddToLogger:)]) {
                    [self->_logFormatter didAddToLogger:self];
                }
            }
        }
    };

    dispatch_async(GrowingLog.loggingQueue, ^{
        dispatch_async(self->_loggerQueue, block);
    });
}

- (dispatch_queue_t)loggerQueue {
    return _loggerQueue;
}

- (NSString *)loggerName {
    return NSStringFromClass([self class]);
}

- (BOOL)isOnGlobalLoggingQueue {
    return (dispatch_get_specific(GlobalLoggingQueueIdentityKey) != NULL);
}

- (BOOL)isOnInternalLoggerQueue {
    void *key = (__bridge void *)self;

    return (dispatch_get_specific(key) != NULL);
}

@end

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

@interface GrowingLoggerInformation()
{
    // Direct accessors to be used only for performance
    @public
    id <GrowingLogger> _logger;
    GrowingLogLevel _level;
}

@end

@implementation GrowingLoggerInformation

- (instancetype)initWithLogger:(id <GrowingLogger>)logger andLevel:(GrowingLogLevel)level {
    if ((self = [super init])) {
        _logger = logger;
        _level = level;
    }
    return self;
}

+ (instancetype)informationWithLogger:(id <GrowingLogger>)logger andLevel:(GrowingLogLevel)level {
    return [[self alloc] initWithLogger:logger andLevel:level];
}

@end
