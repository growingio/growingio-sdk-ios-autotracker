//
//  GrowingEventOptions.m
//  GrowingTracker
//
//  Created by GrowingIO on 2020/4/14.
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


#import "GrowingEventOptions.h"
#import "GrowingFileStorage.h"
#import "GrowingDispatchManager.h"
#import "GrowingGlobal.h"
#import "GrowingDeviceInfo.h"
#import "NSString+GrowingHelper.h"
#import "GrowingInstance.h"
#import "GrowingNetworkConfig.h"

@interface GrowingEventOptions ()

@property (nonatomic, strong) NSOperationQueue *fetchOptionsQueue;
@property (nonatomic, strong) NSURL *optionsURL;

@end

@implementation GrowingEventOptions

- (void)readEventOptions {
    NSString * contentKey = @"white_list_and_options";
    NSString * etagKey = @"white_list_and_options_etag";
    
    GrowingFileStorage *whiteListStorage = [[GrowingFileStorage alloc] initWithName:@"config"];
    NSDictionary * content = [whiteListStorage dictionaryForKey:contentKey];
    NSString * etag = [whiteListStorage stringForKey:etagKey];
    
    [self readOptions_unsafe:content];
    
    __weak GrowingEventOptions *weakSelf = self;

    [GrowingDispatchManager dispatchInLowThread:^{
        
        GrowingEventOptions *strongSelf = weakSelf;

        NSURL * url = strongSelf.optionsURL;
        if (url == nil) { return; }
        
        NSMutableURLRequest * urlRequest = [NSMutableURLRequest requestWithURL:url];
        urlRequest.cachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
        //请求超时设置15s
        [urlRequest setTimeoutInterval:15];
        if (etag.length > 0) {
            [urlRequest setValue:etag forHTTPHeaderField:@"If-None-Match"];
        }
        [urlRequest setValue:@"gzip" forHTTPHeaderField:@"Accept-Encoding"];
        
        __weak GrowingEventOptions *weakSelff = strongSelf;
        [NSURLConnection sendAsynchronousRequest:urlRequest
                                           queue:self.fetchOptionsQueue
                               completionHandler:^(NSURLResponse * response, NSData * data, NSError * connectionError) {
            
            GrowingEventOptions *strongSelf = weakSelff;
            
            // called in main thread
            if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
                NSHTTPURLResponse * httpResponse = (NSHTTPURLResponse *)response;
                NSInteger statusCode = httpResponse.statusCode;
                
                // 304 = NOT MODIFIED
                if (statusCode == 304) {
                    return;
                } else if (statusCode == 200) {
                    NSString * string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                    NSDictionary * content = [string growingHelper_dictionaryObject];
                    NSString * etag = [httpResponse.allHeaderFields valueForKey:@"Etag"];
                    // assign to memory
                    [strongSelf readOptions_unsafe:content];
                    
                    [GrowingDispatchManager dispatchInLowThread:^{
                        [whiteListStorage setDictionary:content forKey:contentKey];
                        [whiteListStorage setString:etag forKey:etagKey];
                    }];
                }
            }
        }];
    }];
    
    [self performSelector:@selector(custom_cancel)
               withObject:nil
               afterDelay:15];
}

- (void)custom_cancel {
    if(self.fetchOptionsQueue) {
       [self.fetchOptionsQueue cancelAllOperations];
    }
}

- (void)readOptions_unsafe:(NSDictionary *)dict {
    if (dict.count == 0) {
        return;
    }

    // runs in main thread
    NSNumber * allDisabled = dict[@"disabled"];
    if ([allDisabled isKindOfClass:[NSNumber class]]) {
        [Growing setDataCollectionEnabled:!allDisabled.boolValue];
    }

    NSNumber * sampling = dict[@"sampling"];
    if ([sampling isKindOfClass:[NSNumber class]]) {
        [GrowingInstance updateSampling:sampling.floatValue];
    }
}

#pragma mark Lozy Load

- (NSOperationQueue *)fetchOptionsQueue {

    if (!_fetchOptionsQueue) {
        _fetchOptionsQueue = [[NSOperationQueue alloc] init];
        _fetchOptionsQueue.name = @"growing.fetchOptions.queue";
    }
    return _fetchOptionsQueue;
}

- (NSURL *)optionsURL {
    if (!_optionsURL) {
        
        unsigned long long timestamp = [GROWGetTimestamp() unsignedLongLongValue];
        NSString * ai = [GrowingInstance sharedInstance].projectID;
        if (ai.length == 0) {
            return nil;
        }
        NSString * d = [GrowingDeviceInfo currentDeviceInfo].bundleID;
        NSString * cv = [GrowingDeviceInfo currentDeviceInfo].appShortVersion;
        NSString * av = [Growing getVersion];
        NSString * signText = [NSString stringWithFormat:@"api=/products/%@/ios/%@/settings&av=%@&cv=%@&timestamp=%llu",
                               ai, d, av, cv,timestamp];
        NSString * hash = signText.growingHelper_sha1;
        
        NSString * urlString = [NSString stringWithFormat:@"%@/products/%@/ios/%@/settings?&av=%@&cv=%@&timestamp=%llu&sign=%@",
                                [GrowingNetworkConfig.sharedInstance tagsHost], ai, d,  av, cv,timestamp, hash];
        
        _optionsURL = [NSURL URLWithString:urlString];
    }
    return _optionsURL;;
}

@end
