//
//  WikiMenuListCell.m
//  Coding_Enterprise_iOS
//
//  Created by Ease on 2017/4/5.
//  Copyright © 2017年 Coding. All rights reserved.
//
#define kWikiMenuListCell_Padding 20.0
#define kWikiMenuListCell_PerWikiTab 30.0
#define kWikiMenuListCell_PerWikiHeight 50.0

#import "WikiMenuListCell.h"

@interface WikiMenuListCell ()<UITableViewDataSource, UITableViewDelegate>
@property (strong, nonatomic) EAWiki *curWiki;
@property (strong, nonatomic) EAWiki *selectedWiki;
@property (assign, nonatomic) NSInteger lavel;

@property (strong, nonatomic) UIButton *expandBtn;
@property (strong, nonatomic) UILabel *titleL;
@property (strong, nonatomic) UIView *lineV;
@property (strong, nonatomic) UITableView *myTableView;
@end

@implementation WikiMenuListCell

- (void)setupLineV{
    if (!_lineV) {
        _lineV = [UIView new];
        _lineV.backgroundColor = kColorDDD;
        [self.contentView addSubview:_lineV];
        CGFloat left = kWikiMenuListCell_Padding + (_lavel * kWikiMenuListCell_PerWikiTab);
        [_lineV mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView).offset(left);
            make.right.equalTo(self.contentView);
            make.top.mas_equalTo(kWikiMenuListCell_PerWikiHeight - 1);
            make.height.mas_equalTo(1.0/[UIScreen mainScreen].scale);
        }];
    }
}

- (void)setupTitleL{
    if (!_titleL) {
        _titleL = [UILabel labelWithFont:_lavel == 0? [UIFont systemFontOfSize:17 weight:UIFontWeightMedium]: [UIFont systemFontOfSize:15] textColor:kColorDark3];
        [self.contentView addSubview:_titleL];
        [_titleL mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.contentView).offset((kWikiMenuListCell_PerWikiHeight - 20)/ 2);
            make.height.mas_equalTo(20);
            make.right.equalTo(self.contentView).offset(-kWikiMenuListCell_Padding);
            make.left.equalTo(self.contentView).offset(kWikiMenuListCell_Padding);
        }];
    }
    [_titleL mas_updateConstraints:^(MASConstraintMaker *make) {
        CGFloat left = kWikiMenuListCell_Padding + (_lavel * kWikiMenuListCell_PerWikiTab) + (_curWiki.hasChildren? 20: 0);
        make.left.equalTo(self.contentView).offset(left);
    }];
    _titleL.text = _curWiki.title;
    _titleL.textColor = (_selectedWiki.iid && [_curWiki.iid isEqualToNumber:_selectedWiki.iid])? kColorBrandGreen: kColorDark3;
}

- (void)setupExpandBtn{
    _expandBtn.hidden = !_curWiki.hasChildren;
    if (_curWiki.hasChildren) {
        if (!_expandBtn) {
            _expandBtn = [UIButton new];
            [_expandBtn setImage:[UIImage imageNamed:@"btn_fliter_down"] forState:UIControlStateNormal];
            _expandBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
            _expandBtn.imageEdgeInsets = UIEdgeInsetsMake(0, -15, 0, 15);
            [self.contentView addSubview:_expandBtn];
            CGFloat width = kWikiMenuListCell_Padding + (_lavel * kWikiMenuListCell_PerWikiTab) + 5 + 15;
            [_expandBtn mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.left.equalTo(self.contentView);
                make.height.mas_equalTo(kWikiMenuListCell_PerWikiHeight);
                make.width.mas_equalTo(width);
            }];
            
            __weak typeof(self) weakSelf = self;
            [_expandBtn bk_addEventHandler:^(id sender) {
                if (weakSelf.expandBlock) {
                    weakSelf.expandBlock(weakSelf.curWiki);
                }
            } forControlEvents:UIControlEventTouchUpInside];
        }
        _expandBtn.imageView.transform = CGAffineTransformMakeRotation(_curWiki.isExpanded? 0: -M_PI_2);
    }
}

- (void)setupTableView{
    _myTableView.hidden = !_curWiki.isExpanded;
    if (_curWiki.isExpanded) {
        if (!_myTableView) {
            _myTableView = ({
                UITableView *tableView = [[UITableView alloc] init];
                tableView.scrollEnabled = NO;
                tableView.delegate = self;
                tableView.dataSource = self;
                [tableView registerClass:[WikiMenuListCell class] forCellReuseIdentifier:kCellIdentifier_WikiMenuListCellLavel((int)(_curWiki.lavel + 1))];
                tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
                [self.contentView addSubview:tableView];
                [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.edges.equalTo(self.contentView).insets(UIEdgeInsetsMake(kWikiMenuListCell_PerWikiHeight, 0, 0, 0));
                }];
                tableView;
            });
        }
        [_myTableView reloadData];
    }
}

- (void)setCurWiki:(EAWiki *)curWiki selectedWiki:(EAWiki *)selectedWiki{
    _curWiki = curWiki;
    _selectedWiki = selectedWiki;
    _lavel = _curWiki.lavel;
    
    [self setupLineV];
    [self setupTitleL];
    [self setupExpandBtn];
    [self setupTableView];
}

+ (CGFloat)cellHeightWithObj:(EAWiki *)obj{
    CGFloat cellHeight = 0;
    cellHeight += kWikiMenuListCell_PerWikiHeight;
    if (obj.isExpanded) {
        for (EAWiki *wiki in obj.childrenDisplayList) {
            cellHeight += [self cellHeightWithObj:wiki];
        }
    }
    return cellHeight;
}

#pragma mark Table
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _curWiki.childrenDisplayList.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [WikiMenuListCell cellHeightWithObj:_curWiki.childrenDisplayList[indexPath.row]];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    WikiMenuListCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_WikiMenuListCellLavel((int)(_curWiki.lavel + 1)) forIndexPath:indexPath];
    [cell setCurWiki:_curWiki.childrenDisplayList[indexPath.row] selectedWiki:_selectedWiki];
    __weak typeof(self) weakSelf = self;
    cell.expandBlock = ^(EAWiki *wiki){
        if (weakSelf.expandBlock) {
            weakSelf.expandBlock(wiki);
        }
    };
    cell.selectedWikiBlock = ^(EAWiki *wiki){
        [weakSelf handleSelectedWiki:wiki];
    };
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self handleSelectedWiki:_curWiki.childrenDisplayList[indexPath.row]];
}

- (void)handleSelectedWiki:(EAWiki *)wiki{
    _selectedWiki = wiki;
    if (_selectedWikiBlock) {
        _selectedWikiBlock(wiki);
    }
}

@end
