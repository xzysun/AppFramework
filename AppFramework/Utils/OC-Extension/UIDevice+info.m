//
//  UIDevice+info.m
//  DataEase
//
//  Created by xzysun on 16/1/11.
//  Copyright © 2016年 AnyApps. All rights reserved.
//

#import "UIDevice+info.h"
#import "sys/utsname.h"

@implementation UIDevice (info)

-(NSString *)deviceModel
{
        struct utsname systemInfo;
        uname(&systemInfo);
        NSString *model = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
    return model;
}

-(NSString *)appVersion
{
    NSString *currentVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    return currentVersion;
}
@end
