//
//  GrowingEvent.h
//  GrowingTracker
//
//  Created by GrowingIO on 15/11/27.
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

#import <Foundation/Foundation.h>

static NSString *_Nonnull const kEventTypeKeyClose = @"APP_CLOSED";
static NSString *_Nonnull const kEventTypeKeyVisit = @"VISIT";
static NSString *_Nonnull const kEventTypeKeyVisitor = @"VISITOR_ATTRIBUTES";
static NSString *_Nonnull const kEventTypeKeyCustom = @"CUSTOM";
static NSString *_Nonnull const kEventTypeKeyLoginUserAttributes = @"LOGIN_USER_ATTRIBUTES";

static NSString *_Nonnull const kEventTypeKeyPage = @"PAGE";
static NSString *_Nonnull const kEventTypeKeyPageAttributes = @"PAGE_ATTRIBUTES";
static NSString *_Nonnull const kEventTypeKeyConversionVariable = @"CONVERSION_VARIABLES";

static NSString *_Nonnull const kEventTypeKeyViewClick = @"VIEW_CLICK";
static NSString *_Nonnull const kEventTypeKeyViewChange = @"VIEW_CHANGE";
static NSString *_Nonnull const kEventTypeKeyInputSubmit = @"FORM_SUBMIT";



// event类型定义
#define GROWING_EVENT_LIST(MACRO)                      \
    MACRO(AppLifeCycleAppNewVisit, = 1, @"一次新访问") \
    MACRO(Page, = 2, @"新页面")                        \
    MACRO(PageNewPage, = 20001, @"新页面")             \
    MACRO(PageNewH5Page, , @"新H5页面")                \
    MACRO(PageResendPage, , @"重发页面")               \
    MACRO(UserInteraction, = 3, @"用户操作")           \
    MACRO(ButtonClick, = 30001, @"按钮点击")           \
    MACRO(ButtonTouchDown, , @"按钮按下")              \
    MACRO(ButtonTouchUp, , @"按钮按下并抬起")          \
    MACRO(SegmentControlSelect, , @"多选控件点击")     \
    MACRO(RowSelected, , @"点击一行")                  \
    MACRO(AlertSelected, , @"点击对话框")              \
    MACRO(TapGest, , @"单击")                          \
    MACRO(DoubleTapGest, , @"双击")                    \
    MACRO(LongPressGest, , @"长按")                    \
    MACRO(H5ElementClick, , @"点击H5元素")             \
    MACRO(H5ElementSubmit, , @"H5 Submit 表单")        \
    MACRO(UI, = 4, @"UI更新")                          \
    MACRO(UIPageShow, = 40001, @"新页面显示UI")        \
    MACRO(UIChangeText, , @"文本变更")                 \
    MACRO(UISetText, , @"设置文本")                    \
    MACRO(H5Element, , @"H5元素显示")                  \
    MACRO(H5ElementChangeText, , @"H5文本变更")

#define GROWING_TYPE_MACRO(NAME, ENUMVALUE, DESP) GrowingEventType##NAME ENUMVALUE,

typedef NS_ENUM(NSInteger, GrowingEventType) { GROWING_EVENT_LIST(GROWING_TYPE_MACRO) };

typedef NS_ENUM(NSUInteger, GrowingEventSendPolicy) { GrowingEventSendPolicyNormal, GrowingEventSendPolicyInstant };

@protocol GrowingEventTransformable <NSObject>

@required

- (NSDictionary *_Nonnull)toDictionary;

@end

@protocol GrowingEventCountable <NSObject>

- (NSInteger)nextGlobalSequenceWithBase:(NSInteger)base andStep:(NSInteger)step;
- (NSInteger)nextEventSequenceWithBase:(NSInteger)base andStep:(NSInteger)step;

@end

@protocol GrowingEventSendPolicyDelegate <NSObject>

@required

- (GrowingEventSendPolicy)sendPolicy;

@end

#pragma mark - GrowingEvent

@interface GrowingEvent : NSObject <GrowingEventTransformable, GrowingEventSendPolicyDelegate, GrowingEventCountable>

@property (nonatomic, copy, readonly) NSString *_Nonnull eventTypeKey;
@property (nonatomic, copy, readonly) NSString *_Nonnull domain;
@property (nonatomic, copy, readonly) NSString *_Nullable userId;
@property (nonatomic, copy, readonly) NSString *_Nonnull deviceId;
@property (nonatomic, strong, readonly) NSNumber *_Nonnull appState;
@property (nonatomic, copy, readwrite) NSString *_Nonnull urlScheme;
@property (nonatomic, strong, readonly) NSMutableDictionary *_Nonnull dataDict DEPRECATED_ATTRIBUTE;

@property (nonatomic, copy) NSString *_Nonnull sessionId;
@property (nonatomic, strong) NSNumber *_Nonnull timestamp;
@property (nonatomic, strong) NSNumber *_Nonnull globalSequenceId;
@property (nonatomic, strong) NSNumber *_Nonnull eventSequenceId;

@property (nonatomic, readonly, copy) NSString *_Nonnull uuid;

- (_Nullable instancetype)initWithUUID:(NSString *_Nonnull)uuid
                                  data:(NSDictionary *_Nullable)data NS_DESIGNATED_INITIALIZER;

// internal
- (instancetype _Nonnull)initWithTimestamp:(NSNumber *_Nullable)tm;

@end

@interface GrowingEventPersistence : NSObject

@property (nonatomic, copy, readonly) NSString *_Nonnull eventUUID;
@property (nonatomic, copy, readonly) NSString *_Nonnull eventTypeKey;
@property (nonatomic, copy, readonly) NSString *_Nonnull rawJsonString;

- (instancetype _Nonnull)initWithUUID:(NSString *_Nonnull)uuid
                            eventType:(NSString *_Nonnull)evnetType
                           jsonString:(NSString *_Nonnull)jsonString;

+ (instancetype _Nonnull)persistenceEventWithEvent:(GrowingEvent *_Nonnull)event;

+ (NSArray<NSString *> *_Nonnull)buildRawEventsFromEvents:(NSArray<GrowingEventPersistence *> *_Nonnull)events;

@end
