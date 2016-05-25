//
//  Config.h
//  TengShare
//
//  Created by xzysun on 15/9/24.
//  Copyright © 2015年 anyApp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CocoaLumberjack.h"
#import "utils.h"
#import "UIColor+Hex.h"

#ifdef DEBUG
//控制DEBUG输出级别为详细
static const DDLogLevel ddLogLevel = DDLogLevelVerbose;
#else
//控制RELEASE输出级别为警告
static const DDLogLevel ddLogLevel = DDLogLevelInfo;
#endif

#pragma mark - Base Config
static NSString * const kServerBaseURL = @"https://127.0.0.1:8080";

#pragma mark -  Notifications
static NSString * const kNetworkStatusChangedNotification = @"kNetworkStatusChangedNotification";

#pragma mark - Constans
static NSString * const kStorageKeyUDID = @"StorageKeyUDID";
static NSString * const kStorageKeyAPSToken = @"StorageKeyAPSToken";
static NSString * const kStorageKeyUserName = @"StorageKeyUserName";
static NSString * const kStorageKeyPassword = @"StorageKeyPassword";

static NSInteger const kDefaultErrorCode = -9999;
static NSInteger const kNoCache = -1;
static NSInteger const kRefreshCache = 0;
static NSInteger const kDefaultTimeOut = 30;
static CGFloat const kDefaultNoticeShowTime = 3.0;
#pragma mark - Font & Color
static NSString * const kColorA = @"02B5D6";
static NSString * const kColorB = @"333333";
static NSString * const kColorC = @"666666";
static NSString * const kColorD = @"999999";
static NSString * const kColorE = @"F5A623";
static NSString * const kColorF = @"4A90E2";
static NSString * const kColorG = @"BBBBBB";
static NSString * const kColorH = @"E5E5E5";

static CGFloat kFont1 = 22.0;
static CGFloat kFont2 = 20.0;
static CGFloat kFont3 = 18.0;
static CGFloat kFont4 = 16.0;
static CGFloat kFont5 = 14.0;
static CGFloat kFont6 = 12.0;

#pragma mark - Server Error Code
static NSInteger const kServerErrorNotLogin = 401;

#pragma mark - Macros
//获取当前屏幕的宽度和高度
#define SCREEN_WIDTH			([[UIScreen mainScreen] bounds].size.width)
#define SCREEN_HEIGHT			([[UIScreen mainScreen] bounds].size.height)
//获取运行环境的版本
#define runTimeOSVersion [UIDevice currentDevice].systemVersion.floatValue
//判断是否在iPad上预习呢
#define isRunOnIPad (UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPhone && [[UIDevice currentDevice].model hasPrefix:@"iPad"])
//weakSelf
#define WeakSelf __weak typeof(self) weakSelf = self;
//Color Form Hex
#define HexColor(hex) [UIColor colorWithHex:hex]
//SDImageCacheDefaultOptions
#define SDImageDefaultOptions SDWebImageLowPriority|SDWebImageRetryFailed|SDWebImageAllowInvalidSSLCertificates

#define Singlton(className)\
static className *_instance;\
static dispatch_once_t onceToken;\
dispatch_once(&onceToken, ^{\
_instance = [[className alloc] init];\
});\
return _instance;