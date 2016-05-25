//
//  GVSMoreMenuView.h
//  GameVideoShare
//
//  Created by xzysun on 15/7/17.
//  Copyright (c) 2015年 AnyApps. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^MoreMenuClickBlock)(NSInteger index);

typedef enum : NSUInteger {
    GVSMoreMenuViewPositionRight,
    GVSMoreMenuViewPositionMiddle,
    GVSMoreMenuViewPositionLeft,
} GVSMoreMenuViewPosition;

@interface GVSMoreMenuView : UIView

@property (nonatomic, assign) GVSMoreMenuViewPosition position;
@property (nonatomic, strong) NSArray<NSString *> *dataList;
@property (nonatomic, assign, readonly) BOOL isShowing;
@property (nonatomic, copy) MoreMenuClickBlock clickBlock;

+(instancetype)moreMenuForViewController:(UIViewController *)viewController;

-(void)showMenu;

-(void)hideMenu;
@end
