//
//  UIViewController+BlockSegue.h
//  GameVideoShare
//
//  Created by xzysun on 15/8/6.
//  Copyright (c) 2015年 AnyApps. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^SeguePreparationBlock)(UIViewController *destinationVC);

@interface UIViewController (BlockSegue)

/**
 *  执行一个Segue并通过block准备segue
 *
 *  @param segueIndetifier 要执行segue的Identifier
 *  @param preparation      在PrepareSegue方法执行的时候调用，用于传递参数
 */
-(void)presentViewControllerWithSegueIdentifier:(NSString *)segueIndetifier AndPreparation:(SeguePreparationBlock)preparation;

@end
