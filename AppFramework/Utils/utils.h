//
//  utils.h
//  GameVideoShare
//
//  Created by xzysun on 14-10-16.
//  Copyright (c) 2014年 AnyApps. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@class Video;
@class User;
@class Game;

//trim字符串两头的空白字符
NSString *trim(NSString *dirtyString);
//检查字符串是否为空
BOOL isStringEmpty(NSString *string);
//根据比例缩放图片
UIImage *scaleImage(UIImage *image, CGFloat scaleSize);
//将图像缩放到指定尺寸
UIImage *scaleToSize(UIImage *img, CGSize size);
//取图像正中间的矩形
UIImage *cutToSquareImage(UIImage *img);
//根据颜色生成图像
UIImage *imageFromColor(UIColor *color);
//根据颜色生成图像,带size参数
UIImage *imageFromColorWithSize(UIColor *color, CGSize size);
//从网址中截取域名
NSString *getDomainFromURLString(NSString *url);
//从image对象中获取data对象
NSData *getDataFromImage(UIImage *image);
//根据预计的尺寸压缩图片
NSData *compressImageWithExpectedFileSize(UIImage *image, NSInteger size);
//根据文本计算高度
CGFloat calculateAttributedTextHeightForWidth(NSAttributedString *text, CGFloat textWidth);
//根据文本计算宽度
CGFloat calculateAttributedTextWidthForHeight(NSAttributedString *text, CGFloat textHeight);
//根据发表时间返回时间提示的字符串
NSString *getTimeInfoString(NSDate *timestamp);
//返回MM:SS格式的时间
NSString *getFormatTimeInfo(NSInteger seconds);
typedef NS_OPTIONS(NSUInteger, ShadowPathSide) {
    ShadowPathSideNone = 0,
    ShadowPathSideTop = 1 << 0,
    ShadowPathSideRight = 1 << 1,
    ShadowPathSideBottom = 1 << 2,
    ShadowPathSideLeft = 1 << 3,
};
//可定制的绘制阴影路径的方法
CGPathRef getShawPathOnRect(CGRect frame, CGFloat width, ShadowPathSide sides);
//强制旋转屏幕到竖直状态
void rotateBackToOrientationPortrait();
//获取当前的屏幕方向
NSInteger getCurrentDeviceOrientation();
//获取当前显示的最顶层的ViewController
UIViewController *getTopMostViewController();