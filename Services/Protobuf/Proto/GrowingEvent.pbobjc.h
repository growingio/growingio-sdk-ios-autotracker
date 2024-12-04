// Generated by the protocol buffer compiler.  DO NOT EDIT!
// source: event_v3.proto

// This CPP symbol can be defined to use imports that match up to the framework
// imports needed when using CocoaPods.
#if !defined(GPB_USE_PROTOBUF_FRAMEWORK_IMPORTS)
 #define GPB_USE_PROTOBUF_FRAMEWORK_IMPORTS 0
#endif

#if GPB_USE_PROTOBUF_FRAMEWORK_IMPORTS
 #import <Protobuf/GPBProtocolBuffers.h>
#else
 #import "GPBProtocolBuffers.h"
#endif

#if GOOGLE_PROTOBUF_OBJC_VERSION < 30002
#error This file was generated by a newer version of protoc which is incompatible with your Protocol Buffer library sources.
#endif
#if 30002 < GOOGLE_PROTOBUF_OBJC_MIN_SUPPORTED_VERSION
#error This file was generated by an older version of protoc which is incompatible with your Protocol Buffer library sources.
#endif

// @@protoc_insertion_point(imports)

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"

CF_EXTERN_C_BEGIN

@class GrowingPBEventV3Dto;
@class GrowingPBResourceItem;

NS_ASSUME_NONNULL_BEGIN

#pragma mark - Enum GrowingPBEventType

typedef GPB_ENUM(GrowingPBEventType) {
  /**
   * Value used if any message's field encounters a value that is not defined
   * by this enum. The message will also have C functions to get/set the rawValue
   * of the field.
   **/
  GrowingPBEventType_GPBUnrecognizedEnumeratorValue = kGPBUnrecognizedEnumeratorValue,
  GrowingPBEventType_Visit = 0,
  GrowingPBEventType_Custom = 1,
  GrowingPBEventType_VisitorAttributes = 2,
  GrowingPBEventType_LoginUserAttributes = 3,
  GrowingPBEventType_ConversionVariables = 4,
  GrowingPBEventType_AppClosed = 5,
  GrowingPBEventType_Page = 6,
  GrowingPBEventType_PageAttributes = 7,
  GrowingPBEventType_ViewClick = 8,
  GrowingPBEventType_ViewChange = 9,
  GrowingPBEventType_FormSubmit = 10,
  GrowingPBEventType_Activate = 11,
};

GPBEnumDescriptor *GrowingPBEventType_EnumDescriptor(void);

/**
 * Checks to see if the given value is defined by the enum or was not known at
 * the time this source was generated.
 **/
BOOL GrowingPBEventType_IsValidValue(int32_t value);

#pragma mark - GrowingPBEventV3Root

/**
 * Exposes the extension registry for this file.
 *
 * The base class provides:
 * @code
 *   + (GPBExtensionRegistry *)extensionRegistry;
 * @endcode
 * which is a @c GPBExtensionRegistry that includes all the extensions defined by
 * this file and all files that it depends on.
 **/
@interface GrowingPBEventV3Root : GPBRootObject
@end

#pragma mark - GrowingPBEventV3Dto

typedef GPB_ENUM(GrowingPBEventV3Dto_FieldNumber) {
  GrowingPBEventV3Dto_FieldNumber_DeviceId = 1,
  GrowingPBEventV3Dto_FieldNumber_UserId = 2,
  GrowingPBEventV3Dto_FieldNumber_SessionId = 4,
  GrowingPBEventV3Dto_FieldNumber_DataSourceId = 5,
  GrowingPBEventV3Dto_FieldNumber_EventType = 6,
  GrowingPBEventV3Dto_FieldNumber_Platform = 7,
  GrowingPBEventV3Dto_FieldNumber_Timestamp = 8,
  GrowingPBEventV3Dto_FieldNumber_Domain = 9,
  GrowingPBEventV3Dto_FieldNumber_Path = 10,
  GrowingPBEventV3Dto_FieldNumber_Query = 11,
  GrowingPBEventV3Dto_FieldNumber_Title = 12,
  GrowingPBEventV3Dto_FieldNumber_ReferralPage = 13,
  GrowingPBEventV3Dto_FieldNumber_EventSequenceId = 15,
  GrowingPBEventV3Dto_FieldNumber_ScreenHeight = 16,
  GrowingPBEventV3Dto_FieldNumber_ScreenWidth = 17,
  GrowingPBEventV3Dto_FieldNumber_Language = 18,
  GrowingPBEventV3Dto_FieldNumber_SdkVersion = 19,
  GrowingPBEventV3Dto_FieldNumber_AppVersion = 20,
  GrowingPBEventV3Dto_FieldNumber_ExtraSdk = 21,
  GrowingPBEventV3Dto_FieldNumber_EventName = 22,
  GrowingPBEventV3Dto_FieldNumber_Attributes = 24,
  GrowingPBEventV3Dto_FieldNumber_ResourceItem = 25,
  GrowingPBEventV3Dto_FieldNumber_ProtocolType = 26,
  GrowingPBEventV3Dto_FieldNumber_TextValue = 27,
  GrowingPBEventV3Dto_FieldNumber_Xpath = 28,
  GrowingPBEventV3Dto_FieldNumber_Index = 29,
  GrowingPBEventV3Dto_FieldNumber_Hyperlink = 30,
  GrowingPBEventV3Dto_FieldNumber_URLScheme = 31,
  GrowingPBEventV3Dto_FieldNumber_AppState = 32,
  GrowingPBEventV3Dto_FieldNumber_NetworkState = 33,
  GrowingPBEventV3Dto_FieldNumber_AppChannel = 34,
  GrowingPBEventV3Dto_FieldNumber_PageName = 35,
  GrowingPBEventV3Dto_FieldNumber_PlatformVersion = 36,
  GrowingPBEventV3Dto_FieldNumber_DeviceBrand = 37,
  GrowingPBEventV3Dto_FieldNumber_DeviceModel = 38,
  GrowingPBEventV3Dto_FieldNumber_DeviceType = 39,
  GrowingPBEventV3Dto_FieldNumber_OperatingSystem = 40,
  GrowingPBEventV3Dto_FieldNumber_AppName = 42,
  GrowingPBEventV3Dto_FieldNumber_Latitude = 44,
  GrowingPBEventV3Dto_FieldNumber_Longitude = 45,
  GrowingPBEventV3Dto_FieldNumber_Imei = 46,
  GrowingPBEventV3Dto_FieldNumber_AndroidId = 47,
  GrowingPBEventV3Dto_FieldNumber_Oaid = 48,
  GrowingPBEventV3Dto_FieldNumber_GoogleAdvertisingId = 49,
  GrowingPBEventV3Dto_FieldNumber_Idfa = 50,
  GrowingPBEventV3Dto_FieldNumber_Idfv = 51,
  GrowingPBEventV3Dto_FieldNumber_Orientation = 52,
  GrowingPBEventV3Dto_FieldNumber_ProjectKey = 53,
  GrowingPBEventV3Dto_FieldNumber_SendTime = 54,
  GrowingPBEventV3Dto_FieldNumber_UserKey = 55,
  GrowingPBEventV3Dto_FieldNumber_Xcontent = 56,
  GrowingPBEventV3Dto_FieldNumber_TimezoneOffset = 57,
};

@interface GrowingPBEventV3Dto : GPBMessage

@property(nonatomic, readwrite, copy, null_resettable) NSString *deviceId;

@property(nonatomic, readwrite, copy, null_resettable) NSString *userId;

@property(nonatomic, readwrite, copy, null_resettable) NSString *sessionId;

@property(nonatomic, readwrite, copy, null_resettable) NSString *dataSourceId;

@property(nonatomic, readwrite) GrowingPBEventType eventType;

@property(nonatomic, readwrite, copy, null_resettable) NSString *platform;

@property(nonatomic, readwrite) int64_t timestamp;

@property(nonatomic, readwrite, copy, null_resettable) NSString *domain;

@property(nonatomic, readwrite, copy, null_resettable) NSString *path;

@property(nonatomic, readwrite, copy, null_resettable) NSString *query;

@property(nonatomic, readwrite, copy, null_resettable) NSString *title;

@property(nonatomic, readwrite, copy, null_resettable) NSString *referralPage;

@property(nonatomic, readwrite) int32_t eventSequenceId;

@property(nonatomic, readwrite) int32_t screenHeight;

@property(nonatomic, readwrite) int32_t screenWidth;

@property(nonatomic, readwrite, copy, null_resettable) NSString *language;

@property(nonatomic, readwrite, copy, null_resettable) NSString *sdkVersion;

@property(nonatomic, readwrite, copy, null_resettable) NSString *appVersion;

@property(nonatomic, readwrite, strong, null_resettable) NSMutableDictionary<NSString*, NSString*> *extraSdk;
/** The number of items in @c extraSdk without causing the array to be created. */
@property(nonatomic, readonly) NSUInteger extraSdk_Count;

@property(nonatomic, readwrite, copy, null_resettable) NSString *eventName;

@property(nonatomic, readwrite, strong, null_resettable) NSMutableDictionary<NSString*, NSString*> *attributes;
/** The number of items in @c attributes without causing the array to be created. */
@property(nonatomic, readonly) NSUInteger attributes_Count;

@property(nonatomic, readwrite, strong, null_resettable) GrowingPBResourceItem *resourceItem;
/** Test to see if @c resourceItem has been set. */
@property(nonatomic, readwrite) BOOL hasResourceItem;

@property(nonatomic, readwrite, copy, null_resettable) NSString *protocolType;

@property(nonatomic, readwrite, copy, null_resettable) NSString *textValue;

@property(nonatomic, readwrite, copy, null_resettable) NSString *xpath;

@property(nonatomic, readwrite) int32_t index;

@property(nonatomic, readwrite, copy, null_resettable) NSString *hyperlink;

@property(nonatomic, readwrite, copy, null_resettable) NSString *URLScheme;

@property(nonatomic, readwrite, copy, null_resettable) NSString *appState;

@property(nonatomic, readwrite, copy, null_resettable) NSString *networkState;

@property(nonatomic, readwrite, copy, null_resettable) NSString *appChannel;

/** useless */
@property(nonatomic, readwrite, copy, null_resettable) NSString *pageName;

@property(nonatomic, readwrite, copy, null_resettable) NSString *platformVersion;

@property(nonatomic, readwrite, copy, null_resettable) NSString *deviceBrand;

@property(nonatomic, readwrite, copy, null_resettable) NSString *deviceModel;

@property(nonatomic, readwrite, copy, null_resettable) NSString *deviceType;

@property(nonatomic, readwrite, copy, null_resettable) NSString *operatingSystem;

@property(nonatomic, readwrite, copy, null_resettable) NSString *appName;

@property(nonatomic, readwrite) double latitude;

@property(nonatomic, readwrite) double longitude;

@property(nonatomic, readwrite, copy, null_resettable) NSString *imei;

@property(nonatomic, readwrite, copy, null_resettable) NSString *androidId;

@property(nonatomic, readwrite, copy, null_resettable) NSString *oaid;

@property(nonatomic, readwrite, copy, null_resettable) NSString *googleAdvertisingId;

@property(nonatomic, readwrite, copy, null_resettable) NSString *idfa;

@property(nonatomic, readwrite, copy, null_resettable) NSString *idfv;

@property(nonatomic, readwrite, copy, null_resettable) NSString *orientation;

@property(nonatomic, readwrite, copy, null_resettable) NSString *projectKey;

@property(nonatomic, readwrite) int64_t sendTime;

@property(nonatomic, readwrite, copy, null_resettable) NSString *userKey;

@property(nonatomic, readwrite, copy, null_resettable) NSString *xcontent;

@property(nonatomic, readwrite, copy, null_resettable) NSString *timezoneOffset;

@end

/**
 * Fetches the raw value of a @c GrowingPBEventV3Dto's @c eventType property, even
 * if the value was not defined by the enum at the time the code was generated.
 **/
int32_t GrowingPBEventV3Dto_EventType_RawValue(GrowingPBEventV3Dto *message);
/**
 * Sets the raw value of an @c GrowingPBEventV3Dto's @c eventType property, allowing
 * it to be set to a value that was not defined by the enum at the time the code
 * was generated.
 **/
void SetGrowingPBEventV3Dto_EventType_RawValue(GrowingPBEventV3Dto *message, int32_t value);

#pragma mark - GrowingPBResourceItem

typedef GPB_ENUM(GrowingPBResourceItem_FieldNumber) {
  GrowingPBResourceItem_FieldNumber_Id_p = 1,
  GrowingPBResourceItem_FieldNumber_Key = 2,
  GrowingPBResourceItem_FieldNumber_Attributes = 3,
};

@interface GrowingPBResourceItem : GPBMessage

@property(nonatomic, readwrite, copy, null_resettable) NSString *id_p;

@property(nonatomic, readwrite, copy, null_resettable) NSString *key;

@property(nonatomic, readwrite, strong, null_resettable) NSMutableDictionary<NSString*, NSString*> *attributes;
/** The number of items in @c attributes without causing the array to be created. */
@property(nonatomic, readonly) NSUInteger attributes_Count;

@end

#pragma mark - GrowingPBEventV3List

typedef GPB_ENUM(GrowingPBEventV3List_FieldNumber) {
  GrowingPBEventV3List_FieldNumber_ValuesArray = 1,
};

@interface GrowingPBEventV3List : GPBMessage

@property(nonatomic, readwrite, strong, null_resettable) NSMutableArray<GrowingPBEventV3Dto*> *valuesArray;
/** The number of items in @c valuesArray without causing the array to be created. */
@property(nonatomic, readonly) NSUInteger valuesArray_Count;

@end

NS_ASSUME_NONNULL_END

CF_EXTERN_C_END

#pragma clang diagnostic pop

// @@protoc_insertion_point(global_scope)
