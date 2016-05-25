//
//  ListTypeFilter.m
//  ListTypeFilter
//
//  Created by xzysun on 15/8/20.
//  Copyright (c) 2015年 xzysun. All rights reserved.
//

#import "ListTypeFilter.h"
#import "Config.h"

@interface ListTypeFilter ()

@property (nonatomic, strong) UIView *scrollViewWrapper;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) NSMutableArray *buttonList;
@end

@implementation ListTypeFilter

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

-(void)dealloc
{
    self.selectionChangedBlock = nil;
}

-(void)setupViews
{
    self.backgroundColor = [UIColor whiteColor];
    self.buttonList = [NSMutableArray array];
    _currentIndex = -1;
    CGFloat width = CGRectGetWidth(self.frame);
    CGFloat height = CGRectGetHeight(self.frame);
    self.scrollViewWrapper = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, height)];
    self.scrollViewWrapper.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    [self addSubview:self.scrollViewWrapper];
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, width, height)];
    self.scrollView.backgroundColor = [UIColor clearColor];
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    self.scrollView.scrollsToTop = NO;
    [self.scrollViewWrapper addSubview:self.scrollView];
    //底部分割线
    UIView *separateLine = [[UIView alloc] initWithFrame:CGRectMake(0, height-0.5, width, 0.5)];
    separateLine.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleTopMargin;
    separateLine.backgroundColor = [UIColor colorWithHex:kColorF];
    [self addSubview:separateLine];
    //scrollView右端的渐变
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.frame = self.scrollViewWrapper.bounds;
    gradientLayer.startPoint = CGPointMake(0, 0.5);
    gradientLayer.endPoint = CGPointMake(1.0, 0.5);
    gradientLayer.colors = [NSArray arrayWithObjects:(id)[UIColor whiteColor].CGColor, (id)[UIColor whiteColor].CGColor, (id)[UIColor clearColor].CGColor, nil];
    gradientLayer.locations = @[@0, [NSNumber numberWithFloat:1.0-(20.0/self.scrollViewWrapper.frame.size.width)], @1.0];
    self.scrollViewWrapper.layer.mask = gradientLayer;
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    self.scrollViewWrapper.layer.mask.frame = self.scrollViewWrapper.bounds;
}

-(void)setItemList:(NSArray *)itemList
{
    _itemList = [itemList copy];
    [self setupButtons];
    if (itemList == nil || itemList.count == 0) {
        _currentIndex = -1;
    } else if (_currentIndex == -1) {
        [self setSeletedIndex:0 WithCallback:YES];
    } else {
        [self setSeletedIndex:_currentIndex WithCallback:NO];
    }
}

-(void)setupButtons
{
    if (self.buttonList) {
        for (UIButton *button in self.buttonList) {
            [button removeFromSuperview];
        }
        [self.buttonList removeAllObjects];
    }
    CGFloat lastMaxX = 10.0;
    CGFloat spaceX = 20.0;
    CGFloat height = CGRectGetHeight(self.frame);
    for (NSInteger i = 0; i < self.itemList.count; i ++) {
        NSString *title = [self.itemList objectAtIndex:i];
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setTitle:title forState:UIControlStateNormal];
        [self configButtonToNormalStyle:button];
        button.tag = i;
        CGFloat width = title.length*15.0 + spaceX;
        button.frame = CGRectMake(lastMaxX, 0, width, height);
        lastMaxX += width;
        [button addTarget:self action:@selector(itemButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.scrollView addSubview:button];
        [self.buttonList addObject:button];
    }
    self.scrollView.contentSize = CGSizeMake(lastMaxX, height);
}

-(void)configButtonToNormalStyle:(UIButton *)button
{
    [button setTitleColor:[UIColor colorWithHex:kColorE] forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont systemFontOfSize:kFont5];
}

-(void)setSeletedIndex:(NSInteger)index
{
    [self setSeletedIndex:index WithCallback:NO];
}

-(void)setSeletedIndex:(NSInteger)index WithCallback:(BOOL)callback
{
    if (self.buttonList.count == 0) {
        return;
    }
    if (self.currentIndex>=0 && self.currentIndex<self.buttonList.count) {
        UIButton *lastItem = [self.buttonList objectAtIndex:self.currentIndex];
        [self configButtonToNormalStyle:lastItem];
    }
    NSInteger oldIndex = self.currentIndex;
    _currentIndex = index;
    if (callback && index != oldIndex && self.selectionChangedBlock) {
        self.selectionChangedBlock(index);
    }
    UIButton *targetItem = [self.buttonList objectAtIndex:index];
    [targetItem setTitleColor:[UIColor colorWithHex:kColorA] forState:UIControlStateNormal];
    targetItem.titleLabel.font = [UIFont systemFontOfSize:kFont4];
    //调整位置
    if (self.scrollView.contentSize.width > CGRectGetWidth(self.scrollView.frame)) {
        CGPoint targetCenter = targetItem.center;
        CGFloat offsetX = targetCenter.x - CGRectGetWidth(self.frame)/2.0;
        offsetX = fmax(0.0, offsetX);
        offsetX = fmin((self.scrollView.contentSize.width-CGRectGetWidth(self.scrollView.frame)), offsetX);
        [self.scrollView setContentOffset:CGPointMake(offsetX, 0) animated:YES];
    } else {
        [self.scrollView setContentOffset:CGPointZero animated:YES];
    }
}

#pragma mark - Button Actions
-(void)itemButtonAction:(UIButton *)sender
{
    DDLogDebug(@"select type%ld", (long)sender.tag);
    [self setSeletedIndex:sender.tag WithCallback:YES];
}
@end
