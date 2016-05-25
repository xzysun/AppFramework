//
//  AppDelegate.m
//  AppFramework
//
//  Created by xzysun on 16/5/25.
//  Copyright © 2016年 AnyApps. All rights reserved.
//

#import "AppDelegate.h"
#import "Config.h"
#import "UncaughtExceptionHandler.h"
#import "SDWebImageManager.h"
#import "KeyChainHelper.h"
#import "NSData+Conversion.h"
#import "AppService.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    /**
     *	注册 Log记录工具
     */
    [DDLog addLogger:[DDASLLogger sharedInstance] withLevel:ddLogLevel];//输出到Console.app
    [DDLog addLogger:[DDTTYLogger sharedInstance] withLevel:ddLogLevel];//输出到Xcode
    
    /**
     *  应用基础服务的初始化
     */
    [[AppService getService] launchInit];
    
    /**
     *  注册崩溃记录器 发送错误日志
     */
    InstallUncaughtExceptionHandler();
    [[UncaughtExceptionHandler new] sendCrashLog];
    
    /**
     *  初始化图片缓存
     */
    [SDWebImageManager sharedManager].imageCache.maxMemoryCost = 1024*1024*10;
    [SDWebImageManager sharedManager].imageCache.maxCacheSize = 30*1024*1024;
    
    /**
     *  注册APNS
     */
    [self registerNotification:application];
    //将推送的图标上的数字置为0
    application.applicationIconBadgeNumber = 0;
    
    /**
     *  处理从推送启动的情况
     */
    if (launchOptions && [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey]) {
#warning launch from notification
    }
    
    DDLogDebug(@"didFinishLaunchingWithOptions:%@", launchOptions);
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark - Notifications
-(void)registerNotification:(UIApplication *)application
{
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 80000
    if ([application respondsToSelector:@selector(registerUserNotificationSettings:)]) {
        //iOS8及以后版本的通知注册方式
        [application registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert|UIUserNotificationTypeBadge|UIUserNotificationTypeSound categories:nil]];
    } else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        [application registerForRemoteNotificationTypes: UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound];
#pragma clang diagnostic pop
    }
#else
    if (TARGET_OS_IPHONE) {
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:
         UIRemoteNotificationTypeAlert |
         UIRemoteNotificationTypeBadge |
         UIRemoteNotificationTypeSound];
    }
#endif
}

#ifdef __IPHONE_8_0
-(void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings
{
    DDLogInfo(@"注册了用户通知");
    //根据新的规则，只有在获得用户许可后才可以申请服务器消息推送
    [application registerForRemoteNotifications];
}
#endif

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    //记录device token到defaults
    NSString *deviceTokenStr = [deviceToken hexadecimalString];
    DDLogInfo(@"系统返回的推送token为:%@", deviceTokenStr);
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *storedToken = [defaults objectForKey:kStorageKeyAPSToken];
    if (storedToken == nil || ![storedToken isEqualToString:deviceTokenStr]) {
        DDLogWarn(@"获取到得token于保存的不一致");
        [defaults setObject:deviceTokenStr forKey:kStorageKeyAPSToken];
        [defaults synchronize];
        [AppService getService].pushToken = deviceTokenStr;
#warning update push token to server
    }
    
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    DDLogError(@"注册推送失败:%@", error);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
#warning handle push notification in active state
}
@end
