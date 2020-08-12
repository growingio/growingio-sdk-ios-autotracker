//
//  GIODataProcessOperation.m
//  GrowingExample
//
//  Created by GrowingIO on 2018/6/4.
//  Copyright (C) 2018 Beijing Yishu Technology Co., Ltd.
//

#import "GIODataProcessOperation.h"
static NSString *const kGrowingTouchState = @"GIO_TOUCH_DEMO_gtouch_state";

@implementation GIODataProcessOperation

//NSDictionary转NSString
+ (NSString *)convertToJsonStringFromJSON:(id)infoDict {
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:infoDict
                                                       options:NSJSONWritingPrettyPrinted // Pass 0 if you don't care about the readability of the generated string
                                                         error:&error];
    
    NSString *jsonString = @"";
    
    if (! jsonData) {
        NSLog(@"Got an error: %@", error);
    }else
    {
        jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    jsonString = [jsonString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];  //去除掉首尾的空白字符和换行字符
    [jsonString stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    
    return jsonString;
}
//字符串转NSDictionary
+ (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString {
    if (jsonString == nil) {
        return nil;
    }
    
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"JSON Test:%@",jsonData);
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&err];
    if(err) {
        NSLog(@"json解析失败：%@",err);
        return nil;
    }
    return dic;
}

//字符串解析成NSDictionary
+(NSDictionary *)transStringToDic:(NSString *) transtr {
    if (transtr.length == 0) {
        return nil;
    }
    NSMutableDictionary * tvardic = [NSMutableDictionary dictionaryWithCapacity:10];
    NSString *newstr=[transtr substringWithRange:NSMakeRange(1,transtr.length-2)];
    NSLog(@"##newStr##:%@",transtr);
    if ((![transtr containsString:@","] ) && (![transtr containsString:@":"])) {
        //空字典
        tvardic = [NSMutableDictionary dictionary];
        NSLog(@"Translate to Empty dict!");
    } else {
        NSArray *nsarr=[newstr componentsSeparatedByString:@","];
        for (int i=0;i<nsarr.count;i++) {
            NSArray *strarr=[[nsarr objectAtIndex:i] componentsSeparatedByString:@":"];
            NSString *ckey=[strarr objectAtIndex:0];
            NSString *cvalue=[strarr objectAtIndex:1];
            [tvardic setObject:[cvalue substringWithRange:NSMakeRange(1,cvalue.length-2)] forKey:[ckey substringWithRange:NSMakeRange(1,ckey.length-2)]];
        }
    }
    return tvardic;
}

//将数字型字符串转换成数值
+(NSDictionary *)transStringToData:(NSString *)datastr {
    NSMutableDictionary * tvardic = [NSMutableDictionary dictionaryWithCapacity:10];
    NSString *chtnum = [datastr stringByTrimmingCharactersInSet:[NSCharacterSet decimalDigitCharacterSet]];
    
    if(chtnum.length==1 && [datastr containsString:@"."]) {
        //浮点型
        float ftnum=[datastr floatValue];
        //NSLog(@"Translate to float:%f",ftnum);
        NSNumber *floatNum = [NSNumber numberWithFloat:ftnum];
        [tvardic setObject:floatNum forKey:@"DataValue"];
    
    } else if (chtnum.length==0) {
      
        if (datastr.length==0) {
            //字符串为空
            [tvardic setObject:@"" forKey:@"DataValue"];
            NSLog(@"Data trans is empty!");
        } else {
            //整形
            int itnum=[datastr intValue];
            NSNumber *IntNum = [NSNumber numberWithInt:itnum];
            [tvardic setObject:IntNum forKey:@"DataValue"];
            NSLog(@"change string to int %@",IntNum);
        }
    } else {
        //字符串
         [tvardic setObject:datastr forKey:@"DataValue"];
    }
    return tvardic;
}

+ (NSString *)randomStringWithLength:(int)length {
    NSString *letters = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    NSMutableString *randomString = [[NSMutableString alloc] initWithCapacity:length];
    for(NSInteger i = 0; i < length; i++) {
        uint32_t ln = (uint32_t)letters.length;
        uint32_t rand = arc4random_uniform(ln);
        [randomString appendFormat:@"%C", [letters characterAtIndex:rand]];
    }
    return randomString;
}

+ (int)getRandomLengthFrom:(int)from to:(int)to {
    return (int)(from + (arc4random() % (to - from + 1)));
}

+ (void)saveGTouchEnableState:(BOOL)enable {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setBool:enable forKey:kGrowingTouchState];
    [userDefaults synchronize];
}

+ (BOOL)getGTouchEnableState {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    BOOL enable = [[userDefaults objectForKey:kGrowingTouchState] boolValue];
    return enable;
}

@end
