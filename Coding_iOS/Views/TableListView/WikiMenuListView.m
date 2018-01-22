//
//  WikiMenuListView.m
//  Coding_Enterprise_iOS
//
//  Created by Ease on 2017/4/5.
//  Copyright © 2017年 Coding. All rights reserved.
//
#define kWikiMenuListView_LeftPadding 30

#import "WikiMenuListView.h"
#import "WikiMenuListCell.h"

@interface WikiMenuListView ()<UITableViewDataSource, UITableViewDelegate>
@property (strong, nonatomic) NSArray<EAWiki *> *wikiList;
@property (strong, nonatomic) EAWiki *selectedWiki;

@property (strong, nonatomic) UIView *contentView;
@property (strong, nonatomic) UITableView *myTableView;
@end

@implementation WikiMenuListView

- (instancetype)init{
    self = [super init];
    if (self) {
        self.frame = kScreen_Bounds;
        _contentView = [[UIView alloc] initWithFrame:CGRectMake(-(self.width - kWikiMenuListView_LeftPadding), 0, self.width - kWikiMenuListView_LeftPadding, self.height)];
        _contentView.backgroundColor = [UIColor whiteColor];
        [self addSubview:_contentView];
        //Nav
        CGFloat navHeight = 64.0;
        UIView *navV = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _contentView.width, navHeight)];
        [navV addLineUp:NO andDown:YES];
        navV.clipsToBounds = YES;
        UILabel *navL = [UILabel labelWithFont:[UIFont systemFontOfSize:kNavTitleFontSize] textColor:kColorNavTitle];
        navL.text = @"目录";
        [navV addSubview:navL];
        [navL mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(navV);
            make.bottom.equalTo(navV).offset(-10);
        }];
        [_contentView addSubview:navV];
        [navV mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.left.right.equalTo(_contentView);
            make.height.mas_equalTo(navHeight);
        }];
        //TableView
        _myTableView = ({
            UITableView *tableView = [[UITableView alloc] init];
            tableView.backgroundColor = [UIColor clearColor];
            tableView.delegate = self;
            tableView.dataSource = self;
            [tableView registerClass:[WikiMenuListCell class] forCellReuseIdentifier:kCellIdentifier_WikiMenuListCellLavel(0)];
            tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
            [_contentView addSubview:tableView];
            [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.edges.equalTo(_contentView).insets(UIEdgeInsetsMake(navHeight, 0, 0, 0));
            }];
            tableView;
        });
        //PanGesture
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
        [_contentView addGestureRecognizer:pan];
        //RACObserve
        __weak typeof(self) weakSelf = self;
        [RACObserve(self.contentView, frame) subscribeNext:^(NSValue *frameV) {
            CGFloat alpha = 0.3;
            alpha *= fabs(CGRectGetMinX(frameV.CGRectValue) + _contentView.width)/_contentView.width;
            weakSelf.backgroundColor = [UIColor colorWithWhite:0 alpha:alpha];
        }];
        //Tap
        UIView *tapV = [UIView new];
        [self addSubview:tapV];
        [tapV mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.right.bottom.equalTo(self);
            make.width.mas_equalTo(kWikiMenuListView_LeftPadding);
        }];
        [tapV bk_whenTapped:^{
            [weakSelf dismiss];
        }];

    }
    return self;
}

- (void)setWikiList:(NSArray<EAWiki *> *)wikiList selectedWiki:(EAWiki *)selectedWiki{
    _wikiList = wikiList;
    _selectedWiki = selectedWiki;
    
    [_myTableView reloadData];
}

- (void)handlePanGesture:(UIPanGestureRecognizer*)pan{
    if (pan.state == UIGestureRecognizerStateChanged) {
        CGPoint diffP = [pan translationInView:_contentView];
        CGFloat contentX = MIN(diffP.x, 0);
        _contentView.x = contentX;
    }else if (pan.state == UIGestureRecognizerStateEnded) {
        CGPoint velocity = [pan velocityInView:_contentView];
        if (velocity.x < 0) {
            [self dismiss];
        }else{
            [self show];
        }
    }
}

- (void)show{
    [kKeyWindow addSubview:self];
    NSTimeInterval duration = .3 * (fabs(_contentView.x)/_contentView.width);
    [UIView animateWithDuration:duration animations:^{
        _contentView.x = 0;
    }];
}

- (void)dismiss{
    NSTimeInterval duration = .3 * (fabs(_contentView.x + _contentView.width)/_contentView.width);
    [UIView animateWithDuration:duration animations:^{
        _contentView.x = -_contentView.width;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

#pragma mark Table
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _wikiList.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [WikiMenuListCell cellHeightWithObj:_wikiList[indexPath.row]];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    WikiMenuListCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_WikiMenuListCellLavel(0) forIndexPath:indexPath];
    [cell setCurWiki:_wikiList[indexPath.row] selectedWiki:_selectedWiki];
    __weak typeof(self) weakSelf = self;
    cell.expandBlock = ^(EAWiki *wiki){
        wiki.isExpanded = !wiki.isExpanded;
        [weakSelf.myTableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    };
    cell.selectedWikiBlock = ^(EAWiki *wiki){
        [weakSelf handleSelectedWiki:wiki];
    };
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self handleSelectedWiki:_wikiList[indexPath.row]];
}

- (void)handleSelectedWiki:(EAWiki *)wiki{
    _selectedWiki = wiki;
    if (_selectedWikiBlock) {
        _selectedWikiBlock(wiki);
    }
    [self dismiss];
}


@end
