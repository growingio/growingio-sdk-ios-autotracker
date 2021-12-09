// Generated by the protocol buffer compiler.  DO NOT EDIT!
// source: event_v3.proto

// This CPP symbol can be defined to use imports that match up to the framework
// imports needed when using CocoaPods.
#if !defined(GPB_USE_PROTOBUF_FRAMEWORK_IMPORTS)
 #define GPB_USE_PROTOBUF_FRAMEWORK_IMPORTS 0
#endif

#if GPB_USE_PROTOBUF_FRAMEWORK_IMPORTS
 #import <Protobuf/GPBProtocolBuffers_RuntimeSupport.h>
#else
 #import "GPBProtocolBuffers_RuntimeSupport.h"
#endif

#import <stdatomic.h>

#import "GrowingEvent.pbobjc.h"
// @@protoc_insertion_point(imports)

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
#pragma clang diagnostic ignored "-Wdollar-in-identifier-extension"

#pragma mark - Objective C Class declarations
// Forward declarations of Objective C classes that we can use as
// static values in struct initializers.
// We don't use [Foo class] because it is not a static value.
GPBObjCClassDeclaration(GrowingPBEventV3Dto);
GPBObjCClassDeclaration(GrowingPBResourceItem);

#pragma mark - GrowingPBEventV3Root

@implementation GrowingPBEventV3Root

// No extensions in the file and no imports, so no need to generate
// +extensionRegistry.

@end

#pragma mark - GrowingPBEventV3Root_FileDescriptor

static GPBFileDescriptor *GrowingPBEventV3Root_FileDescriptor(void) {
  // This is called by +initialize so there is no need to worry
  // about thread safety of the singleton.
  static GPBFileDescriptor *descriptor = NULL;
  if (!descriptor) {
    GPB_DEBUG_CHECK_RUNTIME_VERSIONS();
    descriptor = [[GPBFileDescriptor alloc] initWithPackage:@"com.growingio.database"
                                                 objcPrefix:@"GrowingPB"
                                                     syntax:GPBFileSyntaxProto3];
  }
  return descriptor;
}

#pragma mark - Enum GrowingPBEventType

GPBEnumDescriptor *GrowingPBEventType_EnumDescriptor(void) {
  static _Atomic(GPBEnumDescriptor*) descriptor = nil;
  if (!descriptor) {
    static const char *valueNames =
        "Visit\000Custom\000VisitorAttributes\000LoginUser"
        "Attributes\000ConversionVariables\000AppClosed"
        "\000Page\000PageAttributes\000ViewClick\000ViewChang"
        "e\000FormSubmit\000";
    static const int32_t values[] = {
        GrowingPBEventType_Visit,
        GrowingPBEventType_Custom,
        GrowingPBEventType_VisitorAttributes,
        GrowingPBEventType_LoginUserAttributes,
        GrowingPBEventType_ConversionVariables,
        GrowingPBEventType_AppClosed,
        GrowingPBEventType_Page,
        GrowingPBEventType_PageAttributes,
        GrowingPBEventType_ViewClick,
        GrowingPBEventType_ViewChange,
        GrowingPBEventType_FormSubmit,
    };
    GPBEnumDescriptor *worker =
        [GPBEnumDescriptor allocDescriptorForName:GPBNSStringifySymbol(GrowingPBEventType)
                                       valueNames:valueNames
                                           values:values
                                            count:(uint32_t)(sizeof(values) / sizeof(int32_t))
                                     enumVerifier:GrowingPBEventType_IsValidValue];
    GPBEnumDescriptor *expected = nil;
    if (!atomic_compare_exchange_strong(&descriptor, &expected, worker)) {
      [worker release];
    }
  }
  return descriptor;
}

BOOL GrowingPBEventType_IsValidValue(int32_t value__) {
  switch (value__) {
    case GrowingPBEventType_Visit:
    case GrowingPBEventType_Custom:
    case GrowingPBEventType_VisitorAttributes:
    case GrowingPBEventType_LoginUserAttributes:
    case GrowingPBEventType_ConversionVariables:
    case GrowingPBEventType_AppClosed:
    case GrowingPBEventType_Page:
    case GrowingPBEventType_PageAttributes:
    case GrowingPBEventType_ViewClick:
    case GrowingPBEventType_ViewChange:
    case GrowingPBEventType_FormSubmit:
      return YES;
    default:
      return NO;
  }
}

#pragma mark - GrowingPBEventV3Dto

@implementation GrowingPBEventV3Dto

@dynamic deviceId;
@dynamic userId;
@dynamic gioId;
@dynamic sessionId;
@dynamic dataSourceId;
@dynamic eventType;
@dynamic platform;
@dynamic timestamp;
@dynamic domain;
@dynamic path;
@dynamic query;
@dynamic title;
@dynamic referralPage;
@dynamic globalSequenceId;
@dynamic eventSequenceId;
@dynamic screenHeight;
@dynamic screenWidth;
@dynamic language;
@dynamic sdkVersion;
@dynamic appVersion;
@dynamic extraSdk, extraSdk_Count;
@dynamic eventName;
@dynamic pageShowTimestamp;
@dynamic attributes, attributes_Count;
@dynamic hasResourceItem, resourceItem;
@dynamic protocolType;
@dynamic textValue;
@dynamic xpath;
@dynamic index;
@dynamic hyperlink;
@dynamic URLScheme;
@dynamic appState;
@dynamic networkState;
@dynamic appChannel;
@dynamic pageName;
@dynamic platformVersion;
@dynamic deviceBrand;
@dynamic deviceModel;
@dynamic deviceType;
@dynamic operatingSystem;
@dynamic appName;
@dynamic latitude;
@dynamic longitude;
@dynamic imei;
@dynamic androidId;
@dynamic oaid;
@dynamic googleAdvertisingId;
@dynamic idfa;
@dynamic idfv;
@dynamic orientation;
@dynamic projectKey;
@dynamic sendTime;
@dynamic userKey;

typedef struct GrowingPBEventV3Dto__storage_ {
  uint32_t _has_storage_[2];
  GrowingPBEventType eventType;
  int32_t eventSequenceId;
  int32_t screenHeight;
  int32_t screenWidth;
  int32_t index;
  NSString *deviceId;
  NSString *userId;
  NSString *gioId;
  NSString *sessionId;
  NSString *dataSourceId;
  NSString *platform;
  NSString *domain;
  NSString *path;
  NSString *query;
  NSString *title;
  NSString *referralPage;
  NSString *language;
  NSString *sdkVersion;
  NSString *appVersion;
  NSMutableDictionary *extraSdk;
  NSString *eventName;
  NSMutableDictionary *attributes;
  GrowingPBResourceItem *resourceItem;
  NSString *protocolType;
  NSString *textValue;
  NSString *xpath;
  NSString *hyperlink;
  NSString *URLScheme;
  NSString *appState;
  NSString *networkState;
  NSString *appChannel;
  NSString *pageName;
  NSString *platformVersion;
  NSString *deviceBrand;
  NSString *deviceModel;
  NSString *deviceType;
  NSString *operatingSystem;
  NSString *appName;
  NSString *imei;
  NSString *androidId;
  NSString *oaid;
  NSString *googleAdvertisingId;
  NSString *idfa;
  NSString *idfv;
  NSString *orientation;
  NSString *projectKey;
  NSString *userKey;
  int64_t timestamp;
  int64_t globalSequenceId;
  int64_t pageShowTimestamp;
  double latitude;
  double longitude;
  int64_t sendTime;
} GrowingPBEventV3Dto__storage_;

// This method is threadsafe because it is initially called
// in +initialize for each subclass.
+ (GPBDescriptor *)descriptor {
  static GPBDescriptor *descriptor = nil;
  if (!descriptor) {
    static GPBMessageFieldDescription fields[] = {
      {
        .name = "deviceId",
        .dataTypeSpecific.clazz = Nil,
        .number = GrowingPBEventV3Dto_FieldNumber_DeviceId,
        .hasIndex = 0,
        .offset = (uint32_t)offsetof(GrowingPBEventV3Dto__storage_, deviceId),
        .flags = (GPBFieldFlags)(GPBFieldOptional | GPBFieldClearHasIvarOnZero),
        .dataType = GPBDataTypeString,
      },
      {
        .name = "userId",
        .dataTypeSpecific.clazz = Nil,
        .number = GrowingPBEventV3Dto_FieldNumber_UserId,
        .hasIndex = 1,
        .offset = (uint32_t)offsetof(GrowingPBEventV3Dto__storage_, userId),
        .flags = (GPBFieldFlags)(GPBFieldOptional | GPBFieldClearHasIvarOnZero),
        .dataType = GPBDataTypeString,
      },
      {
        .name = "gioId",
        .dataTypeSpecific.clazz = Nil,
        .number = GrowingPBEventV3Dto_FieldNumber_GioId,
        .hasIndex = 2,
        .offset = (uint32_t)offsetof(GrowingPBEventV3Dto__storage_, gioId),
        .flags = (GPBFieldFlags)(GPBFieldOptional | GPBFieldClearHasIvarOnZero),
        .dataType = GPBDataTypeString,
      },
      {
        .name = "sessionId",
        .dataTypeSpecific.clazz = Nil,
        .number = GrowingPBEventV3Dto_FieldNumber_SessionId,
        .hasIndex = 3,
        .offset = (uint32_t)offsetof(GrowingPBEventV3Dto__storage_, sessionId),
        .flags = (GPBFieldFlags)(GPBFieldOptional | GPBFieldClearHasIvarOnZero),
        .dataType = GPBDataTypeString,
      },
      {
        .name = "dataSourceId",
        .dataTypeSpecific.clazz = Nil,
        .number = GrowingPBEventV3Dto_FieldNumber_DataSourceId,
        .hasIndex = 4,
        .offset = (uint32_t)offsetof(GrowingPBEventV3Dto__storage_, dataSourceId),
        .flags = (GPBFieldFlags)(GPBFieldOptional | GPBFieldClearHasIvarOnZero),
        .dataType = GPBDataTypeString,
      },
      {
        .name = "eventType",
        .dataTypeSpecific.enumDescFunc = GrowingPBEventType_EnumDescriptor,
        .number = GrowingPBEventV3Dto_FieldNumber_EventType,
        .hasIndex = 5,
        .offset = (uint32_t)offsetof(GrowingPBEventV3Dto__storage_, eventType),
        .flags = (GPBFieldFlags)(GPBFieldOptional | GPBFieldHasEnumDescriptor | GPBFieldClearHasIvarOnZero),
        .dataType = GPBDataTypeEnum,
      },
      {
        .name = "platform",
        .dataTypeSpecific.clazz = Nil,
        .number = GrowingPBEventV3Dto_FieldNumber_Platform,
        .hasIndex = 6,
        .offset = (uint32_t)offsetof(GrowingPBEventV3Dto__storage_, platform),
        .flags = (GPBFieldFlags)(GPBFieldOptional | GPBFieldClearHasIvarOnZero),
        .dataType = GPBDataTypeString,
      },
      {
        .name = "timestamp",
        .dataTypeSpecific.clazz = Nil,
        .number = GrowingPBEventV3Dto_FieldNumber_Timestamp,
        .hasIndex = 7,
        .offset = (uint32_t)offsetof(GrowingPBEventV3Dto__storage_, timestamp),
        .flags = (GPBFieldFlags)(GPBFieldOptional | GPBFieldClearHasIvarOnZero),
        .dataType = GPBDataTypeInt64,
      },
      {
        .name = "domain",
        .dataTypeSpecific.clazz = Nil,
        .number = GrowingPBEventV3Dto_FieldNumber_Domain,
        .hasIndex = 8,
        .offset = (uint32_t)offsetof(GrowingPBEventV3Dto__storage_, domain),
        .flags = (GPBFieldFlags)(GPBFieldOptional | GPBFieldClearHasIvarOnZero),
        .dataType = GPBDataTypeString,
      },
      {
        .name = "path",
        .dataTypeSpecific.clazz = Nil,
        .number = GrowingPBEventV3Dto_FieldNumber_Path,
        .hasIndex = 9,
        .offset = (uint32_t)offsetof(GrowingPBEventV3Dto__storage_, path),
        .flags = (GPBFieldFlags)(GPBFieldOptional | GPBFieldClearHasIvarOnZero),
        .dataType = GPBDataTypeString,
      },
      {
        .name = "query",
        .dataTypeSpecific.clazz = Nil,
        .number = GrowingPBEventV3Dto_FieldNumber_Query,
        .hasIndex = 10,
        .offset = (uint32_t)offsetof(GrowingPBEventV3Dto__storage_, query),
        .flags = (GPBFieldFlags)(GPBFieldOptional | GPBFieldClearHasIvarOnZero),
        .dataType = GPBDataTypeString,
      },
      {
        .name = "title",
        .dataTypeSpecific.clazz = Nil,
        .number = GrowingPBEventV3Dto_FieldNumber_Title,
        .hasIndex = 11,
        .offset = (uint32_t)offsetof(GrowingPBEventV3Dto__storage_, title),
        .flags = (GPBFieldFlags)(GPBFieldOptional | GPBFieldClearHasIvarOnZero),
        .dataType = GPBDataTypeString,
      },
      {
        .name = "referralPage",
        .dataTypeSpecific.clazz = Nil,
        .number = GrowingPBEventV3Dto_FieldNumber_ReferralPage,
        .hasIndex = 12,
        .offset = (uint32_t)offsetof(GrowingPBEventV3Dto__storage_, referralPage),
        .flags = (GPBFieldFlags)(GPBFieldOptional | GPBFieldClearHasIvarOnZero),
        .dataType = GPBDataTypeString,
      },
      {
        .name = "globalSequenceId",
        .dataTypeSpecific.clazz = Nil,
        .number = GrowingPBEventV3Dto_FieldNumber_GlobalSequenceId,
        .hasIndex = 13,
        .offset = (uint32_t)offsetof(GrowingPBEventV3Dto__storage_, globalSequenceId),
        .flags = (GPBFieldFlags)(GPBFieldOptional | GPBFieldClearHasIvarOnZero),
        .dataType = GPBDataTypeInt64,
      },
      {
        .name = "eventSequenceId",
        .dataTypeSpecific.clazz = Nil,
        .number = GrowingPBEventV3Dto_FieldNumber_EventSequenceId,
        .hasIndex = 14,
        .offset = (uint32_t)offsetof(GrowingPBEventV3Dto__storage_, eventSequenceId),
        .flags = (GPBFieldFlags)(GPBFieldOptional | GPBFieldClearHasIvarOnZero),
        .dataType = GPBDataTypeInt32,
      },
      {
        .name = "screenHeight",
        .dataTypeSpecific.clazz = Nil,
        .number = GrowingPBEventV3Dto_FieldNumber_ScreenHeight,
        .hasIndex = 15,
        .offset = (uint32_t)offsetof(GrowingPBEventV3Dto__storage_, screenHeight),
        .flags = (GPBFieldFlags)(GPBFieldOptional | GPBFieldClearHasIvarOnZero),
        .dataType = GPBDataTypeInt32,
      },
      {
        .name = "screenWidth",
        .dataTypeSpecific.clazz = Nil,
        .number = GrowingPBEventV3Dto_FieldNumber_ScreenWidth,
        .hasIndex = 16,
        .offset = (uint32_t)offsetof(GrowingPBEventV3Dto__storage_, screenWidth),
        .flags = (GPBFieldFlags)(GPBFieldOptional | GPBFieldClearHasIvarOnZero),
        .dataType = GPBDataTypeInt32,
      },
      {
        .name = "language",
        .dataTypeSpecific.clazz = Nil,
        .number = GrowingPBEventV3Dto_FieldNumber_Language,
        .hasIndex = 17,
        .offset = (uint32_t)offsetof(GrowingPBEventV3Dto__storage_, language),
        .flags = (GPBFieldFlags)(GPBFieldOptional | GPBFieldClearHasIvarOnZero),
        .dataType = GPBDataTypeString,
      },
      {
        .name = "sdkVersion",
        .dataTypeSpecific.clazz = Nil,
        .number = GrowingPBEventV3Dto_FieldNumber_SdkVersion,
        .hasIndex = 18,
        .offset = (uint32_t)offsetof(GrowingPBEventV3Dto__storage_, sdkVersion),
        .flags = (GPBFieldFlags)(GPBFieldOptional | GPBFieldClearHasIvarOnZero),
        .dataType = GPBDataTypeString,
      },
      {
        .name = "appVersion",
        .dataTypeSpecific.clazz = Nil,
        .number = GrowingPBEventV3Dto_FieldNumber_AppVersion,
        .hasIndex = 19,
        .offset = (uint32_t)offsetof(GrowingPBEventV3Dto__storage_, appVersion),
        .flags = (GPBFieldFlags)(GPBFieldOptional | GPBFieldClearHasIvarOnZero),
        .dataType = GPBDataTypeString,
      },
      {
        .name = "extraSdk",
        .dataTypeSpecific.clazz = Nil,
        .number = GrowingPBEventV3Dto_FieldNumber_ExtraSdk,
        .hasIndex = GPBNoHasBit,
        .offset = (uint32_t)offsetof(GrowingPBEventV3Dto__storage_, extraSdk),
        .flags = GPBFieldMapKeyString,
        .dataType = GPBDataTypeString,
      },
      {
        .name = "eventName",
        .dataTypeSpecific.clazz = Nil,
        .number = GrowingPBEventV3Dto_FieldNumber_EventName,
        .hasIndex = 20,
        .offset = (uint32_t)offsetof(GrowingPBEventV3Dto__storage_, eventName),
        .flags = (GPBFieldFlags)(GPBFieldOptional | GPBFieldClearHasIvarOnZero),
        .dataType = GPBDataTypeString,
      },
      {
        .name = "pageShowTimestamp",
        .dataTypeSpecific.clazz = Nil,
        .number = GrowingPBEventV3Dto_FieldNumber_PageShowTimestamp,
        .hasIndex = 21,
        .offset = (uint32_t)offsetof(GrowingPBEventV3Dto__storage_, pageShowTimestamp),
        .flags = (GPBFieldFlags)(GPBFieldOptional | GPBFieldClearHasIvarOnZero),
        .dataType = GPBDataTypeInt64,
      },
      {
        .name = "attributes",
        .dataTypeSpecific.clazz = Nil,
        .number = GrowingPBEventV3Dto_FieldNumber_Attributes,
        .hasIndex = GPBNoHasBit,
        .offset = (uint32_t)offsetof(GrowingPBEventV3Dto__storage_, attributes),
        .flags = GPBFieldMapKeyString,
        .dataType = GPBDataTypeString,
      },
      {
        .name = "resourceItem",
        .dataTypeSpecific.clazz = GPBObjCClass(GrowingPBResourceItem),
        .number = GrowingPBEventV3Dto_FieldNumber_ResourceItem,
        .hasIndex = 22,
        .offset = (uint32_t)offsetof(GrowingPBEventV3Dto__storage_, resourceItem),
        .flags = GPBFieldOptional,
        .dataType = GPBDataTypeMessage,
      },
      {
        .name = "protocolType",
        .dataTypeSpecific.clazz = Nil,
        .number = GrowingPBEventV3Dto_FieldNumber_ProtocolType,
        .hasIndex = 23,
        .offset = (uint32_t)offsetof(GrowingPBEventV3Dto__storage_, protocolType),
        .flags = (GPBFieldFlags)(GPBFieldOptional | GPBFieldClearHasIvarOnZero),
        .dataType = GPBDataTypeString,
      },
      {
        .name = "textValue",
        .dataTypeSpecific.clazz = Nil,
        .number = GrowingPBEventV3Dto_FieldNumber_TextValue,
        .hasIndex = 24,
        .offset = (uint32_t)offsetof(GrowingPBEventV3Dto__storage_, textValue),
        .flags = (GPBFieldFlags)(GPBFieldOptional | GPBFieldClearHasIvarOnZero),
        .dataType = GPBDataTypeString,
      },
      {
        .name = "xpath",
        .dataTypeSpecific.clazz = Nil,
        .number = GrowingPBEventV3Dto_FieldNumber_Xpath,
        .hasIndex = 25,
        .offset = (uint32_t)offsetof(GrowingPBEventV3Dto__storage_, xpath),
        .flags = (GPBFieldFlags)(GPBFieldOptional | GPBFieldClearHasIvarOnZero),
        .dataType = GPBDataTypeString,
      },
      {
        .name = "index",
        .dataTypeSpecific.clazz = Nil,
        .number = GrowingPBEventV3Dto_FieldNumber_Index,
        .hasIndex = 26,
        .offset = (uint32_t)offsetof(GrowingPBEventV3Dto__storage_, index),
        .flags = (GPBFieldFlags)(GPBFieldOptional | GPBFieldClearHasIvarOnZero),
        .dataType = GPBDataTypeInt32,
      },
      {
        .name = "hyperlink",
        .dataTypeSpecific.clazz = Nil,
        .number = GrowingPBEventV3Dto_FieldNumber_Hyperlink,
        .hasIndex = 27,
        .offset = (uint32_t)offsetof(GrowingPBEventV3Dto__storage_, hyperlink),
        .flags = (GPBFieldFlags)(GPBFieldOptional | GPBFieldClearHasIvarOnZero),
        .dataType = GPBDataTypeString,
      },
      {
        .name = "URLScheme",
        .dataTypeSpecific.clazz = Nil,
        .number = GrowingPBEventV3Dto_FieldNumber_URLScheme,
        .hasIndex = 28,
        .offset = (uint32_t)offsetof(GrowingPBEventV3Dto__storage_, URLScheme),
        .flags = (GPBFieldFlags)(GPBFieldOptional | GPBFieldTextFormatNameCustom | GPBFieldClearHasIvarOnZero),
        .dataType = GPBDataTypeString,
      },
      {
        .name = "appState",
        .dataTypeSpecific.clazz = Nil,
        .number = GrowingPBEventV3Dto_FieldNumber_AppState,
        .hasIndex = 29,
        .offset = (uint32_t)offsetof(GrowingPBEventV3Dto__storage_, appState),
        .flags = (GPBFieldFlags)(GPBFieldOptional | GPBFieldClearHasIvarOnZero),
        .dataType = GPBDataTypeString,
      },
      {
        .name = "networkState",
        .dataTypeSpecific.clazz = Nil,
        .number = GrowingPBEventV3Dto_FieldNumber_NetworkState,
        .hasIndex = 30,
        .offset = (uint32_t)offsetof(GrowingPBEventV3Dto__storage_, networkState),
        .flags = (GPBFieldFlags)(GPBFieldOptional | GPBFieldClearHasIvarOnZero),
        .dataType = GPBDataTypeString,
      },
      {
        .name = "appChannel",
        .dataTypeSpecific.clazz = Nil,
        .number = GrowingPBEventV3Dto_FieldNumber_AppChannel,
        .hasIndex = 31,
        .offset = (uint32_t)offsetof(GrowingPBEventV3Dto__storage_, appChannel),
        .flags = (GPBFieldFlags)(GPBFieldOptional | GPBFieldClearHasIvarOnZero),
        .dataType = GPBDataTypeString,
      },
      {
        .name = "pageName",
        .dataTypeSpecific.clazz = Nil,
        .number = GrowingPBEventV3Dto_FieldNumber_PageName,
        .hasIndex = 32,
        .offset = (uint32_t)offsetof(GrowingPBEventV3Dto__storage_, pageName),
        .flags = (GPBFieldFlags)(GPBFieldOptional | GPBFieldClearHasIvarOnZero),
        .dataType = GPBDataTypeString,
      },
      {
        .name = "platformVersion",
        .dataTypeSpecific.clazz = Nil,
        .number = GrowingPBEventV3Dto_FieldNumber_PlatformVersion,
        .hasIndex = 33,
        .offset = (uint32_t)offsetof(GrowingPBEventV3Dto__storage_, platformVersion),
        .flags = (GPBFieldFlags)(GPBFieldOptional | GPBFieldClearHasIvarOnZero),
        .dataType = GPBDataTypeString,
      },
      {
        .name = "deviceBrand",
        .dataTypeSpecific.clazz = Nil,
        .number = GrowingPBEventV3Dto_FieldNumber_DeviceBrand,
        .hasIndex = 34,
        .offset = (uint32_t)offsetof(GrowingPBEventV3Dto__storage_, deviceBrand),
        .flags = (GPBFieldFlags)(GPBFieldOptional | GPBFieldClearHasIvarOnZero),
        .dataType = GPBDataTypeString,
      },
      {
        .name = "deviceModel",
        .dataTypeSpecific.clazz = Nil,
        .number = GrowingPBEventV3Dto_FieldNumber_DeviceModel,
        .hasIndex = 35,
        .offset = (uint32_t)offsetof(GrowingPBEventV3Dto__storage_, deviceModel),
        .flags = (GPBFieldFlags)(GPBFieldOptional | GPBFieldClearHasIvarOnZero),
        .dataType = GPBDataTypeString,
      },
      {
        .name = "deviceType",
        .dataTypeSpecific.clazz = Nil,
        .number = GrowingPBEventV3Dto_FieldNumber_DeviceType,
        .hasIndex = 36,
        .offset = (uint32_t)offsetof(GrowingPBEventV3Dto__storage_, deviceType),
        .flags = (GPBFieldFlags)(GPBFieldOptional | GPBFieldClearHasIvarOnZero),
        .dataType = GPBDataTypeString,
      },
      {
        .name = "operatingSystem",
        .dataTypeSpecific.clazz = Nil,
        .number = GrowingPBEventV3Dto_FieldNumber_OperatingSystem,
        .hasIndex = 37,
        .offset = (uint32_t)offsetof(GrowingPBEventV3Dto__storage_, operatingSystem),
        .flags = (GPBFieldFlags)(GPBFieldOptional | GPBFieldClearHasIvarOnZero),
        .dataType = GPBDataTypeString,
      },
      {
        .name = "appName",
        .dataTypeSpecific.clazz = Nil,
        .number = GrowingPBEventV3Dto_FieldNumber_AppName,
        .hasIndex = 38,
        .offset = (uint32_t)offsetof(GrowingPBEventV3Dto__storage_, appName),
        .flags = (GPBFieldFlags)(GPBFieldOptional | GPBFieldClearHasIvarOnZero),
        .dataType = GPBDataTypeString,
      },
      {
        .name = "latitude",
        .dataTypeSpecific.clazz = Nil,
        .number = GrowingPBEventV3Dto_FieldNumber_Latitude,
        .hasIndex = 39,
        .offset = (uint32_t)offsetof(GrowingPBEventV3Dto__storage_, latitude),
        .flags = (GPBFieldFlags)(GPBFieldOptional | GPBFieldClearHasIvarOnZero),
        .dataType = GPBDataTypeDouble,
      },
      {
        .name = "longitude",
        .dataTypeSpecific.clazz = Nil,
        .number = GrowingPBEventV3Dto_FieldNumber_Longitude,
        .hasIndex = 40,
        .offset = (uint32_t)offsetof(GrowingPBEventV3Dto__storage_, longitude),
        .flags = (GPBFieldFlags)(GPBFieldOptional | GPBFieldClearHasIvarOnZero),
        .dataType = GPBDataTypeDouble,
      },
      {
        .name = "imei",
        .dataTypeSpecific.clazz = Nil,
        .number = GrowingPBEventV3Dto_FieldNumber_Imei,
        .hasIndex = 41,
        .offset = (uint32_t)offsetof(GrowingPBEventV3Dto__storage_, imei),
        .flags = (GPBFieldFlags)(GPBFieldOptional | GPBFieldClearHasIvarOnZero),
        .dataType = GPBDataTypeString,
      },
      {
        .name = "androidId",
        .dataTypeSpecific.clazz = Nil,
        .number = GrowingPBEventV3Dto_FieldNumber_AndroidId,
        .hasIndex = 42,
        .offset = (uint32_t)offsetof(GrowingPBEventV3Dto__storage_, androidId),
        .flags = (GPBFieldFlags)(GPBFieldOptional | GPBFieldClearHasIvarOnZero),
        .dataType = GPBDataTypeString,
      },
      {
        .name = "oaid",
        .dataTypeSpecific.clazz = Nil,
        .number = GrowingPBEventV3Dto_FieldNumber_Oaid,
        .hasIndex = 43,
        .offset = (uint32_t)offsetof(GrowingPBEventV3Dto__storage_, oaid),
        .flags = (GPBFieldFlags)(GPBFieldOptional | GPBFieldClearHasIvarOnZero),
        .dataType = GPBDataTypeString,
      },
      {
        .name = "googleAdvertisingId",
        .dataTypeSpecific.clazz = Nil,
        .number = GrowingPBEventV3Dto_FieldNumber_GoogleAdvertisingId,
        .hasIndex = 44,
        .offset = (uint32_t)offsetof(GrowingPBEventV3Dto__storage_, googleAdvertisingId),
        .flags = (GPBFieldFlags)(GPBFieldOptional | GPBFieldClearHasIvarOnZero),
        .dataType = GPBDataTypeString,
      },
      {
        .name = "idfa",
        .dataTypeSpecific.clazz = Nil,
        .number = GrowingPBEventV3Dto_FieldNumber_Idfa,
        .hasIndex = 45,
        .offset = (uint32_t)offsetof(GrowingPBEventV3Dto__storage_, idfa),
        .flags = (GPBFieldFlags)(GPBFieldOptional | GPBFieldClearHasIvarOnZero),
        .dataType = GPBDataTypeString,
      },
      {
        .name = "idfv",
        .dataTypeSpecific.clazz = Nil,
        .number = GrowingPBEventV3Dto_FieldNumber_Idfv,
        .hasIndex = 46,
        .offset = (uint32_t)offsetof(GrowingPBEventV3Dto__storage_, idfv),
        .flags = (GPBFieldFlags)(GPBFieldOptional | GPBFieldClearHasIvarOnZero),
        .dataType = GPBDataTypeString,
      },
      {
        .name = "orientation",
        .dataTypeSpecific.clazz = Nil,
        .number = GrowingPBEventV3Dto_FieldNumber_Orientation,
        .hasIndex = 47,
        .offset = (uint32_t)offsetof(GrowingPBEventV3Dto__storage_, orientation),
        .flags = (GPBFieldFlags)(GPBFieldOptional | GPBFieldClearHasIvarOnZero),
        .dataType = GPBDataTypeString,
      },
      {
        .name = "projectKey",
        .dataTypeSpecific.clazz = Nil,
        .number = GrowingPBEventV3Dto_FieldNumber_ProjectKey,
        .hasIndex = 48,
        .offset = (uint32_t)offsetof(GrowingPBEventV3Dto__storage_, projectKey),
        .flags = (GPBFieldFlags)(GPBFieldOptional | GPBFieldClearHasIvarOnZero),
        .dataType = GPBDataTypeString,
      },
      {
        .name = "sendTime",
        .dataTypeSpecific.clazz = Nil,
        .number = GrowingPBEventV3Dto_FieldNumber_SendTime,
        .hasIndex = 49,
        .offset = (uint32_t)offsetof(GrowingPBEventV3Dto__storage_, sendTime),
        .flags = (GPBFieldFlags)(GPBFieldOptional | GPBFieldClearHasIvarOnZero),
        .dataType = GPBDataTypeInt64,
      },
      {
        .name = "userKey",
        .dataTypeSpecific.clazz = Nil,
        .number = GrowingPBEventV3Dto_FieldNumber_UserKey,
        .hasIndex = 50,
        .offset = (uint32_t)offsetof(GrowingPBEventV3Dto__storage_, userKey),
        .flags = (GPBFieldFlags)(GPBFieldOptional | GPBFieldClearHasIvarOnZero),
        .dataType = GPBDataTypeString,
      },
    };
    GPBDescriptor *localDescriptor =
        [GPBDescriptor allocDescriptorForClass:[GrowingPBEventV3Dto class]
                                     rootClass:[GrowingPBEventV3Root class]
                                          file:GrowingPBEventV3Root_FileDescriptor()
                                        fields:fields
                                    fieldCount:(uint32_t)(sizeof(fields) / sizeof(GPBMessageFieldDescription))
                                   storageSize:sizeof(GrowingPBEventV3Dto__storage_)
                                         flags:(GPBDescriptorInitializationFlags)(GPBDescriptorInitializationFlag_UsesClassRefs | GPBDescriptorInitializationFlag_Proto3OptionalKnown)];
#if !GPBOBJC_SKIP_MESSAGE_TEXTFORMAT_EXTRAS
    static const char *extraTextFormatInfo =
        "\001\037!!!\246\000";
    [localDescriptor setupExtraTextInfo:extraTextFormatInfo];
#endif  // !GPBOBJC_SKIP_MESSAGE_TEXTFORMAT_EXTRAS
    #if defined(DEBUG) && DEBUG
      NSAssert(descriptor == nil, @"Startup recursed!");
    #endif  // DEBUG
    descriptor = localDescriptor;
  }
  return descriptor;
}

@end

int32_t GrowingPBEventV3Dto_EventType_RawValue(GrowingPBEventV3Dto *message) {
  GPBDescriptor *descriptor = [GrowingPBEventV3Dto descriptor];
  GPBFieldDescriptor *field = [descriptor fieldWithNumber:GrowingPBEventV3Dto_FieldNumber_EventType];
  return GPBGetMessageRawEnumField(message, field);
}

void SetGrowingPBEventV3Dto_EventType_RawValue(GrowingPBEventV3Dto *message, int32_t value) {
  GPBDescriptor *descriptor = [GrowingPBEventV3Dto descriptor];
  GPBFieldDescriptor *field = [descriptor fieldWithNumber:GrowingPBEventV3Dto_FieldNumber_EventType];
  GPBSetMessageRawEnumField(message, field, value);
}

#pragma mark - GrowingPBResourceItem

@implementation GrowingPBResourceItem

@dynamic id_p;
@dynamic key;
@dynamic attributes, attributes_Count;

typedef struct GrowingPBResourceItem__storage_ {
  uint32_t _has_storage_[1];
  NSString *id_p;
  NSString *key;
  NSMutableDictionary *attributes;
} GrowingPBResourceItem__storage_;

// This method is threadsafe because it is initially called
// in +initialize for each subclass.
+ (GPBDescriptor *)descriptor {
  static GPBDescriptor *descriptor = nil;
  if (!descriptor) {
    static GPBMessageFieldDescription fields[] = {
      {
        .name = "id_p",
        .dataTypeSpecific.clazz = Nil,
        .number = GrowingPBResourceItem_FieldNumber_Id_p,
        .hasIndex = 0,
        .offset = (uint32_t)offsetof(GrowingPBResourceItem__storage_, id_p),
        .flags = (GPBFieldFlags)(GPBFieldOptional | GPBFieldClearHasIvarOnZero),
        .dataType = GPBDataTypeString,
      },
      {
        .name = "key",
        .dataTypeSpecific.clazz = Nil,
        .number = GrowingPBResourceItem_FieldNumber_Key,
        .hasIndex = 1,
        .offset = (uint32_t)offsetof(GrowingPBResourceItem__storage_, key),
        .flags = (GPBFieldFlags)(GPBFieldOptional | GPBFieldClearHasIvarOnZero),
        .dataType = GPBDataTypeString,
      },
      {
        .name = "attributes",
        .dataTypeSpecific.clazz = Nil,
        .number = GrowingPBResourceItem_FieldNumber_Attributes,
        .hasIndex = GPBNoHasBit,
        .offset = (uint32_t)offsetof(GrowingPBResourceItem__storage_, attributes),
        .flags = GPBFieldMapKeyString,
        .dataType = GPBDataTypeString,
      },
    };
    GPBDescriptor *localDescriptor =
        [GPBDescriptor allocDescriptorForClass:[GrowingPBResourceItem class]
                                     rootClass:[GrowingPBEventV3Root class]
                                          file:GrowingPBEventV3Root_FileDescriptor()
                                        fields:fields
                                    fieldCount:(uint32_t)(sizeof(fields) / sizeof(GPBMessageFieldDescription))
                                   storageSize:sizeof(GrowingPBResourceItem__storage_)
                                         flags:(GPBDescriptorInitializationFlags)(GPBDescriptorInitializationFlag_UsesClassRefs | GPBDescriptorInitializationFlag_Proto3OptionalKnown)];
    #if defined(DEBUG) && DEBUG
      NSAssert(descriptor == nil, @"Startup recursed!");
    #endif  // DEBUG
    descriptor = localDescriptor;
  }
  return descriptor;
}

@end

#pragma mark - GrowingPBEventV3List

@implementation GrowingPBEventV3List

@dynamic valuesArray, valuesArray_Count;

typedef struct GrowingPBEventV3List__storage_ {
  uint32_t _has_storage_[1];
  NSMutableArray *valuesArray;
} GrowingPBEventV3List__storage_;

// This method is threadsafe because it is initially called
// in +initialize for each subclass.
+ (GPBDescriptor *)descriptor {
  static GPBDescriptor *descriptor = nil;
  if (!descriptor) {
    static GPBMessageFieldDescription fields[] = {
      {
        .name = "valuesArray",
        .dataTypeSpecific.clazz = GPBObjCClass(GrowingPBEventV3Dto),
        .number = GrowingPBEventV3List_FieldNumber_ValuesArray,
        .hasIndex = GPBNoHasBit,
        .offset = (uint32_t)offsetof(GrowingPBEventV3List__storage_, valuesArray),
        .flags = GPBFieldRepeated,
        .dataType = GPBDataTypeMessage,
      },
    };
    GPBDescriptor *localDescriptor =
        [GPBDescriptor allocDescriptorForClass:[GrowingPBEventV3List class]
                                     rootClass:[GrowingPBEventV3Root class]
                                          file:GrowingPBEventV3Root_FileDescriptor()
                                        fields:fields
                                    fieldCount:(uint32_t)(sizeof(fields) / sizeof(GPBMessageFieldDescription))
                                   storageSize:sizeof(GrowingPBEventV3List__storage_)
                                         flags:(GPBDescriptorInitializationFlags)(GPBDescriptorInitializationFlag_UsesClassRefs | GPBDescriptorInitializationFlag_Proto3OptionalKnown)];
    #if defined(DEBUG) && DEBUG
      NSAssert(descriptor == nil, @"Startup recursed!");
    #endif  // DEBUG
    descriptor = localDescriptor;
  }
  return descriptor;
}

@end


#pragma clang diagnostic pop

// @@protoc_insertion_point(global_scope)
