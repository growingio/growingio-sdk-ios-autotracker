//
//  MediatorTest.m
//  GIOAutoTests
//
//  Created by apple on 2018/4/18.
//  Copyright (C) 2018 Beijing Yishu Technology Co., Ltd.
//

#import <XCTest/XCTest.h>
#import <KIF/KIF.h>

static NSString *string1;
static NSArray *array1;


@interface TestObjct : NSObject

@end

@implementation TestObjct

+ (void)classMethod1
{
    string1 = @"1";
}

+ (BOOL)classMethod2
{
    return YES;
}

+ (NSArray *)classMethod3:(NSDictionary *)dict
{
    return @[dict];
}

+ (NSDictionary *)classMethod4:(NSString *)string
{
    return @{@"key":string};
}

+ (void)classMethod5:(NSString *)string array:(NSArray *)array dict:(NSDictionary *)dict
{
    array1 = @[string, array, dict];
}

- (void)instanceMethod1
{
    string1 = @"2";
}

- (BOOL)instanceMethod2
{
    return YES;
}

- (NSArray *)instanceMethod3:(NSDictionary *)dict
{
    return @[dict];
}

- (NSDictionary *)instanceMethod4:(NSString *)string
{
    return @{@"key":string};
}

- (void)instanceMethod5:(NSString *)string array:(NSArray *)array dict:(NSDictionary *)dict
{
    array1 = @[string, array, dict];
}


@end

@interface MediatorTest : KIFTestCase

@end

@implementation MediatorTest

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)test1MediatorClassMethodTest {
//    [[GrowingMediator sharedInstance] performClass:@"TestObjct" action:@"classMethod1" params:nil];
//    XCTAssertEqual(string1, @"1");
//    BOOL boolRet = [[GrowingMediator sharedInstance] performClass:@"TestObjct" action:@"classMethod2" params:nil];
//    XCTAssertEqual(boolRet, YES);
//    NSArray *array = [[GrowingMediator sharedInstance] performClass:@"TestObjct" action:@"classMethod3:" params:@{@"0" :@{@"key":@"value"}}];
//    XCTAssertEqual(array[0][@"key"], @"value");
//    NSDictionary *dict = [[GrowingMediator sharedInstance] performClass:@"TestObjct" action:@"classMethod4:" params:@{@"0":@"haha"}];;
//    XCTAssertEqual(dict[@"key"], @"haha");
//    [[GrowingMediator sharedInstance] performClass:@"TestObjct" action:@"classMethod5:array:dict:" params:@{@"0":@"1", @"1":@[@"1"], @"2":@{@"key":@"value"}}];
//    XCTAssertEqual(array1[0], @"1");
//    XCTAssertEqual(array1[1][0], @"1");
//    XCTAssertEqual(array1[2][@"key"], @"value");
}

- (void)test2MediatorInstanceMethodTest  {
//    TestObjct *obj = [[GrowingMediator sharedInstance] performClass:@"TestObjct" action:@"alloc" params:nil];
//    obj = [[GrowingMediator sharedInstance] performTarget:obj action:@"init" params:nil];
//    
//    [[GrowingMediator sharedInstance] performTarget:obj action:@"instanceMethod1" params:nil];
//    XCTAssertEqual(string1, @"2");
//    BOOL boolRet =     [[GrowingMediator sharedInstance] performTarget:obj action:@"instanceMethod2" params:nil];
//    XCTAssertEqual(boolRet, YES);
//    NSArray *array = [[GrowingMediator sharedInstance] performTarget:obj action:@"instanceMethod3:" params:@{@"0":@{@"key":@"value1"}}];
//    XCTAssertEqual(array[0][@"key"], @"value1");
//    NSDictionary *dict = [[GrowingMediator sharedInstance] performTarget:obj action:@"instanceMethod4:" params:@{@"0":@"haha1"}];;
//    XCTAssertEqual(dict[@"key"], @"haha1");
//    [[GrowingMediator sharedInstance] performTarget:obj action:@"instanceMethod5:array:dict:" params:@{@"0":@"2", @"1":@[@"2"], @"2":@{@"key":@"value1"}}];
//    XCTAssertEqual(array1[0], @"2");
//    XCTAssertEqual(array1[1][0], @"2");
//    XCTAssertEqual(array1[2][@"key"], @"value1");
}



@end
