//
//  GrowingPageEvent+Protobuf.m
//  GrowingAnalytics
//
//  Created by YoloMao on 2021/12/3.
//  Copyright (C) 2021 Beijing Yishu Technology Co., Ltd.
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


#import "GrowingPageEvent+Protobuf.h"
#import "GrowingBaseEvent+Protobuf.h"
#import "GrowingEvent.pbobjc.h"

@implementation GrowingPageEvent (Protobuf)

- (GrowingPBEventV3Dto *)toProtobuf {
    GrowingPBEventV3Dto *dto = [super toProtobuf];
    dto.path = self.pageName;
    dto.orientation = self.orientation;
    dto.title = self.title;
    dto.referralPage = self.referralPage;
    return dto;
}

- (GrowingPBEventType)pbEventType {
    return GrowingPBEventType_Page;
}

@end
