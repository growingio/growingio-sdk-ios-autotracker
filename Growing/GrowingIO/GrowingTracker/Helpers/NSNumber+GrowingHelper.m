//
//  NSNumber+GrowingHelper.m
//  GrowingTracker
//
//  Created by GrowingIO on 16/4/16.
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


#import "NSNumber+GrowingHelper.h"

@implementation NSNumber (GrowingHelper)

+ (void)growingHelper_readableBigNumber:(NSInteger)n
                              outNumber:(NSString *__autoreleasing *)outNumber
                          outUnitString:(NSString *__autoreleasing *)outUnitString
{
    double number = 0.0;
    NSString * digits = nil;
    NSString * unit = nil;
    double K = 1000.0;
    double M = K * K;
    double G = K * K * K;
    if (n < K)
    {
        digits = [NSString stringWithFormat:@"%ld", (long)n];
    }
    else if (n < M)
    {
        number = n / K;
        unit = @"k";
    }
    else if (n < G)
    {
        number = n / M;
        unit = @"m";
    }
    else
    {
        number = n / G;
        unit = @"g";
    }
    if (digits == nil)
    {
        NSString * format = nil;
        if (number < 10)
        {
            format = @"%1.2lf";
        }
        else if (number < 100)
        {
            format = @"%2.1lf";
        }
        else if (number < 1000)
        {
            format = @"%3.0lf";
        }
        else
        {
            format = @"%.0lf";
        }
        digits = [NSString stringWithFormat:format, number];
    }
    
    
    if (outNumber)
    {
        *outNumber = digits;
    }
    if (outUnitString && unit)
    {
        *outUnitString = unit;
    }
}

@end
