//
//  NSObject+GrowingHelper.m
//  GrowingTracker
//
//  Created by GrowingIO on 2020/8/4.
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


#import "NSObject+GrowingHelper.h"
#import <objc/runtime.h>

@implementation NSObject (GrowingHelper)

- (NSArray *)growingHelper_getAllProperties {
    
    u_int count;
    objc_property_t *properties  =class_copyPropertyList([self class], &count);
    NSMutableArray *propertiesArray = [NSMutableArray arrayWithCapacity:count];
    for (int i = 0; i < count ; i++) {
        const char* propertyName =property_getName(properties[i]);
        [propertiesArray addObject: [NSString stringWithUTF8String: propertyName]];
    }
    free(properties);
    return propertiesArray.copy;

}

- (NSString *)growingHelper_getNameWithInstance:(id)instance {
    unsigned int numIvars = 0;
    NSString *key = nil;
    Class realClz = object_isClass(self) ? object_getClass(self) : [self class];
    Ivar *ivarList = class_copyIvarList(realClz, &numIvars);
    for(int i = 0; i < numIvars; i++) {
        Ivar thisIvar = ivarList[i];
        const char *type = ivar_getTypeEncoding(thisIvar);
        NSString *stringType = [NSString stringWithCString:type encoding:NSUTF8StringEncoding];
        if (![stringType hasPrefix:@"@"]) {
            continue;
        }
        if ((object_getIvar(self, thisIvar) == instance)) {
            key = [NSString stringWithUTF8String:ivar_getName(thisIvar)];
            break;
        }
    }
    free(ivarList);
    return key;
}

#ifdef DEBUG

- (NSArray*)growingHelper_allMethod
{
    NSMutableArray *ret = [[NSMutableArray alloc ] init];
    
    
    [@[[self class], object_getClass([self class])] enumerateObjectsUsingBlock:^(Class classs, NSUInteger idx, BOOL * _Nonnull stop) {
        unsigned int count = 0;
        Method *methods = class_copyMethodList(classs, &count);
        for (int i = 0 ; i < count; i ++)
        {
            Method m = methods[i];
            
            NSMutableString *str = [[NSMutableString alloc] init];
            [ret addObject:str];
            
            char *tempChar = method_copyReturnType(m);
            if (idx == 0)
            {
                [str appendFormat:@"- (%s)",tempChar];
            }
            else
            {
                [str appendFormat:@"+ (%s)",tempChar];
            }
            free(tempChar);
            
            [str appendFormat:@"%@",NSStringFromSelector(method_getName(m))];
        }
        free(methods);
    }];
    
    return ret;
}

- (NSArray*)growingHelper_allProperty
{
    NSMutableArray *ret = [[NSMutableArray alloc ] init];
    
    
    Class classs = [self class];
    unsigned int count = 0;
    objc_property_t *propertys = class_copyPropertyList(classs, &count);
    for (int i = 0 ; i < count; i ++)
    {
        objc_property_t p = propertys[i];
        
        NSMutableString *str = [[NSMutableString alloc] init];
        [ret addObject:str];

        [str appendFormat:@"@property (%s)",property_getName(p)];
        
        
        unsigned int pcount = 0;
        objc_property_attribute_t *attrs = property_copyAttributeList(p, &pcount);
        for (int j = 0 ; j < pcount ; j++)
        {
            objc_property_attribute_t attr = attrs[j];
            [str appendFormat:@"%s:%s   ",attr.name,attr.value];
        }
    }
    free(propertys);
    return ret;
}

- (NSArray*)growingHelper_allIVar
{
    NSMutableArray *ret = [[NSMutableArray alloc ] init];
    
    Class classs = [self class];
    unsigned int count = 0;
    Ivar *vars = class_copyIvarList(classs, &count);
    for (int i = 0 ; i < count; i ++)
    {
        Ivar v = vars[i];
        [ret addObject:[NSString stringWithFormat:@"%s",ivar_getName(v)]];
    }
    free(vars);
    return ret;
}

#endif

@end
