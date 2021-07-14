//
// Created by xiangyang on 2020/11/10.
//

#import <Foundation/Foundation.h>

@class GrowingTrackConfiguration;

FOUNDATION_EXPORT NSString *const GrowingTrackerVersionName;
FOUNDATION_EXPORT const int GrowingTrackerVersionCode;

@interface GrowingRealTracker : NSObject

/// 初始化方法
/// @param configuration 配置信息
/// @param launchOptions 启动参数
- (instancetype)initWithConfiguration:(GrowingTrackConfiguration *)configuration launchOptions:(NSDictionary *)launchOptions;

/// 初始化方法
/// @param configuration 配置信息
/// @param launchOptions 启动参数
+ (instancetype)trackerWithConfiguration:(GrowingTrackConfiguration *)configuration launchOptions:(NSDictionary *)launchOptions;

/// 发送一个自定义事件
/// @param eventName 自定义事件名称
- (void)trackCustomEvent:(NSString *)eventName;

/// 发送一个自定义事件
/// @param eventName 自定义事件名称
/// @param attributes 事件发生时所伴随的维度信息
- (void)trackCustomEvent:(NSString *)eventName withAttributes:(NSDictionary <NSString *, NSString *> *)attributes;

/// 以登录用户的身份定义用户属性变量，用于用户信息相关分析。
/// @param attributes 用户属性信息
- (void)setLoginUserAttributes:(NSDictionary<NSString *, NSString *> *)attributes;

/// 以访客的身份定义用户属性变量，也可用于A/B测试上传标签。
/// @param attributes 用户属性信息
- (void)setVisitorAttributes:(NSDictionary<NSString *, NSString *> *)attributes;

/// 发送一个转化信息用于高级归因分析，在添加代码之前必须在打点管理界面上声明转化变量。
/// @param variables 用户属性信息
- (void)setConversionVariables:(NSDictionary <NSString *, NSString *> *)variables;

/// 当用户登录之后调用setLoginUserId API，设置登录用户ID。
/// @param userId 用户ID
- (void)setLoginUserId:(NSString *)userId;

/// 支持设置userId的类型, 存储方式与userId保持一致, userKey默认为null
/// @param userId 用户ID
/// @param userKey 用户ID对应的key值
- (void)setLoginUserId:(NSString *)userId userKey:(NSString *)userKey;

/// 当用户登出之后调用cleanLoginUserId，清除已经设置的登录用户ID。
- (void)cleanLoginUserId;

/// 打开或关闭数据采集
/// @param enabled 打开或者关闭
- (void)setDataCollectionEnabled:(BOOL)enabled;

/// 同步获取设备id，又称为匿名用户id，SDK 自动生成用来定义唯一设备。
- (NSString *)getDeviceId;

/// 设置经纬度坐标
/// @param latitude 纬度
/// @param longitude 经度
- (void)setLocation:(double)latitude longitude:(double)longitude;

/// 清除地理位置
- (void)cleanLocation;

@end
