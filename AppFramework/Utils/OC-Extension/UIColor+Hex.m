//
//  UIColor+Hex.m
//  CrazySmallNote
//
//  Created by xzysun on 14-8-5.
//  Copyright (c) 2014年 AnyApps. All rights reserved.
//

#import "UIColor+Hex.h"

@implementation UIColor (Hex)

//将#RRGGBB格式的字符串转换为颜色
+(UIColor *)colorWithHex:(NSString *)hexString alpha:(float)alpha
{
    NSString  *colorString = [[hexString stringByReplacingOccurrencesOfString:@"#" withString:@""] uppercaseString];
    unsigned int hexInt = 0;
    NSScanner *scanner = [NSScanner scannerWithString:colorString];
    [scanner scanHexInt:&hexInt];
    unsigned redInt = (hexInt & 0xFF0000) >> 16;
    unsigned greenInt = (hexInt & 0xFF00) >> 8;
    unsigned blueInt = (hexInt & 0xFF);
    UIColor *color = [UIColor colorWithRed:(redInt/255.0) green:(greenInt/255.0) blue:(blueInt/255.0) alpha:alpha];
    return color;
}

+(UIColor *)colorWithHex:(NSString *)hexString
{
    return [[self class] colorWithHex:hexString alpha:1.0];
}
@end
