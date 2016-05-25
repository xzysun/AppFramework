//
//  UncaughtExceptionHandler.m
//  CrazySmallNote
//
//  Created by xzysun on 14-9-25.
//  Copyright (c) 2014年 AnyApps. All rights reserved.
//

#import "UncaughtExceptionHandler.h"
#include <libkern/OSAtomic.h>
#include <execinfo.h>
#import "sys/utsname.h"
#import "Config.h"
#import "KeyChainHelper.h"
#import <UIKit/UIDevice.h>

NSString * const UncaughtExceptionHandlerSignalExceptionName = @"UncaughtExceptionHandlerSignalExceptionName";
NSString * const UncaughtExceptionHandlerSignalKey = @"UncaughtExceptionHandlerSignalKey";
NSString * const UncaughtExceptionHandlerAddressesKey = @"UncaughtExceptionHandlerAddressesKey";

volatile int32_t UncaughtExceptionCount = 0;
const int32_t UncaughtExceptionMaximum = 10;

const NSInteger UncaughtExceptionHandlerSkipAddressCount = 1;
const NSInteger UncaughtExceptionHandlerReportAddressCount = 10;

@implementation UncaughtExceptionHandler

+ (NSArray *)backtrace
{
    void* callstack[128];
    int frames = backtrace(callstack, 128);
    char **strs = backtrace_symbols(callstack, frames);
    
    int i;
    NSMutableArray *backtrace = [NSMutableArray arrayWithCapacity:frames];
    for (i = 0; i < frames; i++) {
        [backtrace addObject:[NSString stringWithUTF8String:strs[i]]];
    }
    free(strs);
    
    return backtrace;
}

- (void)handleException:(NSException *)exception
{
    //get exception info
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys: [exception name],@"ExceptionName", [exception reason],@"ExceptionReason", [exception userInfo],@"ExceptionInfo", nil];
    
    [self saveAppCrashData:dic];
    if ([[exception name] isEqual:UncaughtExceptionHandlerSignalExceptionName]) {
        kill(getpid(), [[[exception userInfo] objectForKey:UncaughtExceptionHandlerSignalKey] intValue]);
    } else {
        [exception raise];
    }
}

-(void)saveAppCrashData:(NSDictionary *)dic
{
    DDLogWarn(@"准备保存崩溃记录:%@", dic);
    NSDateFormatter *inputFormatter = [[NSDateFormatter alloc] init];
    [inputFormatter setDateFormat:@"yyyy-MM-dd_HH:mm:ss.SSS"];
    inputFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh-CN"];
    NSString *newDateString = [inputFormatter stringFromDate:[NSDate date]];
    NSMutableDictionary *info = [[NSMutableDictionary alloc]initWithDictionary:dic];
    [info setObject:[self systemInfo] forKey:@"systemInfo"];
    [info setObject:newDateString forKey:@"date"];
    //save file
    NSURL *filePath = [[[[NSFileManager defaultManager] URLsForDirectory:NSCachesDirectory inDomains:NSUserDomainMask] firstObject] URLByAppendingPathComponent:[NSString stringWithFormat:@"crashLog_%@.log", newDateString]];
    BOOL flag = [info writeToURL:filePath atomically:YES];
    if (flag) {
        DDLogWarn(@"崩溃记录保存到文件:%@", filePath);
    } else {
        DDLogError(@"崩溃记录文件写入失败!");
    }
}

-(void)sendCrashLog
{
    //延迟5秒执行错误日志发送操作
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self loadAndSendAnyCrashLog];
    });
}

-(void)loadAndSendAnyCrashLog
{
    NSURL *filePath = [[[NSFileManager defaultManager] URLsForDirectory:NSCachesDirectory inDomains:NSUserDomainMask] firstObject];
    NSArray *files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[filePath path] error:nil];
    NSMutableArray *logList = [NSMutableArray array];
    for (NSString *fileName in files) {
        //扫描目录，获取CrashLog
        if ([fileName hasPrefix:@"crashLog"] && [fileName hasSuffix:@".log"]) {
            [logList addObject:fileName];
        }
    }
    DDLogInfo(@"检测到需要发送的崩溃日志数量:%lu", (unsigned long)logList.count);
    if (logList.count == 0) {
        return;
    }
    for (NSString *fileName in logList) {
        NSURL *logPath = [filePath URLByAppendingPathComponent:fileName];
        NSDictionary *logInfo = [NSDictionary dictionaryWithContentsOfURL:logPath];
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:logInfo options:(NSJSONWritingOptions)0 error:nil];
        if (jsonData) {
            NSString *jsonLog = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
            //执行发送
#warning 发送崩溃日志
        }
    }
}

-(NSDictionary *)systemInfo
{
    NSString *deviceType=@"";
    struct utsname systemInfo;
    uname(&systemInfo);
    deviceType = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
//    NSString *model1 = [UIDevice currentDevice].model;
    NSString *appVersion =  [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    NSString *osversion = [[UIDevice currentDevice] systemVersion];
#warning 获取UDID
    NSString *csnUDID = @"";
    NSDictionary *sysInfo = @{@"DeviceType":deviceType, @"AppVersion":appVersion, @"SystemVersion":osversion, @"UDID":csnUDID};
    return sysInfo;
}
@end

void HandleException(NSException *exception)
{
    int32_t exceptionCount = OSAtomicIncrement32(&UncaughtExceptionCount);
    if (exceptionCount > UncaughtExceptionMaximum) {
        return;
    }
    
//    NSArray *callStack = [UncaughtExceptionHandler backtrace];
    NSArray *callStack = [exception callStackSymbols];
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithDictionary:[exception userInfo]];
    [userInfo setObject:callStack forKey:UncaughtExceptionHandlerAddressesKey];
    
    [[[UncaughtExceptionHandler alloc] init] performSelectorOnMainThread:@selector(handleException:) withObject: [NSException exceptionWithName:[exception name] reason:[exception reason] userInfo:userInfo] waitUntilDone:YES];
}

void SignalHandler(int signal)
{
    int32_t exceptionCount = OSAtomicIncrement32(&UncaughtExceptionCount);
    if (exceptionCount > UncaughtExceptionMaximum) {
        return;
    }
    
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithObject:[NSNumber numberWithInt:signal] forKey:UncaughtExceptionHandlerSignalKey];
    
    NSArray *callStack = [UncaughtExceptionHandler backtrace];
    [userInfo setObject:callStack forKey:UncaughtExceptionHandlerAddressesKey];
    
    [[[UncaughtExceptionHandler alloc] init] performSelectorOnMainThread:@selector(handleException:) withObject: [NSException exceptionWithName:UncaughtExceptionHandlerSignalExceptionName reason: [NSString stringWithFormat: @"Signal %d was raised.", signal] userInfo:userInfo] waitUntilDone:YES];
}

void InstallUncaughtExceptionHandler(void)
{
    NSSetUncaughtExceptionHandler(&HandleException);
    signal(SIGABRT, SignalHandler);
    signal(SIGILL, SignalHandler);
    signal(SIGSEGV, SignalHandler);
    signal(SIGFPE, SignalHandler);
    signal(SIGBUS, SignalHandler);
    signal(SIGPIPE, SignalHandler);
}
