//
//  UncaughtExceptionHandler.h
//  CrazySmallNote
//
//  Created by xzysun on 14-9-25.
//  Copyright (c) 2014年 AnyApps. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UncaughtExceptionHandler : NSObject

//发送错误日志
-(void)sendCrashLog;
@end

/**
 *  注册未捕获异常和系统异常退出信号
 */
void InstallUncaughtExceptionHandler(void);