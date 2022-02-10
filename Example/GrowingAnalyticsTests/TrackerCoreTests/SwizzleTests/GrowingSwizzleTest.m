//
//  GrowingSwizzleTest.m
//  GrowingAnalytics
//
//  Created by YoloMao on 2022/1/19.
//  Copyright (C) 2021 Beijing Yishu Technology Co., Ltd.
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


#import <XCTest/XCTest.h>

#import "GrowingSwizzle.h"
#import "GrowingSwizzler.h"
#import <objc/runtime.h>
#import <objc/message.h>

static NSInteger b = 0;

@interface Growing_Swizzle_XCTest : NSObject

- (void)instanceMethod;

- (void)instanceMethod:(NSString *)arg1;

- (void)instanceMethod:(NSString *)arg1 arg2:(NSString *)arg2;

- (void)instanceMethod:(NSString *)arg1 arg2:(NSString *)arg2 arg3:(NSString *)arg3;

- (void)instanceMethod:(NSString *)arg1 arg2:(NSString *)arg2 arg3:(NSString *)arg3 arg4:(NSString *)arg4;

+ (void)classMethod;

@end

@implementation Growing_Swizzle_XCTest

- (void)instanceMethod {
    b = 1;
}

+ (void)classMethod {
    b = 2;
}

- (void)instanceMethod:(NSString *)arg1 {
    b = 3;
}

- (void)instanceMethod:(NSString *)arg1 arg2:(NSString *)arg2 {
    b = 4;
}

- (void)instanceMethod:(NSString *)arg1 arg2:(NSString *)arg2 arg3:(NSString *)arg3 {
    b = 5;
}

- (void)instanceMethod:(NSString *)arg1 arg2:(NSString *)arg2 arg3:(NSString *)arg3 arg4:(NSString *)arg4 {
    b = 6;
}

@end

@interface Growing_Swizzle_XCTest (XCTest)

- (void)swizzle_instanceMethod;

+ (void)swizzle_classMethod;

@end

@implementation Growing_Swizzle_XCTest (XCTest)

- (void)swizzle_instanceMethod {
    b = 6;
}

+ (void)swizzle_classMethod {
    b = 7;
}

@end

@interface Growing_Swizzle_Proxy_XCTest : NSProxy

@property (nonatomic, weak) id target;

- (void)delegateSelector;

- (void)delegateSelector2;

@end

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wincomplete-implementation"

@implementation Growing_Swizzle_Proxy_XCTest

- (instancetype)initWithTarget:(id)target {
    _target = target;
    return self;
}

- (void)delegateSelector {
    
}

static void fooMethod(id obj, SEL _cmd) {
    
}

+ (BOOL)resolveInstanceMethod:(SEL)sel {
    if (sel == @selector(delegateSelector2)) {
        class_addMethod([self class], sel, (IMP)fooMethod, "v@:");
    }
    return NO;
}

@end

#pragma clang diagnostic pop

@interface Growing_Swizzle_Proxy_XCTest2 : NSProxy

@property (nonatomic, weak) id target;

- (instancetype)initWithTarget:(id)target;

- (void)delegateSelector;

@end

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wincomplete-implementation"

@implementation Growing_Swizzle_Proxy_XCTest2

- (instancetype)initWithTarget:(id)target {
    _target = target;
    return self;
}

- (id)forwardingTargetForSelector:(SEL)aSelector {
    return _target;
}

@end

#pragma clang diagnostic pop

@interface GrowingSwizzleTest : XCTestCase

@end

@implementation GrowingSwizzleTest

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)test0GrowingSwizzler {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
    {
        [GrowingSwizzler growing_swizzleSelector:@selector(instanceMethod)
                                         onClass:Growing_Swizzle_XCTest.class
                                       withBlock:^{
            b = 8;
        } named:@"xctest"];
        
        Growing_Swizzle_XCTest *test = Growing_Swizzle_XCTest.new;
        [test instanceMethod];
        XCTAssertEqual(b, 8);

        [GrowingSwizzler growing_unswizzleSelector:@selector(instanceMethod)
                                           onClass:Growing_Swizzle_XCTest.class
                                             named:@"xctest"];
        [test instanceMethod];
        XCTAssertEqual(b, 1);
    }
    
    {
        [GrowingSwizzler growing_swizzleSelector:@selector(instanceMethod:)
                                         onClass:Growing_Swizzle_XCTest.class
                                       withBlock:^{
            b = 9;
        } named:@"xctest"];
        
        Growing_Swizzle_XCTest *test = Growing_Swizzle_XCTest.new;
        [test instanceMethod:@""];
        XCTAssertEqual(b, 9);

        [GrowingSwizzler growing_unswizzleSelector:@selector(instanceMethod:)
                                           onClass:Growing_Swizzle_XCTest.class
                                             named:@"xctest"];
        [test instanceMethod:@""];
        XCTAssertEqual(b, 3);
    }
    
    {
        [GrowingSwizzler growing_swizzleSelector:@selector(instanceMethod:arg2:)
                                         onClass:Growing_Swizzle_XCTest.class
                                       withBlock:^{
            b = 10;
        } named:@"xctest"];
        
        Growing_Swizzle_XCTest *test = Growing_Swizzle_XCTest.new;
        [test instanceMethod:@"" arg2:@""];
        XCTAssertEqual(b, 10);

        [GrowingSwizzler growing_unswizzleSelector:@selector(instanceMethod:arg2:)
                                           onClass:Growing_Swizzle_XCTest.class
                                             named:@"xctest"];
        [test instanceMethod:@"" arg2:@""];
        XCTAssertEqual(b, 4);
    }
    
    {
        [GrowingSwizzler growing_swizzleSelector:@selector(instanceMethod:arg2:arg3:)
                                         onClass:Growing_Swizzle_XCTest.class
                                       withBlock:^{
            b = 11;
        } named:@"xctest"];
        
        Growing_Swizzle_XCTest *test = Growing_Swizzle_XCTest.new;
        [test instanceMethod:@"" arg2:@"" arg3:@""];
        XCTAssertEqual(b, 11);

        [GrowingSwizzler growing_unswizzleSelector:@selector(instanceMethod:arg2:arg3:)
                                           onClass:Growing_Swizzle_XCTest.class
                                             named:@"xctest"];
        [test instanceMethod:@"" arg2:@"" arg3:@""];
        XCTAssertEqual(b, 5);
    }
    
    {
        [GrowingSwizzler growing_swizzleSelector:@selector(instanceMethod)
                                         onClass:Growing_Swizzle_XCTest.class
                                       withBlock:^{
            b *= 2;
        } named:@"xctest"];
        [GrowingSwizzler growing_swizzleSelector:@selector(instanceMethod)
                                         onClass:Growing_Swizzle_XCTest.class
                                       withBlock:^{
            b *= 3;
        } named:@"xctest2"];
        
        Growing_Swizzle_XCTest *test = Growing_Swizzle_XCTest.new;
        [test instanceMethod];
        XCTAssertEqual(b, 6);

        ((void(*)(id, SEL, SEL, Class))objc_msgSend)(GrowingSwizzler.class,
                                                     @selector(growing_unswizzleSelector:onClass:),
                                                     @selector(instanceMethod),
                                                     Growing_Swizzle_XCTest.class);
        [test instanceMethod];
        XCTAssertEqual(b, 1);
    }
    
    {
        [GrowingSwizzler growing_swizzleSelector:@selector(respondsToSelector:)
                                         onClass:Growing_Swizzle_XCTest.class
                                       withBlock:^{
            b = 12;
        } named:@"xctest"];
    }
    
    {
        XCTAssertThrows([GrowingSwizzler growing_swizzleSelector:@selector(cannotFindMethod)
                                                         onClass:Growing_Swizzle_XCTest.class
                                                       withBlock:^{
        } named:@"xctest"]);
        
        XCTAssertThrows([GrowingSwizzler growing_swizzleSelector:@selector(instanceMethod:arg2:arg3:arg4:)
                                                         onClass:Growing_Swizzle_XCTest.class
                                                       withBlock:^{
        } named:@"xctest"]);
    }
        
    XCTAssertNoThrow([GrowingSwizzler growing_printSwizzles]);
#pragma clang diagnostic pop
}

- (void)test0GrowingSwizzlerRealDelegate {
    id proxy = nil;
    id proxy1 = [[Growing_Swizzle_Proxy_XCTest alloc] initWithTarget:nil];
    id proxy2 = [[Growing_Swizzle_Proxy_XCTest2 alloc] initWithTarget:proxy1];
    {
        XCTAssertNoThrow([GrowingSwizzler realDelegateClassFromSelector:@selector(delegateSelector) proxy:proxy]);
        
        id result = [GrowingSwizzler realDelegateClassFromSelector:@selector(delegateSelector)
                                                              proxy:proxy1];
        XCTAssertEqualObjects(Growing_Swizzle_Proxy_XCTest.class, result);
        XCTAssertTrue([GrowingSwizzler realDelegateClass:result respondsToSelector:@selector(delegateSelector)]);

        id result2 = [GrowingSwizzler realDelegateClassFromSelector:@selector(delegateSelector2)
                                                              proxy:proxy1];
        XCTAssertEqualObjects(Growing_Swizzle_Proxy_XCTest.class, result);
        XCTAssertTrue([GrowingSwizzler realDelegateClass:result2 respondsToSelector:@selector(delegateSelector2)]);
    }
    
    {
        id result = [GrowingSwizzler realDelegateClassFromSelector:@selector(delegateSelector)
                                                             proxy:proxy2];
        XCTAssertEqualObjects(Growing_Swizzle_Proxy_XCTest.class, result);
        XCTAssertTrue([GrowingSwizzler realDelegateClass:result respondsToSelector:@selector(delegateSelector)]);
    }
}

- (void)test1GrowingSwizzle {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
    NSError *error = nil;
    [Growing_Swizzle_XCTest growing_swizzleMethod:@selector(undefinedSelector)
                                       withMethod:@selector(swizzle_instanceMethod)
                                            error:&error];
    XCTAssertNotNil(error);
    
    error = nil;
    [Growing_Swizzle_XCTest growing_swizzleMethod:@selector(instanceMethod)
                                       withMethod:@selector(undefinedSelector)
                                            error:&error];
    XCTAssertNotNil(error);
    
    error = nil;
    [Growing_Swizzle_XCTest growing_swizzleMethod:@selector(instanceMethod)
                                       withMethod:@selector(swizzle_instanceMethod)
                                            error:&error];
    XCTAssertNil(error);
    Growing_Swizzle_XCTest *test = Growing_Swizzle_XCTest.new;
    [test instanceMethod];
    XCTAssertEqual(b, 6);

    error = nil;
    [Growing_Swizzle_XCTest growing_swizzleClassMethod:@selector(classMethod)
                                       withClassMethod:@selector(swizzle_classMethod)
                                                 error:&error];
    XCTAssertNil(error);
    [Growing_Swizzle_XCTest classMethod];
    XCTAssertEqual(b, 7);
#pragma clang diagnostic pop
}

@end
