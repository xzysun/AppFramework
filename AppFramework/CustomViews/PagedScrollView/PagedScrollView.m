//
//  PagedScrollView.m
//  ListTypeFilter
//
//  Created by xzysun on 15/8/21.
//  Copyright (c) 2015年 xzysun. All rights reserved.
//

#import "PagedScrollView.h"

@interface PagedScrollView () <UIScrollViewDelegate>

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIView *previousView;
@property (nonatomic, strong) UIView *currentView;
@property (nonatomic, strong) UIView *nextView;
@end

@implementation PagedScrollView

-(instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        //init
        [self setupViews];
    }
    return self;
}

-(void)awakeFromNib
{
    [super awakeFromNib];
    [self setupViews];
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    [self updatePageViewFrame];
}

-(void)setupViews
{
    _currentPageIndex = 0;
    self.scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
    self.scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    self.scrollView.pagingEnabled = YES;
    self.scrollView.delegate = self;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.scrollsToTop = NO;
    self.scrollView.directionalLockEnabled = YES;
    [self addSubview:self.scrollView];
}

-(void)setPageHorizontalGap:(CGFloat)pageHorizontalGap
{
    _pageHorizontalGap = pageHorizontalGap;
    self.scrollView.frame = CGRectMake(-pageHorizontalGap/2.0, 0, CGRectGetWidth(self.frame)+pageHorizontalGap, CGRectGetHeight(self.frame));
    self.scrollView.contentInset = UIEdgeInsetsMake(0, pageHorizontalGap/2.0, 0, pageHorizontalGap/2.0);
    [self updatePageViewFrame];
}

-(void)loadPages
{
    [self.previousView removeFromSuperview];
    [self.nextView removeFromSuperview];
    self.previousView = nil;
    self.nextView = nil;
    NSInteger pageCount = 0;
    if (self.datasource && [self.datasource respondsToSelector:@selector(numberOfPagesInScrollView)] && [self.datasource respondsToSelector:@selector(pageForScrollViewAtIndex:)]) {
        pageCount = [self.datasource numberOfPagesInScrollView];
    }
    if (pageCount == 0) {
        [self.currentView removeFromSuperview];
        self.currentView = nil;
        return;
    }
    if (_currentPageIndex > 0) {
        self.previousView = [self.datasource pageForScrollViewAtIndex:_currentPageIndex-1];
        [self.scrollView addSubview:self.previousView];
    }
    UIView *newCurrentView = [self.datasource pageForScrollViewAtIndex:_currentPageIndex];
    if (newCurrentView != self.currentView) {//针对当前视图进行特别处理，避免重复调用的时候页面闪烁
        [self.currentView removeFromSuperview];
        self.currentView = newCurrentView;
    }
    [self.scrollView addSubview:self.currentView];
    if (_currentPageIndex < pageCount - 1) {
        self.nextView = [self.datasource pageForScrollViewAtIndex:_currentPageIndex+1];
        [self.scrollView addSubview:self.nextView];
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(pageScrollViewDidShowPageAtIndex:)]) {
        [self.delegate pageScrollViewDidShowPageAtIndex:_currentPageIndex];
    }
    [self updatePageViewFrame];
}

-(void)updatePageViewFrame
{
    NSInteger pageCount = 0;
    if (self.datasource && [self.datasource respondsToSelector:@selector(numberOfPagesInScrollView)] && [self.datasource respondsToSelector:@selector(pageForScrollViewAtIndex:)]) {
        pageCount = [self.datasource numberOfPagesInScrollView];
    }
    if (pageCount == 0) {
        return;
    }
    //更新ScrollView内部的大小
    CGFloat pageWidth = CGRectGetWidth(self.scrollView.frame);
    CGFloat pageHeight = CGRectGetHeight(self.scrollView.frame);
    CGRect frame = self.scrollView.bounds;
    frame.size.width -= (self.scrollView.contentInset.left+self.scrollView.contentInset.right);
    frame.origin.x = self.scrollView.contentInset.left;
    if (self.previousView) {
        self.previousView.frame = frame;
        frame.origin.x += pageWidth;
    }
    if (self.currentView) {
        self.currentView.frame = frame;
        frame.origin.x += pageWidth;
    }
    if (self.nextView) {
        self.nextView.frame = frame;
    }
    NSInteger showPageCount = 3;
    if (self.previousView == nil) {
        showPageCount --;
    }
    if (self.nextView == nil) {
        showPageCount --;
    }
    self.scrollView.contentSize = CGSizeMake(pageWidth*showPageCount, pageHeight);
    if (self.previousView) {
        self.scrollView.contentOffset = CGPointMake(pageWidth, 0);
    } else {
        self.scrollView.contentOffset = CGPointZero;
    }
}

-(void)showPageWithIndex:(NSInteger)index ReloadPages:(BOOL)reloadPages
{
    NSInteger pageCount = 0;
    if (self.datasource && [self.datasource respondsToSelector:@selector(numberOfPagesInScrollView)] && [self.datasource respondsToSelector:@selector(pageForScrollViewAtIndex:)]) {
        pageCount = [self.datasource numberOfPagesInScrollView];
    }
    if (pageCount == 0) {
        return;
    }
    if (index < 0 || index >= pageCount) {
        return;
    }
    [self.previousView removeFromSuperview];
    [self.currentView removeFromSuperview];
    [self.nextView removeFromSuperview];
    if (reloadPages) {
        self.previousView = nil;
        self.currentView = nil;
        self.nextView = nil;
    } else if (index == _currentPageIndex-1) {
        self.nextView = self.currentView;
        self.currentView = self.previousView;
        self.previousView = nil;
    } else if (index == _currentPageIndex) {
        //do nothing
    } else if (index == _currentPageIndex+1) {
        self.previousView = self.currentView;
        self.currentView = self.nextView;
        self.nextView = nil;
    } else {
        //show pages not nearby
        self.previousView = nil;
        self.currentView = nil;
        self.nextView = nil;
    }
    if (index > 0) {
        if (self.previousView == nil) {
            self.previousView = [self.datasource pageForScrollViewAtIndex:index-1];
        }
        [self.scrollView addSubview:self.previousView];
    } else {
        self.previousView = nil;
    }
    if (self.currentView == nil) {
        self.currentView = [self.datasource pageForScrollViewAtIndex:index];
    }
    [self.scrollView addSubview:self.currentView];
    if (index < pageCount-1) {
        if (self.nextView == nil) {
            self.nextView = [self.datasource pageForScrollViewAtIndex:index+1];
        }
        [self.scrollView addSubview:self.nextView];
    } else {
        self.nextView = nil;
    }
    [self updatePageViewFrame];
    if ((index != _currentPageIndex||reloadPages) && self.delegate && [self.delegate respondsToSelector:@selector(pageScrollViewDidShowPageAtIndex:)]) {
        [self.delegate pageScrollViewDidShowPageAtIndex:index];
    }
    _currentPageIndex = index;
}

#pragma mark - Scroll View Delegate
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self handleScrollAction];
}

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if (scrollView.isDecelerating) {
        [self handleScrollAction];
    }
}

-(void)handleScrollAction
{
    NSInteger pageCount = 0;
    if (self.datasource && [self.datasource respondsToSelector:@selector(numberOfPagesInScrollView)] && [self.datasource respondsToSelector:@selector(pageForScrollViewAtIndex:)]) {
        pageCount = [self.datasource numberOfPagesInScrollView];
    }
    if (pageCount == 0) {
        return;
    }
    CGFloat pageWidth = CGRectGetWidth(self.scrollView.frame);
    NSInteger pageIndex = round(self.scrollView.contentOffset.x / pageWidth);
    NSLog(@"current scroll state:%ld", (long)pageIndex);
    if (pageIndex == 0) {
        //向前翻了一页
        [self showPageWithIndex:_currentPageIndex-1 ReloadPages:NO];
    } else if (pageIndex == 2 || (pageIndex==1&&self.previousView==nil)) {
        //向后翻了一页
        [self showPageWithIndex:_currentPageIndex+1 ReloadPages:NO];
    } else {
        //页码未发生变化
    }
//    if (pageIndex == 0 && self.previousView) {
//        //向前翻了一页
//        _currentPageIndex --;
//        [self.nextView removeFromSuperview];
//        self.nextView = self.currentView;
//        self.currentView = self.previousView;
//        if (pageCount > 2 && _currentPageIndex-1>=0) {
//            self.previousView = [self.datasource pageForScrollViewAtIndex:_currentPageIndex-1];
//            [self.scrollView addSubview:self.previousView];
//        } else {
//            self.previousView = nil;
//            [self.previousView removeFromSuperview];
//        }
//    } else if ((pageIndex == 2||(pageIndex==1&&self.previousView==nil)) && self.nextView) {
//        //向后翻了一页
//        _currentPageIndex ++;
//        [self.previousView removeFromSuperview];
//        self.previousView = self.currentView;
//        self.currentView = self.nextView;
//        if (pageCount > 2 && _currentPageIndex+1<pageCount) {
//            self.nextView = [self.datasource pageForScrollViewAtIndex:_currentPageIndex+1];
//            [self.scrollView addSubview:self.nextView];
//        } else {
//            self.nextView = nil;
//            [self.nextView removeFromSuperview];
//        }
//    } else {
//        //页码未发生变化
//        return;
//    }
//    [self updatePageViewFrame];
//    NSLog(@"准备显示页面%ld", (long)_currentPageIndex);
//    if (self.delegate && [self.delegate respondsToSelector:@selector(pageScrollViewDidShowPageAtIndex:)]) {
//        [self.delegate pageScrollViewDidShowPageAtIndex:_currentPageIndex];
//    }
}
@end
