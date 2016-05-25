//
//  GVSMoreMenuView.m
//  GameVideoShare
//
//  Created by xzysun on 15/7/17.
//  Copyright (c) 2015年 AnyApps. All rights reserved.
//

#import "GVSMoreMenuView.h"
#import "Config.h"

#define Table_Separate_Line_Color @"CCCCCC"
#define Menu_Item_Text_Color @"3D7C99"
#define Menu_Item_Font 16.0
#define Menu_Max_Width 200.0

static CGFloat const kMoreMenuDefaultWidth = 120.0;
static CGFloat const kMoreMenuDefaultLineHeight = 40.0;
static CGFloat const kMoreMenuDefaultTopMargin = 0.0;
static CGFloat const kMoreMenuDefaultHorizontalMargin = 10.0;
static CGFloat const kMoreMenuDefaultArrowHeight = 6.0;
static CGFloat const kMoreMenuDefaultArrowWidth = 10.0;
static CGFloat const kMoreMenuDefaultArrowOffset = 10.0;

@interface GVSMoreMenuView () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, assign) CGFloat calculatedWidth;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIView *maskView;
@property (nonatomic, weak) UIViewController *viewController;
@end

@implementation GVSMoreMenuView

+(instancetype)moreMenuForViewController:(UIViewController *)viewController
{
    GVSMoreMenuView *moreMenuView = [[GVSMoreMenuView alloc] initWithFrame:CGRectZero];
    moreMenuView.viewController = viewController;
    moreMenuView.calculatedWidth = kMoreMenuDefaultWidth;
    return moreMenuView;
}

-(void)showMenu
{
    [self updateFrame];
    self.maskView.frame = self.viewController.view.bounds;
    [self.viewController.view addSubview:self.maskView];
    [self.viewController.view addSubview:self];
}

-(void)hideMenu
{
    [self.maskView removeFromSuperview];
    [self removeFromSuperview];
}

-(BOOL)isShowing
{
    return (self.superview != nil);
}

#pragma mark - Private Method
-(UITableView *)tableView
{
    if (_tableView == nil) {
        CGRect frame = self.bounds;
        frame.origin.y = kMoreMenuDefaultArrowHeight;
        frame.size.height -= kMoreMenuDefaultArrowHeight;
        _tableView = [[UITableView alloc] initWithFrame:frame style:UITableViewStylePlain];
        _tableView.scrollEnabled = NO;
        _tableView.separatorColor = [UIColor colorWithHex:Table_Separate_Line_Color];
        _tableView.clipsToBounds = YES;
        _tableView.separatorInset = UIEdgeInsetsZero;
        _tableView.dataSource = self;
        _tableView.delegate = self;
        if (runTimeOSVersion >= 8.0) {
            _tableView.layoutMargins = UIEdgeInsetsZero;
        }
        _tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
        _tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        [self addSubview:_tableView];
    }
    return _tableView;
}

-(UIView *)maskView
{
    if (_maskView == nil) {
        _maskView = [[UIView alloc] initWithFrame:CGRectZero];
        _maskView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.2];
        _maskView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        [self addSubview:_maskView];
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(maskViewTapGesture:)];
        [_maskView addGestureRecognizer:tapGesture];
    }
    return _maskView;
}

-(void)setDataList:(NSArray<NSString *> *)dataList
{
    _dataList = dataList;
    [self updateFrame];
    [self.tableView reloadData];
    //计算宽度
    CGFloat width = kMoreMenuDefaultWidth;
    NSDictionary *attrs = @{NSFontAttributeName:[UIFont systemFontOfSize:Menu_Item_Font]};
    for (NSString *string in dataList) {
        CGFloat calculated = [string sizeWithAttributes:attrs].width;
        width = MAX(width, calculated);
    }
    width += 30.0;//默认的左右空白
    width = MIN(width, Menu_Max_Width);
    self.calculatedWidth = width;
}

-(void)updateFrame
{
    CGFloat height = self.dataList.count * kMoreMenuDefaultLineHeight + kMoreMenuDefaultArrowHeight;
    if (self.viewController) {
        CGFloat x = 0;
        if (self.position == GVSMoreMenuViewPositionLeft) {
            x = kMoreMenuDefaultHorizontalMargin;
        } else if (self.position == GVSMoreMenuViewPositionMiddle) {
            x = CGRectGetWidth(self.viewController.view.frame)/2.0 - self.calculatedWidth/2.0;
        } else {
            x = CGRectGetWidth(self.viewController.view.frame) - self.calculatedWidth - kMoreMenuDefaultHorizontalMargin;
        }
        //有viewcontroller
        if (self.viewController.navigationController && !self.viewController.navigationController.navigationBarHidden) {
            //有导航栏
            self.frame = CGRectMake(x, self.viewController.topLayoutGuide.length+kMoreMenuDefaultTopMargin, self.calculatedWidth, height);
        } else {
            self.frame = CGRectMake(x, kMoreMenuDefaultTopMargin, self.calculatedWidth, height);
        }
        //draw layer mask with arrow
        UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, kMoreMenuDefaultArrowHeight, self.calculatedWidth, height-kMoreMenuDefaultArrowHeight) cornerRadius:5.0];
        CGFloat arrowMinX = 0;
        if (self.position == GVSMoreMenuViewPositionLeft) {
            arrowMinX = kMoreMenuDefaultArrowOffset;
        } else if (self.position == GVSMoreMenuViewPositionMiddle) {
            arrowMinX = self.calculatedWidth/2.0 - kMoreMenuDefaultArrowWidth/2.0;
        } else {
            arrowMinX = self.calculatedWidth - kMoreMenuDefaultArrowOffset - kMoreMenuDefaultArrowWidth;
        }
        [path moveToPoint:CGPointMake(arrowMinX, kMoreMenuDefaultArrowHeight)];
        [path addLineToPoint:CGPointMake(arrowMinX+kMoreMenuDefaultArrowWidth/2.0, 0)];
        [path addLineToPoint:CGPointMake(arrowMinX+kMoreMenuDefaultArrowWidth, kMoreMenuDefaultArrowHeight)];
        [path closePath];
        CAShapeLayer *maskLayer = [CAShapeLayer layer];
        maskLayer.path = path.CGPath;
        self.layer.mask = maskLayer;
        self.backgroundColor = [UIColor whiteColor];
    } else {
        self.frame = CGRectMake(0, 0, self.calculatedWidth, height);
    }
}

////点击检测
//-(BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
//{
//    if (CGRectContainsPoint(self.bounds, point)) {
//        return YES;
//    }
//    [self hideMenu];
//    return NO;
//}

-(void)maskViewTapGesture:(UITapGestureRecognizer *)gesture
{
    [self hideMenu];
}

#pragma mark - TableView Datasource & Delegate
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataList.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kMoreMenuDefaultLineHeight;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"MoreMenuTableViewCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    cell.textLabel.text = [self.dataList objectAtIndex:indexPath.row];
    cell.textLabel.textColor = [UIColor colorWithHex:Menu_Item_Text_Color];
    cell.textLabel.font = [UIFont systemFontOfSize:Menu_Item_Font];
    cell.textLabel.textAlignment = NSTextAlignmentCenter;
    if (runTimeOSVersion >= 8.0) {
        cell.layoutMargins = UIEdgeInsetsZero;
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (self.clickBlock) {
        self.clickBlock(indexPath.row);
    }
}
@end
