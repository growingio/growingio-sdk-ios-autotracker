//
// GrowingDataCompression.m
// Pods
//
//  Created by YoloMao on 2021/6/24.
//  Copyright (C) 2017 Beijing Yishu Technology Co., Ltd.
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


#import "GrowingDataCompression.h"
#import "GrowingLZ4.h"

@GrowingService(GrowingCompressService, GrowingDataCompression)

@implementation GrowingDataCompression

- (NSData *_Nonnull)compressedEventData:(NSData *_Nonnull)data {
    void *out_buff = malloc(LZ4_compressBound((int)data.length));
    int out_size = GROW_LZ4_compress(data.bytes, out_buff, (int)data.length);
    if (out_size < 0) {
        free(out_buff);
        return data;
    }

    return [[NSData alloc] initWithBytesNoCopy:out_buff length:out_size freeWhenDone:YES];
}

@end
