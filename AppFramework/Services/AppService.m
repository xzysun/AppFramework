//
//  AppService.m
//  AppFramework
//
//  Created by xzysun on 16/5/25.
//  Copyright © 2016年 AnyApps. All rights reserved.
//

#import "AppService.h"
#import "Config.h"
#import <AdSupport/AdSupport.h>
#import "KeyChainHelper.h"

@implementation AppService

+(instancetype)getService
{
    Singlton(AppService)
}

-(void)launchInit
{
    self.pushToken = [[NSUserDefaults standardUserDefaults] objectForKey:kStorageKeyAPSToken];
    if (self.pushToken == nil) {
        self.pushToken = @"";
    }
    [self initUdid];
    [self initVersionCheck];
    //初始化应用参数
    
}

#pragma mark - Private
-(void)initUdid
{
    NSString *idfa = [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
    NSString *storedUdid = [KeyChainHelper searchKeyChainValue:kStorageKeyUDID];
    DDLogInfo(@"系统返回的设备标识:%@", idfa);
    WeakSelf
    if (isStringEmpty(idfa)) {
        DDLogWarn(@"系统返回的IDFA是空值，准备稍后重试");
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [weakSelf initUdid];
        });
        if (isStringEmpty(storedUdid)) {
            DDLogWarn(@"未能获取到keychain中保存的UDID，使用空字符串做为UDID");
            weakSelf.udid = @"";
        } else {
            weakSelf.udid = storedUdid;
        }
    } else {
        //获取到设备标识的情况
        weakSelf.udid = idfa;
        [KeyChainHelper createKeyChainValue:kStorageKeyUDID value:idfa];
    }
}

-(void)initVersionCheck
{
    //TODO
}
@end
