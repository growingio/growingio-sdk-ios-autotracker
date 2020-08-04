//
//  GIODataProcessOperation.h
//  GrowingIOTest
//
//  Created by GrowingIO on 2018/6/4.
//  Copyright © 2018年 GrowingIO. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GIODataProcessOperation : NSObject
//NSDictionary转NSString
+ (NSString *)convertToJsonStringFromJSON:(id)infoDict;
//字符串转NSDictionary
+ (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString;
//字符串解析成NSDictionary
+ (NSDictionary *)transStringToDic:(NSString *) transtr;
//将数字型字符串转换成数值
+ (NSDictionary *)transStringToData:(NSString *)datastr;

+ (NSString *)randomStringWithLength:(int)length;
+ (int)getRandomLengthFrom:(int)from to:(int)to;

+ (void)saveGTouchEnableState:(BOOL)enable;
+ (BOOL)getGTouchEnableState;

@end
