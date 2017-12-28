//
//  CodingVipTipManager.m
//  Coding_iOS
//
//  Created by Easeeeeeeeee on 2017/12/26.
//  Copyright © 2017年 Coding. All rights reserved.
//

#import "CodingVipTipManager.h"

@interface CodingVipTipManager ()
@property (strong, nonatomic) NSString *title, *imageName;

@property (strong, nonatomic) UIView *bgView, *contentView;
@property (strong, nonatomic) UIImageView *logoImgV;
@property (strong, nonatomic) UILabel *titleL;
@property (strong, nonatomic) UIButton *closeBtn;

@end

@implementation CodingVipTipManager
+ (instancetype)shareManager{
    static CodingVipTipManager *shared_manager = nil;
    static dispatch_once_t pred;
    dispatch_once(&pred, ^{
        shared_manager = [[self alloc] init];
    });
    return shared_manager;
}

+ (void)showTip{
    CodingVipTipManager *manager = [self shareManager];
    manager.title = @"恭喜你成为 Coding 银牌会员";
    manager.imageName = @"upgrade_success";
    [manager p_show];
}

- (instancetype)init{
    self = [super init];
    if (self) {
        //层级关系
        _bgView = [UIView new];
        _contentView = [UIView new];
        
        _logoImgV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:_imageName]];
        _titleL = [UILabel labelWithFont:[UIFont systemFontOfSize:17] textColor:[UIColor colorWithHexString:@"0x222222"]];
        _titleL.textAlignment = NSTextAlignmentCenter;
        _closeBtn = ({
            UIButton *button = [UIButton new];
            button.backgroundColor = kColorDark3;
            button.cornerRadius = 4;
            button.masksToBounds = YES;
            button.titleLabel.font = [UIFont systemFontOfSize:17];
            [button setTitleColor:kColorWhite forState:UIControlStateNormal];
            [button setTitle:@"我知道了" forState:UIControlStateNormal];
            [button addTarget:self action:@selector(p_dismiss) forControlEvents:UIControlEventTouchUpInside];
            button;
        });
        [_contentView addSubview:_logoImgV];
        [_contentView addSubview:_titleL];
        [_contentView addSubview:_closeBtn];
        [_bgView addSubview:_contentView];
        //属性设置
        _contentView.backgroundColor = kColorTableSectionBg;
        _contentView.layer.masksToBounds = YES;
        _contentView.layer.cornerRadius = 6;
        _titleL.numberOfLines = 0;
        //位置大小
        [_contentView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(300);
            make.centerX.equalTo(_bgView);
            make.centerY.equalTo(_bgView).offset(-20);
        }];
        [_logoImgV mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(132, 109));
            make.centerX.equalTo(_contentView);
            make.top.equalTo(_contentView).mas_offset(30);
        }];
        [_titleL mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_logoImgV.mas_bottom).offset(30);
            make.left.equalTo(_contentView).offset(15);
            make.right.equalTo(_contentView).offset(-15);
        }];
        [_closeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(_contentView);
            make.top.equalTo(_titleL.mas_bottom).offset(30);
            make.bottom.equalTo(_contentView).offset(-30);
            make.size.mas_equalTo(CGSizeMake(120, 44));
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

- (void)setImageName:(NSString *)imageName{
    _imageName = imageName;
    _logoImgV.image = [UIImage imageNamed:_imageName];
}

- (void)p_show{
    //初始状态
    _bgView.backgroundColor = [UIColor clearColor];
    _contentView.alpha = 0;
    UIView *spV = [BaseViewController presentingVC].navigationController.view;
    _bgView.frame = spV.bounds;
    [spV addSubview:_bgView];
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
