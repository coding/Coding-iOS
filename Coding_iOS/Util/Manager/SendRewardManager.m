//
//  SendRewardManager.m
//  Coding_iOS
//
//  Created by Ease on 15/12/2.
//  Copyright © 2015年 Coding. All rights reserved.
//

#import "SendRewardManager.h"
#import "Coding_NetAPIManager.h"
#import "Login.h"

@interface SendRewardManager ()
@property (strong, nonatomic) Tweet *curTweet;
@property (copy, nonatomic) void(^completion)(Tweet *curTweet, BOOL sendSucess);
@property (strong, nonatomic) NSArray *tipStrList;


@property (strong, nonatomic) UIView *bgView, *contentView, *tipBgView;
@property (strong, nonatomic) UIButton *closeBtn, *submitBtn;
@property (strong, nonatomic) UILabel *titleL, *tipL, *bottomL;
@property (strong, nonatomic) UITextField *passwordF;
@end

@implementation SendRewardManager
+ (instancetype)shareManager{
    static SendRewardManager *shared_manager = nil;
    static dispatch_once_t pred;
    dispatch_once(&pred, ^{
        shared_manager = [[self alloc] init];
    });
    return shared_manager;
}

+ (instancetype)handleTweet:(Tweet *)curTweet completion:(void(^)(Tweet *curTweet, BOOL sendSucess))block{
    SendRewardManager *manager = [self shareManager];
    if (manager.curTweet) {//有正在处理的冒泡，此次调用无效
        return nil;
    }
    manager.curTweet = curTweet;
    manager.completion = block;
    [[Coding_NetAPIManager sharedManager] request_Preparereward:curTweet.id.stringValue andBlock:^(id data, NSError *error) {
        manager.tipStrList = data;
        [manager p_show];
    }];
    return manager;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        CGFloat buttonHeight = 44;
        
        //层级关系
        _bgView = [UIView new];
        _contentView = [UIView new];
        _closeBtn = [UIButton new];
        _titleL = [UILabel new];
        _passwordF = [UITextField new];
        _submitBtn = [UIButton buttonWithStyle:StrapSuccessStyle andTitle:@"确认打赏" andFrame:CGRectMake(0, 0, buttonHeight, buttonHeight) target:self action:@selector(submitBtnClicked)];
        _bottomL = [UILabel new];
        _tipBgView = [UIView new];
        _tipL = [UILabel new];
        [_contentView addSubview:_closeBtn];
        [_contentView addSubview:_titleL];
        [_contentView addSubview:_passwordF];
        [_contentView addSubview:_submitBtn];
        [_contentView addSubview:_bottomL];
        [_contentView addSubview:_tipBgView];
        [_contentView addSubview:_tipL];

        [_bgView addSubview:_contentView];
        
        //属性设置
        _contentView.backgroundColor = [UIColor colorWithHexString:@"0xF8F8F8"];
        _contentView.layer.masksToBounds = YES;
        _contentView.layer.cornerRadius = 6;
        [_closeBtn setImage:[UIImage imageNamed:@"button_close"] forState:UIControlStateNormal];
        [_closeBtn addTarget:self action:@selector(p_dismiss) forControlEvents:UIControlEventTouchUpInside];
        _titleL.font = [UIFont systemFontOfSize:18];
        _titleL.textColor = [UIColor colorWithHexString:@"0x222222"];
        _titleL.textAlignment = NSTextAlignmentCenter;
        _titleL.attributedText = [self p_titleStr];
        _passwordF.font = [UIFont systemFontOfSize:15];
        _passwordF.textColor = [UIColor colorWithHexString:@"0x222222"];
        _passwordF.secureTextEntry = YES;
        _passwordF.textAlignment = NSTextAlignmentCenter;
        [_passwordF doBorderWidth:1.0 color:[UIColor colorWithHexString:@"0xCCCCCC"] cornerRadius:2.0];
        _passwordF.placeholder = @" 请输入密码";
        _bottomL.font = [UIFont systemFontOfSize:12];
        _bottomL.textColor = [UIColor colorWithHexString:@"0x999999"];
        _bottomL.textAlignment = NSTextAlignmentCenter;
        _bottomL.attributedText = [self p_bottomStr];
        _tipBgView.backgroundColor = [UIColor colorWithHexString:@"0xF2DEDE"];
        _tipBgView.layer.masksToBounds = YES;
        _tipBgView.layer.cornerRadius = 3;
        _tipL.font = [UIFont systemFontOfSize:15];
        _tipL.textColor = [UIColor colorWithHexString:@"0xC55351"];
        _tipL.textAlignment = NSTextAlignmentCenter;
        _tipL.numberOfLines = 0;
        
        //位置大小
        [_closeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.top.equalTo(_contentView);
            make.width.height.mas_equalTo(buttonHeight);
        }];
        [_titleL mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(_contentView);
            make.top.equalTo(_contentView).offset(35);
        }];
        [_passwordF mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_titleL.mas_bottom).offset(20);
            make.left.equalTo(_contentView).offset(25);
            make.right.equalTo(_contentView).offset(-25);
            make.height.mas_equalTo(35);
        }];
        [_submitBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_passwordF.mas_bottom).offset(25);
            make.left.equalTo(_contentView).offset(50);
            make.right.equalTo(_contentView).offset(-50);
            make.height.mas_equalTo(buttonHeight);
        }];
        [_tipBgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_titleL.mas_bottom).offset(20);
            make.left.equalTo(_contentView).offset(25);
            make.right.equalTo(_contentView).offset(-25);
            make.height.mas_equalTo(60);
        }];
        [_tipL mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(_tipBgView).insets(UIEdgeInsetsMake(10, 15, 10, 15));
        }];
//        [_bgView bk_whenTapped:^{
//            [self p_dismiss];
//        }];
        
        
        [_bottomL mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(_contentView);
            make.bottom.equalTo(_contentView).offset(-15);
            make.height.mas_equalTo(15);
        }];
        
        
        //初始状态
        _bgView.backgroundColor = [UIColor clearColor];
        _contentView.alpha = 0;
    }
    return self;
}

- (NSAttributedString *)p_titleStr{
    NSString *tempStr = @"打赏给该用户 0.01 码币";
    NSMutableAttributedString *titleStr = [[NSMutableAttributedString alloc] initWithString:tempStr];
    [titleStr addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithHexString:@"0xF5A623"] range:[tempStr rangeOfString:@"0.01"]];
    return titleStr;
}


- (NSAttributedString *)p_bottomStr{
    NSString *tempStr = [NSString stringWithFormat:@"我的码币余额：%@ ", [Login curLoginUser].points_left.stringValue];
    NSMutableAttributedString *bottomStr = [[NSMutableAttributedString alloc] initWithString:tempStr];
    [bottomStr addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithHexString:@"0xF5A623"] range:[tempStr rangeOfString:[Login curLoginUser].points_left.stringValue]];
    return bottomStr;
}

- (void)setTipStrList:(NSArray *)tipStrList{
    _tipStrList = tipStrList;
    _tipL.text = tipStrList.firstObject;

    BOOL hasTip = _tipStrList.count > 0;
    CGFloat contentHeight = hasTip? 185: 229;
    CGFloat centerYOffset = hasTip? 0: -60;
    _passwordF.hidden = hasTip;
    _submitBtn.hidden = hasTip;
    _tipBgView.hidden = !hasTip;
    _tipL.hidden = !hasTip;
    
    [_contentView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_bgView).offset(kPaddingLeftWidth);
        make.height.mas_equalTo(contentHeight);
        make.centerX.equalTo(_bgView);
        make.centerY.equalTo(_bgView).offset(centerYOffset);
    }];
}

- (void)submitBtnClicked{
#warning submitBtnClicked reward
    [NSObject showHudTipStr:@"稍等~"];
}

- (void)p_show{
    _bgView.frame = kScreen_Bounds;
    [kKeyWindow addSubview:_bgView];
    [UIView animateWithDuration:0.3 animations:^{
        _bgView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.6];
        _contentView.alpha = 1;
    } completion:^(BOOL finished) {
        if (!_passwordF.hidden) {
            [_passwordF becomeFirstResponder];
        }
    }];
}

- (void)p_dismiss{
    _curTweet = nil;
    _completion = nil;
    
    [UIView animateWithDuration:0.3 animations:^{
        _bgView.backgroundColor = [UIColor clearColor];
        _contentView.alpha = 0;
    } completion:^(BOOL finished) {
        [_bgView removeFromSuperview];
    }];
}

@end
