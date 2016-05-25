//
//  UIColor+Hex.h
//  CrazySmallNote
//
//  Created by xzysun on 14-8-5.
//  Copyright (c) 2014年 AnyApps. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (Hex)

+(UIColor *)colorWithHex:(NSString *)hexString alpha:(float)alpha;

+(UIColor *)colorWithHex:(NSString *)hexString;
@end
