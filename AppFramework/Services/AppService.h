//
//  AppService.h
//  AppFramework
//
//  Created by xzysun on 16/5/25.
//  Copyright © 2016年 AnyApps. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User.h"

@interface AppService : NSObject

@property (nonatomic, strong) NSString *udid;
@property (nonatomic, strong) NSString *pushToken;
@property (nonatomic, strong) User *currentUser;

+(instancetype)getService;

/**
 *  启动初始化，需要在应用启动的时候调用
 */
-(void)launchInit;

@end
