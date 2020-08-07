//
//  NSURLSession+TestHook.h
//  GrowingSDKTest
//
//  Created by smart on 2018/3/21.
//  Copyright © 2018年 GrowingIO. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^GrowCompletionHandler)(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error);

@interface NSURLSession (TestHook)

+ (void)setTestHandler:(GrowCompletionHandler _Nullable)handler forKey:(NSString *_Nullable)key;

+ (GrowCompletionHandler _Nullable)testHandlerForKey:(NSString *_Nullable)key;

+ (void)setURLSuccessArray:(NSMutableArray<NSURL *> *_Nullable)array;

+ (NSMutableArray<NSURL *> *_Nullable)URLSuccessArray;

@end
