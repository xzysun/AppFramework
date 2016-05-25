//
//  utils.m
//  GameVideoShare
//
//  Created by xzysun on 14-10-16.
//  Copyright (c) 2014年 AnyApps. All rights reserved.
//

#import "utils.h"
#import "Config.h"

//trim字符串两头的空白字符
NSString *trim(NSString *dirtyString)
{
    NSString *cleanString = [dirtyString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    return cleanString;
}

//检查字符串是否为空
BOOL isStringEmpty(NSString *string)
{
    if (string != nil && string != (id)[NSNull null] && string.length > 0 ) {
        return NO;
    }
    return YES;
}

//根据比例缩放图片
UIImage *scaleImage(UIImage *image, CGFloat scaleSize)
{
    UIGraphicsBeginImageContext(CGSizeMake(image.size.width*scaleSize, image.size.height*scaleSize));
    [image drawInRect:CGRectMake(0, 0, image.size.width*scaleSize, image.size.height*scaleSize)];
    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return scaledImage;
}

//将图像缩放到指定尺寸
UIImage *scaleToSize(UIImage *img, CGSize size){
    // 创建一个bitmap的context
    // 并把它设置成为当前正在使用的context
    UIGraphicsBeginImageContext(size);
    // 绘制改变大小的图片
    [img drawInRect:CGRectMake(0, 0, size.width, size.height)];
    // 从当前context中创建一个改变大小后的图片
    UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    // 使当前的context出堆栈
    UIGraphicsEndImageContext();
    // 返回新的改变大小后的图片
    return scaledImage;
}

//取图像正中间的矩形
UIImage *cutToSquareImage(UIImage *img)
{
    CGSize imgSize = img.size;
    if (imgSize.width == imgSize.height) {
        return img;
    }
    
    CGRect newRect = CGRectZero;
    if(imgSize.width<imgSize.height){
        //较高的图片
        newRect = CGRectMake(0, (imgSize.height - imgSize.width) / 2, imgSize.width, imgSize.width);
    }else{
        //较宽的图片
        newRect = CGRectMake((imgSize.width - imgSize.height) / 2, 0, imgSize.height, imgSize.height);
    }
    UIImage * cutImg = [UIImage imageWithCGImage:CGImageCreateWithImageInRect([img CGImage], newRect)];
    return cutImg;
}

//根据颜色生成图像
UIImage *imageFromColor(UIColor *color)
{
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

//根据颜色生成图像，带size参数
UIImage *imageFromColorWithSize(UIColor *color, CGSize size)
{
    CGRect rect = CGRectMake(0.0f, 0.0f, size.width, size.height);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

//从网址中截取域名
NSString *getDomainFromURLString(NSString *url)
{
    NSRange rangeHeader = [url rangeOfString:@"://"];
    if (rangeHeader.location != NSNotFound) {
        url = [url substringFromIndex:(rangeHeader.location+rangeHeader.length)];
    }
    NSRange rangePort = [url rangeOfString:@":"];
    if (rangePort.location != NSNotFound) {
        url = [url substringToIndex:rangePort.location];
    }
    NSRange rangeTail = [url rangeOfString:@"/"];
    if (rangeTail.location != NSNotFound) {
        url = [url substringToIndex:rangeTail.location];
    }
    return url;
}

//从image对象中获取data对象
NSData *getDataFromImage(UIImage *image)
{
    NSData *data = UIImagePNGRepresentation(image);
    if (data == nil || data.length == 0) {
        data = UIImageJPEGRepresentation(image, 1.0);
    }
    return data;
}

//根据预计的尺寸压缩图片
NSData *compressImageWithExpectedFileSize(UIImage *image, NSInteger size)
{
    NSData *data = UIImageJPEGRepresentation(image, 0.9);
    int tryCount = 0;
    while (data.length > size) {
        UIImage *tmpImage = [UIImage imageWithData:data];
        data = UIImageJPEGRepresentation(tmpImage, 0.5);
        if (tryCount > 3) {
            DDLogWarn(@"经过尝试还未能把图片压缩到预计的大小，放弃继续压缩，最终的文件尺寸为:%lu", (unsigned long)data.length);
            break;
        }
        tryCount ++;
    }
    return data;
}

//根据文本计算高度
CGFloat calculateAttributedTextHeightForWidth(NSAttributedString *text, CGFloat textWidth)
{
    if (text.length > 0) {
        CGRect textRect = [text boundingRectWithSize:CGSizeMake(textWidth, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading context:nil];
        return ceilf(textRect.size.height);
    } else {
        return 0.0;
    }
}

//根据文本计算高度
CGFloat calculateAttributedTextWidthForHeight(NSAttributedString *text, CGFloat textHeight)
{
    if (text.length > 0) {
        CGRect textRect = [text boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, textHeight) options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading context:nil];
        return ceilf(textRect.size.width);
    } else {
        return 0.0;
    }
}

NSString *getTimeInfoString(NSDate *timestamp)
{
    NSDate *fromDate = [NSDate date];
    double seconds = [fromDate timeIntervalSinceDate:timestamp];
    int numberS = seconds / 60;
    NSString *timeInfo = @"未知";
    if (numberS == 0) {
        timeInfo = @"刚刚";
    }
    else if (numberS >=1 && numberS <= 60){
        timeInfo = [NSString stringWithFormat:@"%d分钟前", numberS];
    }
    else if (numberS > 60 && numberS <= 60*24){
        int numberH = numberS / 60;
        timeInfo = [NSString stringWithFormat:@"%d小时前", numberH];
    }
    else if (numberS > 60*24 && numberS <= 60*24*30){
        int numberD = numberS / 60 / 24;
        timeInfo = [NSString stringWithFormat:@"%d天前", numberD];
    }
    else if (numberS > 60*24*30 && numberS <= 60*24*30*12){
        int numberW = numberS / 60 / 24 / 30;
        timeInfo = [NSString stringWithFormat:@"%d月前", numberW];
    }
    else if (numberS > 60*24*30*12){
        timeInfo = @"1年前";
    }
    return timeInfo;
}

NSString *getFormatTimeInfo(NSInteger seconds)
{
    NSInteger minutes = seconds / 60;
    NSInteger s = seconds - minutes * 60;
    NSString *formatStr;
    if (s<10) {
        formatStr = [NSString stringWithFormat:@"%ld:0%ld",(long)minutes,(long)s];
    }else{
        formatStr = [NSString stringWithFormat:@"%ld:%ld",(long)minutes,(long)s];
    }
    return formatStr;
}

CGPathRef getShawPathOnRect(CGRect frame, CGFloat width, ShadowPathSide sides)
{
    if (sides == ShadowPathSideNone) {
        return nil;
    }
    CGFloat leftValue = (sides&ShadowPathSideLeft)?(0.0-width):0.0;
    CGFloat topValue = (sides&ShadowPathSideTop)?(0.0-width):0.0;
    CGFloat rightValue = (sides&ShadowPathSideRight)?(CGRectGetWidth(frame)+width):CGRectGetWidth(frame);
    CGFloat bottomValue = (sides&ShadowPathSideBottom)?(CGRectGetHeight(frame)+width):CGRectGetHeight(frame);
    CGPoint middlePoint = CGPointMake(CGRectGetWidth(frame)/2.0, CGRectGetHeight(frame)/2.0);
    //begin to draw path
    UIBezierPath *path = [UIBezierPath bezierPath];
    //start from top left point
    [path moveToPoint:CGPointMake(leftValue, topValue)];
    if (!(sides&ShadowPathSideTop)) {
        //not on top, line go to the middle point
        [path addLineToPoint:middlePoint];
    }
    //move to top right point
    [path addLineToPoint:CGPointMake(rightValue, topValue)];
    if (!(sides&ShadowPathSideRight)) {
        //not on right, line go to the middle point
        [path addLineToPoint:middlePoint];
    }
    //move to bottom right point
    [path addLineToPoint:CGPointMake(rightValue, bottomValue)];
    if (!(sides&ShadowPathSideBottom)) {
        //not on bottom, line go to the middle point
        [path addLineToPoint:middlePoint];
    }
    //move to bottom left point
    [path addLineToPoint:CGPointMake(leftValue, bottomValue)];
    if (!(sides&ShadowPathSideLeft)) {
        //not on left, line go to the middle point
        [path addLineToPoint:middlePoint];
    }
    //close path
    [path closePath];
    return path.CGPath;
}

//强制旋转屏幕到竖直状态
void rotateBackToOrientationPortrait()
{
    [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger: UIInterfaceOrientationPortrait] forKey:@"orientation"];
}

//获取当前的屏幕方向
NSInteger getCurrentDeviceOrientation()
{
    return [[[UIDevice currentDevice] valueForKey:@"orientation"] integerValue];
}

UIViewController *getTopMostViewController()
{
    UIViewController *tmpVC = [[UIApplication sharedApplication].delegate window].rootViewController;
    if (tmpVC == nil) {
        return tmpVC;
    }
    if ([tmpVC isKindOfClass:[UITabBarController class]]) {
        tmpVC = ((UITabBarController *)tmpVC).selectedViewController;
    }
    if ([tmpVC isKindOfClass:[UINavigationController class]]) {
        tmpVC = ((UINavigationController *)tmpVC).topViewController;
    }
    return tmpVC;
}