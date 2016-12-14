//
//  RewardTipManager.m
//  Coding_iOS
//
//  Created by Ease on 2016/12/14.
//  Copyright © 2016年 Coding. All rights reserved.
//

#import "RewardTipManager.h"
#import "PointRecordsViewController.h"
#import "Login.h"

@interface RewardTipManager ()
@property (strong, nonatomic) NSString *title, *rewardPoint;

@property (strong, nonatomic) UIView *bgView, *contentView;
@property (strong, nonatomic) UIImageView *logoImgV;
@property (strong, nonatomic) UILabel *titleL, *rewardPointL;
@property (strong, nonatomic) UIButton *closeBtn, *knowMoreBtn;
@end

@implementation RewardTipManager
+ (instancetype)shareManager{
    static RewardTipManager *shared_manager = nil;
    static dispatch_once_t pred;
    dispatch_once(&pred, ^{
        shared_manager = [[self alloc] init];
    });
    return shared_manager;
}

+ (void)showTipWithTitle:(NSString *)title rewardPoint:(NSString *)rewardPoint{
    if (![Login isLogin]) {
        return;
    }
    RewardTipManager *manager = [self shareManager];
    manager.title = title;
    manager.rewardPoint = rewardPoint;
    [manager p_show];
}

- (instancetype)init{
    self = [super init];
    if (self) {
        //层级关系
        _bgView = [UIView new];
        _contentView = [UIView new];
        
        _logoImgV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"reward_tip_logo"]];
        _titleL = [UILabel labelWithFont:[UIFont boldSystemFontOfSize:18] textColor:[UIColor colorWithHexString:@"0x222222"]];
        _rewardPointL = [UILabel labelWithSystemFontSize:15 textColorHexString:@"0x222222"];
        _knowMoreBtn = ({
            UIButton *button = [UIButton new];
            button.backgroundColor = kColorTableSectionBg;
            button.titleLabel.font = [UIFont systemFontOfSize:17];
            [button setTitleColor:kColorNavTitle forState:UIControlStateNormal];
            [button setTitle:@"了解码币" forState:UIControlStateNormal];
            [button addTarget:self action:@selector(knowMoreBtnClicked) forControlEvents:UIControlEventTouchUpInside];
            button;
        });
        _closeBtn = ({
            UIButton *button = [UIButton new];
            button.backgroundColor = kColorTableSectionBg;
            button.titleLabel.font = [UIFont systemFontOfSize:17];
            [button setTitleColor:kColorNavTitle forState:UIControlStateNormal];
            [button setTitle:@"知道了" forState:UIControlStateNormal];
            [button addTarget:self action:@selector(p_dismiss) forControlEvents:UIControlEventTouchUpInside];
            button;
        });
        [_contentView addSubview:_logoImgV];
        [_contentView addSubview:_titleL];
        [_contentView addSubview:_rewardPointL];
        [_contentView addSubview:_knowMoreBtn];
        [_contentView addSubview:_closeBtn];
        [_bgView addSubview:_contentView];
        //属性设置
        _contentView.backgroundColor = kColorTableSectionBg;
        _contentView.layer.masksToBounds = YES;
        _contentView.layer.cornerRadius = 6;
        _rewardPointL.textAlignment = _titleL.textAlignment = NSTextAlignmentCenter;
        _titleL.numberOfLines = 0;
        //位置大小
        [_contentView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(270);
            make.center.equalTo(_bgView);
        }];
        [_logoImgV mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(88, 67));
            make.centerX.equalTo(_contentView);
            make.top.equalTo(_contentView).mas_offset(30);
        }];
        [_titleL mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_logoImgV.mas_bottom).offset(30);
            make.left.equalTo(_contentView).offset(15);
            make.right.equalTo(_contentView).offset(-15);
        }];
        [_rewardPointL mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_titleL.mas_bottom).offset(10);
            make.left.right.equalTo(_titleL);
        }];
        [_knowMoreBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_rewardPointL.mas_bottom).offset(30);
            make.left.equalTo(_contentView).offset(0);
            make.bottom.equalTo(_contentView).offset(0);
            make.right.equalTo(_closeBtn.mas_left).offset(0);
            make.width.equalTo(_closeBtn);
            make.height.mas_equalTo(44);
        }];
        [_closeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(_contentView).offset(0);
            make.top.bottom.equalTo(_knowMoreBtn);
        }];
        //改 UI，加两条线
        UIView *hLineV = [UIView new];
        UIView *vLineV = [UIView new];
        hLineV.backgroundColor = vLineV.backgroundColor = kColorDDD;
        [_contentView addSubview:hLineV];
        [_contentView addSubview:vLineV];
        [hLineV mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(_closeBtn.mas_top);
            make.left.right.equalTo(_contentView);
            make.height.mas_equalTo(1.0/[UIScreen mainScreen].scale);
        }];
        [vLineV mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(_contentView);
            make.top.bottom.equalTo(_closeBtn);
            make.width.mas_equalTo(1.0/[UIScreen mainScreen].scale);
        }];
        //关联事件
        [_bgView bk_whenTapped:^{
            [self p_dismiss];
        }];
    }
    return self;
}

- (void)setTitle:(NSString *)title{
    _title = title;
    _titleL.text = _title;
}

- (void)setRewardPoint:(NSString *)rewardPoint{
    _rewardPoint = rewardPoint;
    [_rewardPointL setAttrStrWithStr:[NSString stringWithFormat:@"获得 %@ 的奖励", _rewardPoint] diffColorStr:_rewardPoint diffColor:[UIColor colorWithHexString:@"0xF5A623"]];
}

- (void)knowMoreBtnClicked{
    PointRecordsViewController *vc = [PointRecordsViewController new];
    [BaseViewController goToVC:vc];
    [self p_dismiss];
}

- (void)p_show{
    //初始状态
    _bgView.backgroundColor = [UIColor clearColor];
    _contentView.alpha = 0;
    _bgView.frame = kScreen_Bounds;

    [kKeyWindow addSubview:_bgView];
    [UIView animateWithDuration:0.3 animations:^{
        _bgView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
        _contentView.alpha = 1;
    } completion:nil];
}

- (void)p_dismiss{
    [UIView animateWithDuration:0.3 animations:^{
        _bgView.backgroundColor = [UIColor clearColor];
        _contentView.alpha = 0;
    } completion:^(BOOL finished) {
        [_bgView removeFromSuperview];
    }];
}

@end
