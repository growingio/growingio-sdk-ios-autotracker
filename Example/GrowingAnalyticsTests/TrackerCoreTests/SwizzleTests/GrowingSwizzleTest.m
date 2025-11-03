//
//  GrowingULSwizzleTest.m
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

#import <objc/message.h>
#import <objc/runtime.h>
#import "GrowingULSwizzle.h"
#import "GrowingULSwizzler.h"

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
#pragma clang diagnostic ignored "-Wincomplete-implementation"

static NSInteger b = 0;

@interface Growing_Swizzle_XCTest : NSObject

- (void)instanceMethod;

+ (void)classMethod;

@end

@implementation Growing_Swizzle_XCTest

- (void)instanceMethod {
}

+ (void)classMethod {
}

@end

@interface Growing_Swizzle_XCTest_B : Growing_Swizzle_XCTest

@end

@implementation Growing_Swizzle_XCTest_B

@end

@interface Growing_Swizzle_XCTest_C : Growing_Swizzle_XCTest_B

@end

@implementation Growing_Swizzle_XCTest_C

@end

@interface Growing_Swizzle_XCTest_D : Growing_Swizzle_XCTest_B

@end

@implementation Growing_Swizzle_XCTest_D

- (void)instanceMethod {
    [super instanceMethod];
}

@end

@interface Growing_Swizzle_XCTest_B_2 : Growing_Swizzle_XCTest

@end

@implementation Growing_Swizzle_XCTest_B_2

@end

@interface Growing_Swizzle_XCTest_D_2 : Growing_Swizzle_XCTest_B_2

@end

@implementation Growing_Swizzle_XCTest_D_2

- (void)instanceMethod {
    [super instanceMethod];
}

@end

@interface Growing_Swizzle_XCTest_E : Growing_Swizzle_XCTest_B

@end

@implementation Growing_Swizzle_XCTest_E

- (void)instanceMethod {
    
}

@end

@interface Growing_Swizzle_XCTest (XCTest)

- (void)swizzle_instanceMethod;

+ (void)swizzle_classMethod;

@end

@implementation Growing_Swizzle_XCTest (XCTest)

- (void)swizzle_instanceMethod {
    b++;
}

+ (void)swizzle_classMethod {
    b += 2;
}

@end

@interface Growing_Swizzle_Proxy_XCTest : NSProxy

@property (nonatomic, weak) id target;

- (void)delegateSelector;

- (void)delegateSelector2;

@end

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

@interface GrowingULSwizzleTest : XCTestCase

@property (nonatomic, strong) NSMutableString *swizzleString;

@end

@implementation GrowingULSwizzleTest

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
    self.swizzleString = @"".mutableCopy;
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)generalSwizzleClass:(Class)cls selector:(SEL)sel {
    __weak typeof(self) weakSelf = self;
    __block NSInvocation *invocation = nil;
    invocation = [cls growingul_swizzleMethod:sel withBlock:^(id obj) {
        [invocation invokeWithTarget:obj];
        [weakSelf.swizzleString appendString:@"A"];
    } error:nil];
}

- (void)guSwizzleClass:(Class)cls selector:(SEL)sel key:(const void *)key mode:(GrowingULSwizzleMode)mode {
    __weak typeof(self) weakSelf = self;
    GrowingULSwizzleInstanceMethod(cls,
                                   sel,
                                   GUSWReturnType(void),
                                   GUSWArguments(),
                                   GUSWReplacement({
        GUSWCallOriginal();
        [weakSelf.swizzleString appendString:@"B"];
    }), mode, key);
}

- (void)test01InstanceSwizzlingInModeOncePerClassAndSuperclasses {
    SEL selector = @selector(instanceMethod);
    static const void *key = &key;
    
    // hook子类B
    [self guSwizzleClass:Growing_Swizzle_XCTest_B.class
                selector:selector
                     key:key
                    mode:GrowingULSwizzleModeOncePerClassAndSuperclasses];
    
    // 父类没有调用swizzle方法
    self.swizzleString.string = @"";
    [[Growing_Swizzle_XCTest new] performSelector:selector];
    XCTAssertEqualObjects(self.swizzleString, @"");
    
    // 子类正常调用swizzle方法
    self.swizzleString.string = @"";
    [[Growing_Swizzle_XCTest_B new] performSelector:selector];
    XCTAssertEqualObjects(self.swizzleString, @"B");
    
    // 子类如果没有重写，则调用用的是父类的，会调用swizzle方法
    self.swizzleString.string = @"";
    [[Growing_Swizzle_XCTest_C new] performSelector:selector];
    XCTAssertEqualObjects(self.swizzleString, @"B");
    
    // 子类如果重写且调用super，则触发1次
    self.swizzleString.string = @"";
    [[Growing_Swizzle_XCTest_D new] performSelector:selector];
    XCTAssertEqualObjects(self.swizzleString, @"B");
    
    // hook子类D
    [self guSwizzleClass:Growing_Swizzle_XCTest_D.class
                selector:selector
                     key:key
                    mode:GrowingULSwizzleModeOncePerClassAndSuperclasses];
    
    // 子类如果重写且调用super，先后hook了B和B的子类D，则触发1次；此为ModeOncePerClassAndSuperclasses的作用
    self.swizzleString.string = @"";
    [[Growing_Swizzle_XCTest_D new] performSelector:selector];
    XCTAssertEqualObjects(self.swizzleString, @"B");
    
    // 异常情况1：如果先hook子类（重写且调用super），再hook父类的话，则会触发2次
    {
        [self guSwizzleClass:Growing_Swizzle_XCTest_D_2.class
                    selector:selector
                         key:key
                        mode:GrowingULSwizzleModeOncePerClassAndSuperclasses];
        [self guSwizzleClass:Growing_Swizzle_XCTest_B_2.class
                    selector:selector
                         key:key
                        mode:GrowingULSwizzleModeOncePerClassAndSuperclasses];
        // B_2正常调用swizzle方法
        self.swizzleString.string = @"";
        [[Growing_Swizzle_XCTest_B_2 new] performSelector:selector];
        XCTAssertEqualObjects(self.swizzleString, @"B");
        
        // D_2会触发2次；此为异常情况
        self.swizzleString.string = @"";
        [[Growing_Swizzle_XCTest_D_2 new] performSelector:selector];
        XCTAssertEqualObjects(self.swizzleString, @"BB");
    }
    
    // 异常情况2：子类如果重写且没调用super，则swizzle不生效
    {
        self.swizzleString.string = @"";
        [[Growing_Swizzle_XCTest_E new] performSelector:selector];
        XCTAssertEqualObjects(self.swizzleString, @"");
    }
}

- (void)test02ClassSwizzling {
    Class cls = Growing_Swizzle_XCTest_B.class;
    SEL selector = @selector(classMethod);
    __block NSMutableString *swizzleString = self.swizzleString;
    
    // hook子类B
    GrowingULSwizzleClassMethod(cls,
                                selector,
                                GUSWReturnType(void),
                                GUSWArguments(),
                                GUSWReplacement({
        GUSWCallOriginal();
        [swizzleString appendString:@"B"];
    }));
    
    // 父类没有调用swizzle方法
    self.swizzleString.string = @"";
    [Growing_Swizzle_XCTest classMethod];
    XCTAssertEqualObjects(self.swizzleString, @"");
    
    // 子类正常调用swizzle方法
    self.swizzleString.string = @"";
    [Growing_Swizzle_XCTest_B classMethod];
    XCTAssertEqualObjects(self.swizzleString, @"B");
    
    // 子类如果没有重写，则调用用的是父类的，会调用swizzle方法
    self.swizzleString.string = @"";
    [Growing_Swizzle_XCTest_C classMethod];
    XCTAssertEqualObjects(self.swizzleString, @"B");
}

- (void)test03AlwaysSwizzlingMode {
    // GrowingULSwizzleModeAlways的swizzle一直触发
    Class cls = Growing_Swizzle_XCTest.class;
    Class cls2 = Growing_Swizzle_XCTest_B.class;
    SEL selector = @selector(instanceMethod);
    for (int i = 3; i > 0; --i) {
        [self guSwizzleClass:cls selector:selector key:NULL mode:GrowingULSwizzleModeAlways];
        [self guSwizzleClass:cls2 selector:selector key:NULL mode:GrowingULSwizzleModeAlways];
    }
    NSObject *test = [cls2 new];
    [test performSelector:selector];
    XCTAssertEqualObjects(self.swizzleString, @"BBBBBB");
}

- (void)test04SwizzleOncePerClassMode {
    // GrowingULSwizzleModeOncePerClass只能保证分别对父类和子类只swizzle一次
    Class cls = Growing_Swizzle_XCTest.class;
    Class cls2 = Growing_Swizzle_XCTest_B.class;
    SEL selector = @selector(instanceMethod);
    static const void *key = &key;
    for (int i = 3; i > 0; --i) {
        [self guSwizzleClass:cls selector:selector key:key mode:GrowingULSwizzleModeOncePerClass];
        [self guSwizzleClass:cls2 selector:selector key:key mode:GrowingULSwizzleModeOncePerClass];
    }
    NSObject *test = [cls2 new];
    [test performSelector:selector];
    XCTAssertEqualObjects(self.swizzleString, @"BB");
}

- (void)test05SwizzleOncePerClassOrSuperClassesMode {
    // 先swizzle父类，再swizzle子类，GrowingULSwizzleModeOncePerClassAndSuperclasses保证只swizzle一次
    Class cls = Growing_Swizzle_XCTest.class;
    Class cls2 = Growing_Swizzle_XCTest_B.class;
    SEL selector = @selector(instanceMethod);
    static const void *key = &key;
    for (int i = 3; i > 0; --i) {
        [self guSwizzleClass:cls selector:selector key:key mode:GrowingULSwizzleModeOncePerClassAndSuperclasses];
        [self guSwizzleClass:cls2 selector:selector key:key mode:GrowingULSwizzleModeOncePerClassAndSuperclasses];
    }
    NSObject *test = [cls2 new];
    [test performSelector:selector];
    XCTAssertEqualObjects(self.swizzleString, @"B");
}

- (void)test06SwizzleOncePerClassOrSuperClassesMode2 {
    // 先swizzle子类，再swizzle父类，GrowingULSwizzleModeOncePerClassAndSuperclasses就只能保证分别对父类和子类只swizzle一次
    Class cls = Growing_Swizzle_XCTest.class;
    Class cls2 = Growing_Swizzle_XCTest_B.class;
    SEL selector = @selector(instanceMethod);
    static const void *key = &key;
    for (int i = 3; i > 0; --i) {
        [self guSwizzleClass:cls2 selector:selector key:key mode:GrowingULSwizzleModeOncePerClassAndSuperclasses];
        [self guSwizzleClass:cls selector:selector key:key mode:GrowingULSwizzleModeOncePerClassAndSuperclasses];
    }
    NSObject *test = [cls2 new];
    [test performSelector:selector];
    XCTAssertEqualObjects(self.swizzleString, @"BB");
}

- (void)test07GrowingULSwizzlerRealDelegate {
    // NSProxy
    id proxy = [[Growing_Swizzle_Proxy_XCTest alloc] initWithTarget:nil];
    {
        // proxy 本身实现了
        XCTAssertTrue([GrowingULSwizzle realDelegateClass:((NSObject *)proxy).class
                                        respondsToSelector:@selector(delegateSelector)]);

        // proxy 在 resolveInstanceMethod 增加了实现
        XCTAssertTrue([GrowingULSwizzle realDelegateClass:((NSObject *)proxy).class
                                        respondsToSelector:@selector(delegateSelector2)]);
    }
}

- (void)test08SwizzleCompatibility {
    // 先执行generalSwizzle
    Class cls = Growing_Swizzle_XCTest.class;
    SEL selector = @selector(instanceMethod);
    
    __weak typeof(self) weakSelf = self;
    void(^checkBlock)(NSString *) = ^(NSString *string) {
        weakSelf.swizzleString.string = @"";
        [[cls new] performSelector:selector];
        XCTAssertEqualObjects(weakSelf.swizzleString, string);
    };
    
    // generalSwizzleImp -> originImp
    // A
    [self generalSwizzleClass:cls selector:selector];
    checkBlock(@"A");

    // rsSwizzleImp -> generalSwizzleImp -> originImp
    // B <- A
    static const void *key = &key;
    [self guSwizzleClass:cls selector:selector key:key mode:GrowingULSwizzleModeOncePerClassAndSuperclasses];
    checkBlock(@"AB");

    // generalSwizzleImp -> rsSwizzleImp -> generalSwizzleImp -> originImp
    // A <- B <- A
    [self generalSwizzleClass:cls selector:selector];
    checkBlock(@"ABA");

    // generalSwizzleImp -> rsSwizzleImp -> generalSwizzleImp -> originImp
    // A <- B <- A
    [self guSwizzleClass:cls selector:selector key:key mode:GrowingULSwizzleModeOncePerClassAndSuperclasses];
    checkBlock(@"ABA");
    
    // generalSwizzleImp -> generalSwizzleImp -> rsSwizzleImp -> generalSwizzleImp -> originImp
    // A <- A <- B <- A
    [self generalSwizzleClass:cls selector:selector];
    checkBlock(@"ABAA");
}

- (void)test09SwizzleCompatibility {
    // 先执行rsSwizzle
    Class cls = Growing_Swizzle_XCTest.class;
    SEL selector = @selector(instanceMethod);
    
    __weak typeof(self) weakSelf = self;
    void(^checkBlock)(NSString *) = ^(NSString *string) {
        weakSelf.swizzleString.string = @"";
        [[cls new] performSelector:selector];
        XCTAssertEqualObjects(weakSelf.swizzleString, string);
    };
    
    // rsSwizzleImp -> originImp
    // B
    static const void *key = &key;
    [self guSwizzleClass:cls selector:selector key:key mode:GrowingULSwizzleModeOncePerClassAndSuperclasses];
    checkBlock(@"B");

    // generalSwizzleImp -> rsSwizzleImp -> originImp
    // A <- B
    [self generalSwizzleClass:cls selector:selector];
    checkBlock(@"BA");

    // generalSwizzleImp -> rsSwizzleImp -> originImp
    // A <- B
    [self guSwizzleClass:cls selector:selector key:key mode:GrowingULSwizzleModeOncePerClassAndSuperclasses];
    checkBlock(@"BA");
    
    // generalSwizzleImp -> generalSwizzleImp -> rsSwizzleImp -> originImp
    // A <- A <- B
    [self generalSwizzleClass:cls selector:selector];
    checkBlock(@"BAA");
}

- (void)test10SwizzleCompatibility {
    // isaSwizzler
    Class cls = Growing_Swizzle_XCTest.class;
    SEL selector = @selector(instanceMethod);
    
    Growing_Swizzle_XCTest *instance = [cls new];
    __weak typeof(self) weakSelf = self;
    void(^checkBlock)(NSString *) = ^(NSString *string) {
        weakSelf.swizzleString.string = @"";
        [instance performSelector:selector];
        XCTAssertEqualObjects(weakSelf.swizzleString, string);
    };

    NSString *newClassName = [NSString stringWithFormat:@"%@_%@", [NSUUID UUID].UUIDString,
                                                        NSStringFromClass(cls)];
    Class generatedClass = objc_allocateClassPair(cls, newClassName.UTF8String, 0);
    objc_registerClassPair(generatedClass);
    object_setClass(instance, generatedClass);
    
    // isaSwizzler最后还是需要在动态子类中重写并调用父类方法，因此只要保证对父类的swizzler正常生效即可
    
    // rsSwizzleImp -> originImp
    // B
    static const void *key = &key;
    [self guSwizzleClass:cls selector:selector key:key mode:GrowingULSwizzleModeOncePerClassAndSuperclasses];
    checkBlock(@"B");

    // generalSwizzleImp -> rsSwizzleImp -> originImp
    // A <- B
    [self generalSwizzleClass:cls selector:selector];
    checkBlock(@"BA");

    // generalSwizzleImp -> rsSwizzleImp -> originImp
    // A <- B
    [self guSwizzleClass:cls selector:selector key:key mode:GrowingULSwizzleModeOncePerClassAndSuperclasses];
    checkBlock(@"BA");
    
    // generalSwizzleImp -> generalSwizzleImp -> rsSwizzleImp -> originImp
    // A <- A <- B
    [self generalSwizzleClass:cls selector:selector];
    checkBlock(@"BAA");
}

- (void)test11GrowingULSwizzle {
    NSError *error = nil;
    [Growing_Swizzle_XCTest growingul_swizzleMethod:@selector(undefinedSelector)
                                         withMethod:@selector(swizzle_instanceMethod)
                                              error:&error];
    XCTAssertNotNil(error);

    error = nil;
    [Growing_Swizzle_XCTest growingul_swizzleMethod:@selector(instanceMethod)
                                         withMethod:@selector(undefinedSelector)
                                              error:&error];
    XCTAssertNotNil(error);

    error = nil;
    [Growing_Swizzle_XCTest growingul_swizzleMethod:@selector(instanceMethod)
                                         withMethod:@selector(swizzle_instanceMethod)
                                              error:&error];
    XCTAssertNil(error);
    Growing_Swizzle_XCTest *test = Growing_Swizzle_XCTest.new;
    [test instanceMethod];
    XCTAssertEqual(b, 1);

    error = nil;
    [Growing_Swizzle_XCTest growingul_swizzleClassMethod:@selector(classMethod)
                                         withClassMethod:@selector(swizzle_classMethod)
                                                   error:&error];
    XCTAssertNil(error);
    [Growing_Swizzle_XCTest classMethod];
    XCTAssertEqual(b, 3);
}

@end

#pragma clang diagnostic pop
