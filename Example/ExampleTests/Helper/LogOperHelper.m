//
//  LogOperHelper.m
//  GIOAutoTests
//
//  Created by GrowingIO on 2018/7/10.
//  Copyright (C) 2018 Beijing Yishu Technology Co., Ltd.
//

#import "LogOperHelper.h"
#import <asl.h>

@implementation LogOperHelper

NSString *logfilepath;
int origin;

+ (NSArray *)allLogMessagesForCurrentProcess
{
    asl_object_t query = asl_new(ASL_TYPE_QUERY);
    
    // Filter for messages from the current process. Note that this appears to happen by default on device, but is required in the simulator.
    NSString *pidString = [NSString stringWithFormat:@"%d", [[NSProcessInfo processInfo] processIdentifier]];
    asl_set_query(query, ASL_KEY_PID, [pidString UTF8String], ASL_QUERY_OP_EQUAL);
    
    aslresponse response = asl_search(NULL, query);
    aslmsg aslMessage = NULL;
    
    NSMutableArray *logMessages = [NSMutableArray array];
    while ((aslMessage = asl_next(response))) {
        [logMessages addObject:[LogOperHelper logMessageFromASLMessage:aslMessage]];
    }
    asl_release(response);
    
    return logMessages;
}



//这个是怎么从日志的对象aslmsg中获取我们需要的数据
+(instancetype)logMessageFromASLMessage:(aslmsg)aslMessage
{
    LogOperHelper *logMessage = [[LogOperHelper alloc] init];
    const char *timestamp = asl_get(aslMessage, ASL_KEY_TIME);
    if (timestamp) {
        NSTimeInterval timeInterval = [@(timestamp) integerValue];
        const char *nanoseconds = asl_get(aslMessage, ASL_KEY_TIME_NSEC);
        if (nanoseconds) {
            timeInterval += [@(nanoseconds) doubleValue] / NSEC_PER_SEC;
        }
    }
    
    const char *sender = asl_get(aslMessage, ASL_KEY_SENDER);
    if (sender) {
        logMessage.sender = @(sender);
    }
    
    const char *messageText = asl_get(aslMessage, ASL_KEY_MSG);
    if (messageText) {
        logMessage.messageText = @(messageText);//NSLog写入的文本内容
    }
    
    const char *messageID = asl_get(aslMessage, ASL_KEY_MSG_ID);
    if (messageID) {
        logMessage.messageID = [@(messageID) longLongValue];
    }
    
    return logMessage;
}

//将Nslog输出重新定位到文件
+(void)writeLogToFile{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = [paths objectAtIndex:0];
    NSString *loggingPath = [documentsPath stringByAppendingPathComponent:@"/mylog.log"];
    //删除原日志文件
    NSLog(@"Log file location:%@",loggingPath);
    NSFileManager *manager = [NSFileManager defaultManager];
    BOOL isExist = [manager fileExistsAtPath:loggingPath];
    if(isExist){
        BOOL sucess4 = [manager removeItemAtPath:loggingPath error:nil];
        if(sucess4){
            //删除成功
        }else{
            //删除失败
        }
    }
    origin=dup(STDERR_FILENO);
    freopen([loggingPath cStringUsingEncoding:NSASCIIStringEncoding], "a+", stderr);
    logfilepath=loggingPath;
}

//检测日志中是否有相应该的文字
+(Boolean)CheckLogOutput:(NSString *)logcheck
{
    NSString *loggingPath=logfilepath;
    //读取文件
    NSString *str1 = [NSString stringWithContentsOfFile:loggingPath encoding:NSUTF8StringEncoding error:nil];
    //Boolean *chres=[str1 containsString:logcheck];
    if ([str1 rangeOfString:logcheck].location==NSNotFound)
    {
        return false;
    }
    else
    {
        return true;
    }
}
//恢复日志重定向
+(void)redirectLogBack{
    dup2(origin, STDERR_FILENO);
}

//获取标识符错误提醒
+(NSString *)getFlagErrNsLog
{
    NSString *const FlagNl=@"当前数据的标识符不合法。合法的标识符的详细定义请参考：https://docs.growingio.com/v3/developer-manual/sdkintegrated/ios-sdk/ios-sdk-api/customize-api";
    return FlagNl;
}

//获取值错误提醒
+(NSString *)getValueErrNsLog{
    NSString *const ValueNl=@"当前数据的值不合法。合法值的详细定义请参考：https://docs.growingio.com/v3/developer-manual/sdkintegrated/ios-sdk/ios-sdk-api/customize-api";
    return ValueNl;
}

@end
