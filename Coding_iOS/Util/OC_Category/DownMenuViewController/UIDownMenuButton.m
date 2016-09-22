//
//  UIDownMenuButton.m
//  Coding_iOS
//
//  Created by 王 原闯 on 14-8-5.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#define kNavImageWidth (7.0+5.0)
#define kDownMenu_ContentLeftPading 27.0
#define kDownMenuCellHeight 50.0

#define DEGREES_TO_RADIANS(angle) ((angle)/180.0 *M_PI)
#define RADIANS_TO_DEGREES(radians) ((radians)*(180.0/M_PI))

#import "UIDownMenuButton.h"
#import "DownMenuCell.h"

@interface UIDownMenuButton()

@property (nonatomic, strong) NSArray *titleList;
@property (nonatomic, assign) BOOL isShowing;
@property (nonatomic, strong) UIView *mySuperView, *myTapBackgroundView;
@property (nonatomic, strong) UITableView *myTableView;

@end


@implementation UIDownMenuButton

- (UIDownMenuButton *)initWithTitles:(NSArray *)titleList andDefaultIndex:(NSInteger)index andVC:(UIViewController *)viewcontroller{
    self = [super init];
    if (self) {
        _titleList = titleList;
        _curIndex = index;
        _isShowing = NO;
        _mySuperView = viewcontroller.view;
        
        self.backgroundColor = [UIColor clearColor];
        [self setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
        [self.titleLabel setFont:[UIFont systemFontOfSize:kNavTitleFontSize]];
        [self.titleLabel setMinimumScaleFactor:0.5];
        [self addTarget:self action:@selector(changeShowing) forControlEvents:UIControlEventTouchUpInside];
        [self refreshSelfUI];
    }
    return self;
}

- (void)refreshSelfUI{
    NSString *titleStr = @"";
    DownMenuTitle *menuObj = [self.titleList objectAtIndex:self.curIndex];
    titleStr = menuObj.titleValue;
    CGFloat titleWidth = [titleStr getWidthWithFont:self.titleLabel.font constrainedToSize:CGSizeMake(kScreen_Width, 30)];
    CGFloat btnWidth = titleWidth +kNavImageWidth;
    self.frame = CGRectMake((kScreen_Width-btnWidth)/2, (44-30)/2, btnWidth, 30);

    self.titleEdgeInsets = UIEdgeInsetsMake(0, -kNavImageWidth, 0, kNavImageWidth);
    self.imageEdgeInsets = UIEdgeInsetsMake(0, titleWidth, 0, -titleWidth);
    [self setTitle:titleStr forState:UIControlStateNormal];
    [self setImage:[UIImage imageNamed:@"btn_fliter_down"] forState:UIControlStateNormal];
}

- (void)changeShowing{
    [kKeyWindow endEditing:YES];
    
    if (!self.myTableView) {
        CGPoint origin = [self.mySuperView convertPoint:CGPointZero toView:[UIApplication sharedApplication].keyWindow];
        self.myTableView = [[UITableView alloc] initWithFrame:CGRectMake(origin.x, origin.y, kScreen_Width, 0) style:UITableViewStylePlain];
        [self.myTableView registerClass:[DownMenuCell class] forCellReuseIdentifier:kCellIdentifier_DownMenu];
        self.myTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        self.myTableView.dataSource = self;
        self.myTableView.delegate = self;
        self.myTableView.alpha = 0;
        self.myTableView.scrollEnabled = NO;
    }
    if (!self.myTapBackgroundView) {
        self.myTapBackgroundView = [[UIView alloc] initWithFrame:kScreen_Bounds];
        self.myTapBackgroundView.backgroundColor = [UIColor clearColor];
        UITapGestureRecognizer *bgTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(changeShowing)];
        [self.myTapBackgroundView addGestureRecognizer:bgTap];
    }
    
    if (self.isShowing) {//隐藏
        CGRect frame = self.myTableView.frame;
        frame.size.height = 0;
        self.enabled = NO;
        [UIView animateWithDuration:0.3 animations:^{
            [self refreshSelfUI];
            self.myTapBackgroundView.backgroundColor = [UIColor colorWithWhite:0 alpha:0];
            self.myTableView.alpha = 0;
            self.myTableView.frame = frame;
            self.imageView.transform = CGAffineTransformRotate(self.imageView.transform, DEGREES_TO_RADIANS(180));
        } completion:^(BOOL finished) {
            [self.myTableView removeFromSuperview];
            [self.myTapBackgroundView removeFromSuperview];
            self.enabled = YES;
            self.isShowing = !self.isShowing;
        }];
    }else{//显示
        [[UIApplication sharedApplication].keyWindow addSubview:self.myTapBackgroundView];
        [[UIApplication sharedApplication].keyWindow addSubview:self.myTableView];
        [self.myTableView reloadData];
        CGRect frame = self.myTableView.frame;
        frame.size.height = kDownMenuCellHeight *[self.titleList count];
        self.enabled = NO;
        [UIView animateWithDuration:0.3 animations:^{
            self.myTapBackgroundView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.2];
            self.myTableView.alpha = 1.0;
            self.myTableView.frame = frame;
            self.imageView.transform = CGAffineTransformRotate(self.imageView.transform, DEGREES_TO_RADIANS(180));
        } completion:^(BOOL finished) {
            self.enabled = YES;
            self.isShowing = YES;
        }];
    }
}

#pragma mark Table M
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.titleList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    DownMenuCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_DownMenu forIndexPath:indexPath];
    DownMenuTitle *curItem =[self.titleList objectAtIndex:indexPath.row];
    cell.curItem = curItem;
    cell.backgroundColor = (indexPath.row == self.curIndex)? [UIColor colorWithHexString:@"0xf3f3f3"] : [UIColor whiteColor];
    [self.myTableView addLineforPlainCell:cell forRowAtIndexPath:indexPath withLeftSpace:kDownMenu_ContentLeftPading];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return kDownMenuCellHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    self.curIndex = indexPath.row;
    [self changeShowing];
    if (self.menuIndexChanged) {
        self.menuIndexChanged([self.titleList objectAtIndex:_curIndex], _curIndex);
    }
}

- (void)setCurIndex:(NSInteger)curIndex{
    _curIndex = curIndex;
    [UIView animateWithDuration:0.3 animations:^{
        [self refreshSelfUI];
//        [self.myTableView reloadData];
//        [self.myTableView performSelector:@selector(reloadData) withObject:nil afterDelay:0.3];
    }];
}

- (void)dealloc
{
    self.myTableView.delegate = nil;
}

@end


@implementation DownMenuTitle
+ (DownMenuTitle *)title:(NSString *)title image:(NSString *)image badge:(NSString *)badge{
    DownMenuTitle *menuObj = [[DownMenuTitle alloc] init];
    menuObj.titleValue = title;
    menuObj.badgeValue = badge;
    menuObj.imageName = image;
    return menuObj;
}
@end
