//
//  CodeBranchTagButton.m
//  Coding_iOS
//
//  Created by Ease on 15/1/29.
//  Copyright (c) 2015年 Coding. All rights reserved.
//

#define kCellIdentifier_BranchTag @"UITableViewCell"
#define kCodeBranchTagButton_NavHeight 44.0
#define kCodeBranchTagButton_ContentHeight (kScreen_Height/2)
#define DEGREES_TO_RADIANS(angle) ((angle)/180.0 *M_PI)



#import "CodeBranchTagButton.h"
#import "Coding_NetAPIManager.h"
#import "ODRefreshControl.h"


@interface CodeBranchTagButton ()<UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, assign) BOOL isShowing;
@property (nonatomic, assign) NSInteger segmentIndex;

@property (nonatomic, strong) UIView *myTapBackgroundView, *myContentView;
@property (nonatomic, strong) UITableView *myTableView;
@property (strong, nonatomic) UISegmentedControl *mySegmentedControl;
//@property (nonatomic, strong) ODRefreshControl *myRefreshControl;

@end


@implementation CodeBranchTagButton

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _isShowing = NO;
        [self addTarget:self action:@selector(changeShowing) forControlEvents:UIControlEventTouchUpInside];
        [self addLineUp:YES andDown:NO andColor:[UIColor lightGrayColor]];
    }
    return self;
}

+ (instancetype)buttonWithProject:(Project *)project andTitleStr:(NSString *)titleStr{
    CodeBranchTagButton *button = [[CodeBranchTagButton alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, 49)];
    button.titleStr = titleStr;
    button.curProject = project;
    return button;
}

- (UIView *)myTapBackgroundView{
    if (!_myTapBackgroundView) {
        _myTapBackgroundView = ({
            UIView *view = [[UIView alloc] initWithFrame:kScreen_Bounds];
            view.backgroundColor = [UIColor clearColor];
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(changeShowing)];
            [view addGestureRecognizer:tap];
            view;
        });
    }
    return _myTapBackgroundView;
}

- (UIView *)myContentView{
    if (!_myContentView) {
        _myContentView = ({
            UIView *view = [[UIView alloc] initWithFrame:CGRectZero];
            view.backgroundColor = [UIColor whiteColor];
            view;
        });
    }
    return _myContentView;
}

- (UITableView *)myTableView{
    if (!_myTableView) {
        _myTableView = ({
            UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
            [tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:kCellIdentifier_BranchTag];
            tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
            tableView.dataSource = self;
            tableView.delegate = self;
            tableView;
        });
    }
    return _myTableView;
}

- (UISegmentedControl *)mySegmentedControl{
    if (!_mySegmentedControl) {
        _mySegmentedControl = ({
            UISegmentedControl *segmentedControl = [[UISegmentedControl alloc] initWithItems:@[@"分支", @"标签"]];
            segmentedControl.tintColor = kColorBrandGreen;
            [segmentedControl setTitleTextAttributes:@{
                                                       NSFontAttributeName: [UIFont boldSystemFontOfSize:16],
                                                       NSForegroundColorAttributeName: [UIColor whiteColor]
                                                       }
                                            forState:UIControlStateSelected];
            [segmentedControl setTitleTextAttributes:@{
                                                       NSFontAttributeName: [UIFont boldSystemFontOfSize:16],
                                                       NSForegroundColorAttributeName: kColorBrandGreen
                                                       } forState:UIControlStateNormal];
            [segmentedControl addTarget:self action:@selector(segmentedControlSelected:) forControlEvents:UIControlEventValueChanged];
            segmentedControl;
        });
    }
    return _mySegmentedControl;
}

- (NSArray *)dataList{
    return _segmentIndex == 0? _branchList: _tagList;
}

#pragma mark UI

- (void)loadUIElement{
    self.myTapBackgroundView.backgroundColor = [UIColor colorWithWhite:0 alpha:0];
    
    [self.myContentView addSubview:self.myTableView];
    [self.myContentView addSubview:self.mySegmentedControl];
    
    self.mySegmentedControl.frame = CGRectMake(12, (kCodeBranchTagButton_NavHeight - 30)/2, kScreen_Width - 2*12, 30);
    self.myTableView.frame = CGRectMake(0, kCodeBranchTagButton_NavHeight, kScreen_Width, kCodeBranchTagButton_ContentHeight-kCodeBranchTagButton_NavHeight);
    
//    _myRefreshControl = [[ODRefreshControl alloc] initInScrollView:self.myTableView];
//    [_myRefreshControl addTarget:self action:@selector(queryToRefresh) forControlEvents:UIControlEventValueChanged];
    
    self.segmentIndex = 0;
}


- (void)changeShowing{
    [kKeyWindow endEditing:YES];
    if (!_myContentView) {//未载入过
        [self loadUIElement];
    }
    CGPoint origin = [self convertPoint:CGPointZero toView:kKeyWindow];
    CGFloat contentHeight = self.isShowing? 0: kCodeBranchTagButton_ContentHeight;
    if (self.isShowing) {//隐藏
        self.enabled = NO;
        [UIView animateWithDuration:0.3 animations:^{
            self.myTapBackgroundView.backgroundColor = [UIColor colorWithWhite:0 alpha:0];
            self.myContentView.alpha = 0;
            self.myContentView.frame = CGRectMake(0, origin.y-contentHeight, kScreen_Width, contentHeight);
            self.imageView.transform = CGAffineTransformRotate(self.imageView.transform, DEGREES_TO_RADIANS(180));
        } completion:^(BOOL finished) {
            [self.myTapBackgroundView removeFromSuperview];
            [self.myContentView removeFromSuperview];
            self.enabled = YES;
            self.isShowing = NO;
        }];
    }else{//显示
        self.myContentView.frame = CGRectMake(0, origin.y, kScreen_Width, 0);
        [kKeyWindow addSubview:self.myTapBackgroundView];
        [kKeyWindow addSubview:self.myContentView];
        self.enabled = NO;
        [UIView animateWithDuration:0.3 animations:^{
            self.myTapBackgroundView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.2];
            self.myContentView.alpha = 1.0;
            self.myContentView.frame = CGRectMake(0, origin.y-contentHeight, kScreen_Width, contentHeight);
            self.imageView.transform = CGAffineTransformRotate(self.imageView.transform, DEGREES_TO_RADIANS(180));
        } completion:^(BOOL finished) {
            self.enabled = YES;
            self.isShowing = YES;
        }];
    }
}

- (void)segmentedControlSelected:(id)sender{
    UISegmentedControl *segmentedControl = (UISegmentedControl *)sender;
    self.segmentIndex = segmentedControl.selectedSegmentIndex;
}
#pragma mark Set & Refresh

- (void)setTitleStr:(NSString *)titleStr{
    if (![_titleStr isEqualToString:titleStr]) {
        _titleStr = titleStr;
        [self refreshSelfUI];
    }
}

- (void)refreshSelfUI{
    self.backgroundColor = [UIColor colorWithHexString:@"0xf3f3f3"];
    self.titleLabel.font = [UIFont systemFontOfSize:15];
    [self setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self setTitleColor:[UIColor darkGrayColor] forState:UIControlStateHighlighted];
    
    [self setTitle:_titleStr forState:UIControlStateNormal];
    [self setImage:[UIImage imageNamed:@"icon_triangle"] forState:UIControlStateNormal];
    
    CGFloat titleWidth = [_titleStr getWidthWithFont:self.titleLabel.font constrainedToSize:CGSizeMake(kScreen_Width, 30)];
    self.titleEdgeInsets = UIEdgeInsetsMake(0, -20, 0, 20);
    self.imageEdgeInsets = UIEdgeInsetsMake(0, titleWidth, 0, -titleWidth);
}

- (void)setSegmentIndex:(NSInteger)segmentIndex{
    _segmentIndex = segmentIndex;
    if (self.mySegmentedControl.selectedSegmentIndex != _segmentIndex) {
        [self.mySegmentedControl setSelectedSegmentIndex:_segmentIndex];
    }
    [self.myTableView reloadData];
    if (!self.dataList) {
//        [self.myRefreshControl beginRefreshing];
        [self.myTableView setContentOffset:CGPointMake(0, -44)];
        [self queryToRefresh];
    }
}

- (void)queryToRefresh{
    if (!_curProject) {
        return;
    }
    __weak typeof(self) weakSelf = self;
    if (_segmentIndex == 0) {//branch
        [[Coding_NetAPIManager sharedManager] request_CodeBranchOrTagWithPath:@"list_branches" withPro:_curProject andBlock:^(id data, NSError *error) {
//            [weakSelf.myRefreshControl endRefreshing];
            if (data) {
                weakSelf.branchList = data;
                [weakSelf.myTableView reloadData];
            }
        }];
    }else{//tag
        [[Coding_NetAPIManager sharedManager] request_CodeBranchOrTagWithPath:@"list_tags" withPro:_curProject andBlock:^(id data, NSError *error) {
//            [weakSelf.myRefreshControl endRefreshing];
            if (data) {
                weakSelf.tagList = data;
                [weakSelf.myTableView reloadData];
            }
        }];
    }
}

#pragma mark Table M
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.dataList count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0.5;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.5;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_BranchTag forIndexPath:indexPath];
    cell.textLabel.textColor = [UIColor blackColor];
    cell.textLabel.font = [UIFont systemFontOfSize:15];
    
    CodeBranchOrTag *curBranchOrTag = [self.dataList objectAtIndex:indexPath.row];
    cell.textLabel.text = curBranchOrTag.name;
    
    if ([curBranchOrTag.name isEqualToString:self.titleStr]) {
        cell.backgroundColor = [UIColor colorWithHexString:@"0xf3f3f3"];
    }else{
        cell.backgroundColor = [UIColor whiteColor];
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 44;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    CodeBranchOrTag *curBranchOrTag = [self.dataList objectAtIndex:indexPath.row];
    self.titleStr = curBranchOrTag.name;
    [self.myTableView reloadData];
    if (_selectedBranchTagBlock) {
        _selectedBranchTagBlock(curBranchOrTag.name);
    }
    [self changeShowing];
}


@end
