//
// HTTPStubsHelper.m
// ExampleTests
//
//  Created by GrowingIO on 11/25/20.
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


#import "HTTPStubsHelper.h"

@implementation HTTPStubsHelper


-(void)stubRequests{
    [HTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest * _Nonnull request) {
        return [request.URL.host isEqualToString:@"run.mocky.io"];
    } withStubResponse:^HTTPStubsResponse * _Nonnull(NSURLRequest * _Nonnull request) {
        // NSArray *array = @[@"Hello", @"world"];
        // NSLog(@"testbody %@",[request OHHTTPStubs_HTTPBody]);
        NSData* stubData = [@"hello world" dataUsingEncoding:NSUTF8StringEncoding];
        
        return [HTTPStubsResponse responseWithData:stubData statusCode:205 headers:nil];
    }];
};

-(NSArray *)checkEvents{
    
    
    [HTTPStubs onStubActivation:^(NSURLRequest * _Nonnull request, id<HTTPStubsDescriptor>  _Nonnull stub, HTTPStubsResponse * _Nonnull responseStub)   {
        self.array =[NSJSONSerialization JSONObjectWithData:request.OHHTTPStubs_HTTPBody options:0 error:NULL];
        
        NSLog(@"[OHHTTPStubs] Request boby is  %@ ", self.array[0]);
        }];
    
    return self.array;
};

@end
