//
//  ListTypeFilter.h
//  ListTypeFilter
//
//  Created by xzysun on 15/8/20.
//  Copyright (c) 2015年 xzysun. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^ListTypeFilterSelectionChangedBlock)(NSInteger newIndex);

@interface ListTypeFilter : UIView

/**
 *  当前选中的对象列表
 */
@property (nonatomic, copy) NSArray *itemList;
/**
 *  当前选择的index
 */
@property (nonatomic, assign, readonly) NSInteger currentIndex;
/**
 *  传递新的选中的index
 */
@property (nonatomic, copy) ListTypeFilterSelectionChangedBlock selectionChangedBlock;
/**
 *  选择列表筛选器的index，会执行动画，不会触发回调
 *
 *  @param index 切换到的index
 */
-(void)setSeletedIndex:(NSInteger)index;
@end
