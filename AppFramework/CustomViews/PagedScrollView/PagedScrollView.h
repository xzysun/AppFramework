//
//  PagedScrollView.h
//  ListTypeFilter
//
//  Created by xzysun on 15/8/21.
//  Copyright (c) 2015年 xzysun. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PagedScrollViewDatasource <NSObject>

/**
 *  返回当前的PagedScrollView里面有多少个page
 *
 *  @return 总共page的数量
 */
-(NSInteger)numberOfPagesInScrollView;
/**
 *  返回当前index对应的页面
 *
 *  @param index 页面的index
 *
 *  @return index对应的页面
 */
-(UIView *)pageForScrollViewAtIndex:(NSInteger)index;
@end

@protocol PagedScrollViewDelegate <NSObject>

/**
 *  PageScrollView展示了一个页面，在初始化加载的时候也会触发这个回调
 *
 *  @param index 展示页面的index
 */
-(void)pageScrollViewDidShowPageAtIndex:(NSInteger)index;
@end

@interface PagedScrollView : UIView

@property (nonatomic, weak) id<PagedScrollViewDatasource> datasource;
@property (nonatomic, weak) id<PagedScrollViewDelegate> delegate;
/**
 *  当前展示的页面的index
 */
@property (nonatomic, assign, readonly) NSInteger currentPageIndex;
/**
 *  页面之间的间隙
 */
@property (nonatomic, assign) CGFloat pageHorizontalGap;

/**
 *  初始化加载数据，请确保配置了数据源
 */
-(void)loadPages;

/**
 *  切换到页面index，对于临近的页面默认会重用，而不是每次都加载新的页面
 *
 *  @param index       需要显示的页面index
 *  @param reloadPages 是否重新加载页面
 */
-(void)showPageWithIndex:(NSInteger)index ReloadPages:(BOOL)reloadPages;
@end
