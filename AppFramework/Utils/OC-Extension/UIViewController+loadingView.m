//
//  UIViewController+loadingView.m
//  CrazySmallNote
//
//  Created by xzysun on 14-8-5.
//  Copyright (c) 2014年 AnyApps. All rights reserved.
//

#import "UIViewController+loadingView.h"
#import "MBProgressHUD.h"
#import "CSNotificationView.h"
#import "Config.h"
#import "UIAlertController+Blocks.h"

@implementation UIViewController (loadingView)

-(MBProgressHUD *)showLoadingViewWithText:(NSString *)text
{
    MBProgressHUD *loadingView = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:loadingView];
    loadingView.labelText = text;
    [loadingView show:YES];
    return loadingView;
}

-(void)hideAllLoadingView
{
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
}

-(void)hideLoadingAfter:(NSTimeInterval)time
{
    MBProgressHUD *loadingView = [MBProgressHUD HUDForView:self.view];
    [loadingView hide:YES afterDelay:time];
}

-(void)showNoticeViewWithType:(GVSNoticeType)type Message:(NSString *)text Delay:(NSTimeInterval)delay
{
    UIColor *tintColor = nil;
    UIImage *image = nil;
    if (type == GVSNoticeTypeNormal) {
        tintColor = [UIColor colorWithRed:0.000 green:0.6 blue:1.000 alpha:1];
        image = [CSNotificationView imageForStyle:CSNotificationViewStyleSuccess];
    } else if (type == GVSNoticeTypeSuccess) {
        tintColor = [UIColor colorWithRed:0.21 green:0.72 blue:0.00 alpha:1.0];;
        image = [CSNotificationView imageForStyle:CSNotificationViewStyleSuccess];
    } else {
        tintColor = [UIColor redColor];;
        image = [CSNotificationView imageForStyle:CSNotificationViewStyleError];
    }
    CSNotificationView *notificationView = [CSNotificationView notificationViewWithParentViewController:self tintColor:tintColor image:image message:text];
    if (notificationView==nil) {
        return;
    }
    UIView *statusBackgroundView = nil;
    if (self.navigationController && self.navigationController.navigationBarHidden) {
        statusBackgroundView = [[UIView alloc] initWithFrame:[UIApplication sharedApplication].statusBarFrame];
        statusBackgroundView.backgroundColor = [UIColor blackColor];
        [[[UIApplication sharedApplication].delegate window] addSubview:statusBackgroundView];
    }
    __weak CSNotificationView *weakNotificationView = notificationView;
    __weak typeof(self) weakSelf = self;
    [notificationView setVisible:YES animated:YES completion:^{
        if (weakSelf.navigationController && weakSelf.navigationController.navigationBarHidden) {
            [weakSelf.view addSubview:weakNotificationView];
        }
        if (delay > 0) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [weakNotificationView setVisible:NO animated:YES completion:^{
                    if (statusBackgroundView) {
                        [statusBackgroundView removeFromSuperview];
                    }
                }];
            });
        }
    }];
    notificationView.tapHandler = ^{
        [weakNotificationView setVisible:NO animated:YES completion:^{
            if (statusBackgroundView) {
                [statusBackgroundView removeFromSuperview];
            }
        }];
    };
    
}

-(void)showAlertViewWithTitle:(NSString *)title Message:(NSString *)message Delay:(NSTimeInterval)delay
{
    if (title == nil) {
        title = @"";
    }
    if (runTimeOSVersion > 8.0) {
        UIAlertController *alert = [UIAlertController showAlertInViewController:self withTitle:title message:message cancelButtonTitle:@"确定" destructiveButtonTitle:nil otherButtonTitles:nil tapBlock:^(UIAlertController * _Nonnull controller, UIAlertAction * _Nonnull action, NSInteger buttonIndex) {
            //
        }];
        if (delay > 0.0) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [alert.presentingViewController dismissViewControllerAnimated:YES completion:^{
                    //
                }];
            });
        }
        return;
    }
    if (delay > 0.0) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:nil otherButtonTitles: nil];
        [alertView show];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [alertView dismissWithClickedButtonIndex:alertView.cancelButtonIndex animated:YES];
        });
    } else {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
        [alertView show];
    }
}
@end
