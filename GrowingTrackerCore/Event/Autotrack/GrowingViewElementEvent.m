//
// GrowingViewElementEvent.m
// GrowingAnalytics
//
//  Created by sheng on 2020/11/16.
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

#import "GrowingTrackerCore/Event/Autotrack/GrowingViewElementEvent.h"

@implementation GrowingViewElementEvent

+ (GrowingViewElementBuilder *)builder {
    return [[GrowingViewElementBuilder alloc] init];
}

- (instancetype)initWithBuilder:(GrowingBaseBuilder *)builder {
    if (self = [super initWithBuilder:builder]) {
        GrowingViewElementBuilder *subBuilder = (GrowingViewElementBuilder *)builder;
        _path = subBuilder.path;
        _textValue = subBuilder.textValue;
        _xpath = subBuilder.xpath;
        _xcontent = subBuilder.xcontent;
        int index = subBuilder.index;
        if (index >= 0) {
            // SDK 4.x: 原生需要手动加1，而hybrid、flutter等等跨平台需要自行处理index
            _index = (subBuilder.scene == GrowingEventSceneNative) ? index + 1 : index;
        }
    }
    return self;
}

- (NSDictionary *)toDictionary {
    NSMutableDictionary *dataDictM = [NSMutableDictionary dictionaryWithDictionary:[super toDictionary]];
    dataDictM[@"path"] = self.path;
    dataDictM[@"textValue"] = self.textValue;
    dataDictM[@"xpath"] = self.xpath;
    dataDictM[@"xcontent"] = self.xcontent;
    dataDictM[@"index"] = self.index > 0 ? @(self.index) : nil;
    return dataDictM;
}

@end

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wincomplete-implementation"
@implementation GrowingViewElementBuilder

- (GrowingViewElementBuilder * (^)(NSString *value))setPath {
    return ^(NSString *value) {
        self->_path = value;
        return self;
    };
}

- (GrowingViewElementBuilder * (^)(NSString *value))setTextValue {
    return ^(NSString *value) {
        self->_textValue = value;
        return self;
    };
}

- (GrowingViewElementBuilder * (^)(NSString *value))setXpath {
    return ^(NSString *value) {
        self->_xpath = value;
        return self;
    };
}

- (GrowingViewElementBuilder * (^)(NSString *value))setXcontent {
    return ^(NSString *value) {
        self->_xcontent = value;
        return self;
    };
}

- (GrowingViewElementBuilder * (^)(int value))setIndex {
    return ^(int value) {
        self->_index = value;
        return self;
    };
}

- (GrowingBaseEvent *)build {
    return [[GrowingViewElementEvent alloc] initWithBuilder:self];
}

@end
#pragma clang diagnostic pop
