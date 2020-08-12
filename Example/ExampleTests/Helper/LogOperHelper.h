//
//  LogOperHelper.h
//  GIOAutoTests
//
//  Created by GrowingIO on 2018/7/10.
//  Copyright (C) 2018 Beijing Yishu Technology Co., Ltd.
//

#import <Foundation/Foundation.h>
#import <asl.h>

@interface LogOperHelper : NSObject
@property (nonatomic, strong) NSDate *date;
@property (nonatomic, copy) NSString *sender;
@property (nonatomic, copy) NSString *messageText;
@property (nonatomic, assign) long long messageID;

//定义常量，标识符错误提醒
extern NSString *const FlagNl;

//定义常量，标识符错误提醒
extern NSString *const ValueNl;

+ (NSArray *)allLogMessagesForCurrentProcess;

+(instancetype)logMessageFromASLMessage:(aslmsg)aslMessage;

//获取日志路径
+(void)writeLogToFile;

//检测日志中是否有相应该的文字
+(Boolean)CheckLogOutput:(NSString *)logcheck;

//恢复日志重定向
+(void)redirectLogBack;

//获取标识符错误提醒
+(NSString *)getFlagErrNsLog;

//获取值错误提醒
+(NSString *)getValueErrNsLog;
@end
