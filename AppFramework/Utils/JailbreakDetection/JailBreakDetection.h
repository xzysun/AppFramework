//
//  JailBreakDetection.h
//  DataEase
//
//  Created by xzysun on 16/1/8.
//  Copyright © 2016年 AnyApps. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JailBreakDetection : NSObject

/**
 *  判断当前设备是否越狱
 *
 *  @return 返回YES表示当前设备越狱
 */
+(BOOL)isJailBroken;

@end
