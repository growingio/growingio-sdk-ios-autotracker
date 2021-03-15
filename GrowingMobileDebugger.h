//
//  GrowingMobileDebugger.h
//  Growing
//
//  Created by GIO on 2017/9/19.
//  Copyright © 2017年 GrowingIO. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GrowingEvent;

@interface GrowingMobileDebugger : NSObject

+ (instancetype)shareDebugger;

//更新屏幕截图
+ (void)updateScreenshot;

//获取 Mobile Debugger 当前状态：进行中、正在关闭Debugger
+ (BOOL)isStart;

//初始化debugger
- (void)debugWithRoomNumber:(NSString *)roomNumber dataCheck:(BOOL)dataCheck;

//用户一些设置events会在Observer之前发送，需要提前缓存
- (void)cacheValue:(NSDictionary<NSString *, NSObject *> *)varDic ofType:(NSString *)type;

@end
