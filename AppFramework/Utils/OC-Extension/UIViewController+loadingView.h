//
//  UIViewController+loadingView.h
//  CrazySmallNote
//
//  Created by xzysun on 14-8-5.
//  Copyright (c) 2014年 AnyApps. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    GVSNoticeTypeNormal,
    GVSNoticeTypeSuccess,
    GVSNoticeTypeError,
} GVSNoticeType;

@class MBProgressHUD;
@interface UIViewController (loadingView)

/**
*  显示一个读取的loading框，使用MBProgressHUD实现
*
*  @param text 说明loading状态的文本
*
*  @return 返回显示的MBProgressHUB，用于自定义
*/
-(MBProgressHUD *)showLoadingViewWithText:(NSString *)text;

/**
 *  隐藏当前页面弹出的loading框
 */
-(void)hideAllLoadingView;

/**
 *  显示loading框，在指定秒之后自动隐藏
 *
 *  @param time 指定的显示时长
 */
-(void)hideLoadingAfter:(NSTimeInterval)time;

/**
 *  显示一个消息提示框，如果传入的时间为0，则包含一个确定按钮
 *
 *  @param type 消息框的类型
 *  @param text  消息框正文
 *  @param delay 自动消失的延迟，单位秒，传入0的时候不会自动消失
 */
-(void)showNoticeViewWithType:(GVSNoticeType)type Message:(NSString *)text Delay:(NSTimeInterval)delay;

/**
 *  使用系统的AlertView显示一个消息提示框，如果传入的时间为0，则包含一个确定按钮
 *
 *  @param title   消息框的标题，可以为空
 *  @param message 消息框正文
 *  @param delay   自动消失的延迟，单位秒，传入0的时候不会自动消失
 */
-(void)showAlertViewWithTitle:(NSString *)title Message:(NSString *)message Delay:(NSTimeInterval)delay;
@end
