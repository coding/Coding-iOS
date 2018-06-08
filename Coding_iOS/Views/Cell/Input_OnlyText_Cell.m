//
//  Input_OnlyText_Cell.m
//  Coding_iOS
//
//  Created by 王 原闯 on 14-8-4.
//  Copyright (c) 2014年 Coding. All rights reserved.
//
#define kCellIdentifier_Input_OnlyText_Cell_PhoneCode_Prefix @"Input_OnlyText_Cell_PhoneCode"

#import "Input_OnlyText_Cell.h"
#import "Coding_NetAPIManager.h"


@interface Input_OnlyText_Cell ()

@property (strong, nonatomic) UIView *lineView;
@property (strong, nonatomic) UIButton *clearBtn, *passwordBtn;

@property (strong, nonatomic) UITapImageView *captchaView;
@property (strong, nonatomic) UIActivityIndicatorView *activityIndicator;

@end

@implementation Input_OnlyText_Cell
+ (NSString *)randomCellIdentifierOfPhoneCodeType{
    return [NSString stringWithFormat:@"%@_%ld", kCellIdentifier_Input_OnlyText_Cell_PhoneCode_Prefix, random()];
}

- (void)setIsBottomLineShow:(BOOL)isBottomLineShow{
    _isBottomLineShow = isBottomLineShow;
    _lineView.hidden = !_isBottomLineShow;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.clipsToBounds = YES;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        if (!_textField) {
            _textField = [UITextField new];
            [_textField setFont:[UIFont systemFontOfSize:15]];
            [_textField addTarget:self action:@selector(editDidBegin:) forControlEvents:UIControlEventEditingDidBegin];
            [_textField addTarget:self action:@selector(textValueChanged:) forControlEvents:UIControlEventEditingChanged];
            [_textField addTarget:self action:@selector(editDidEnd:) forControlEvents:UIControlEventEditingDidEnd];
            [self.contentView addSubview:_textField];
            [_textField mas_makeConstraints:^(MASConstraintMaker *make) {
                make.height.mas_equalTo(20);
                make.left.equalTo(self.contentView).offset(kLoginPaddingLeftWidth);
                make.right.equalTo(self.contentView).offset(-kLoginPaddingLeftWidth);
                
                make.bottom.mas_greaterThanOrEqualTo(self.contentView).offset(-15).priority(MASLayoutPriorityRequired);
                make.centerY.equalTo(self.contentView).priority(MASLayoutPriorityDefaultLow);
            }];
        }
        
        if ([reuseIdentifier isEqualToString:kCellIdentifier_Input_OnlyText_Cell_Text]) {
            
        }else if ([reuseIdentifier isEqualToString:kCellIdentifier_Input_OnlyText_Cell_Captcha]){
            __weak typeof(self) weakSelf = self;
            if (!_captchaView) {
                _captchaView = [[UITapImageView alloc] initWithFrame:CGRectMake(kScreen_Width - 60 - kLoginPaddingLeftWidth, (44-25)/2, 60, 25)];
                _captchaView.layer.masksToBounds = YES;
                _captchaView.layer.cornerRadius = 5;
                [_captchaView addTapBlock:^(id obj) {
                    [weakSelf refreshCaptchaImage];
                }];
                [self.contentView addSubview:_captchaView];
                [_captchaView mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.size.mas_equalTo(CGSizeMake(60, 25));
                    make.centerY.equalTo(self.textField);
                    make.right.equalTo(self.contentView).offset(-kLoginPaddingLeftWidth);
                }];
            }
            if (!_activityIndicator) {
                _activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
                _activityIndicator.hidesWhenStopped = YES;
                [self.contentView addSubview:_activityIndicator];
                [_activityIndicator mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.center.equalTo(self.captchaView);
                }];
            }
        }else if ([reuseIdentifier isEqualToString:kCellIdentifier_Input_OnlyText_Cell_Password]){
            if (!_passwordBtn) {
                _textField.secureTextEntry = YES;

                _passwordBtn = [[UIButton alloc] initWithFrame:CGRectMake(kScreen_Width - 44- kLoginPaddingLeftWidth, 0, 44, 44)];
                [_passwordBtn setImage:[UIImage imageNamed:@"password_unlook"] forState:UIControlStateNormal];
                [_passwordBtn addTarget:self action:@selector(passwordBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
                [self.contentView addSubview:_passwordBtn];
            }
        }else if ([reuseIdentifier hasPrefix:kCellIdentifier_Input_OnlyText_Cell_PhoneCode_Prefix]){
            if (!_verify_codeBtn) {
                _verify_codeBtn = [[PhoneCodeButton alloc] initWithFrame:CGRectMake(kScreen_Width - 80 - kLoginPaddingLeftWidth, (44-25)/2, 80, 25)];
                [_verify_codeBtn addTarget:self action:@selector(phoneCodeButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
                [self.contentView addSubview:_verify_codeBtn];
                [_verify_codeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.size.mas_equalTo(CGSizeMake(80, 25));
                    make.centerY.equalTo(self.textField);
                    make.right.equalTo(self.contentView).offset(-kLoginPaddingLeftWidth);
                }];
            }
        }else if ([reuseIdentifier isEqualToString:kCellIdentifier_Input_OnlyText_Cell_Company]){
            if (!_companySuffixL) {
                _companySuffixL = [UILabel labelWithFont:[UIFont systemFontOfSize:17] textColor:kColor222];
                [self.contentView addSubview:_companySuffixL];
                [_companySuffixL mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.centerY.equalTo(self.textField);
                    make.right.equalTo(self.contentView).offset(-kPaddingLeftWidth);
                }];
                {
                    UIView *splitLineV = [UIView new];
                    splitLineV.backgroundColor = kColorDDD;
                    [self.contentView addSubview:splitLineV];
                    [splitLineV mas_makeConstraints:^(MASConstraintMaker *make) {
                        make.centerY.equalTo(self.textField);
                        make.size.mas_equalTo(CGSizeMake(1.0/[UIScreen mainScreen].scale, 20));
                        make.right.equalTo(self.companySuffixL.mas_left).offset(-10);
                    }];
                }
            }
        }else if ([reuseIdentifier isEqualToString:kCellIdentifier_Input_OnlyText_Cell_Phone]){
            _countryCodeL = ({
                UILabel *label = [UILabel new];
                label.font = [UIFont systemFontOfSize:15];
                label.textColor = kColorBrandBlue;
                [self.contentView addSubview:label];
                [label mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.left.equalTo(self.contentView).offset(kPaddingLeftWidth);
                    make.centerY.equalTo(self.textField);
                }];
                label;
            });
            UIView *lineV = ({
                UIView *view = [UIView new];
                view.backgroundColor = kColorCCC;
                [self.contentView addSubview:view];
                [view mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.left.equalTo(self.countryCodeL.mas_right).offset(8);
                    make.centerY.equalTo(self.countryCodeL);
                    make.width.mas_offset(0.5);
                    make.height.mas_equalTo(15.0);
                }];
                view;
            });
            UIButton *bgBtn = ({
                UIButton *button = [UIButton new];
                [self.contentView addSubview:button];
                [button mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.left.top.bottom.equalTo(self.contentView);
                    make.right.equalTo(lineV);
                }];
                button;
            });
            [bgBtn addTarget:self action:@selector(countryCodeBtnClicked:) forControlEvents:UIControlEventTouchUpInside];

            
            [_textField mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.height.mas_equalTo(20);
                make.right.equalTo(self.contentView).offset(-kLoginPaddingLeftWidth);
                make.left.equalTo(lineV.mas_right).offset(8.0);
                
                make.bottom.mas_greaterThanOrEqualTo(self.contentView).offset(-15).priority(MASLayoutPriorityRequired);
                make.centerY.equalTo(self.contentView).priority(MASLayoutPriorityDefaultLow);
            }];
        }
    }
    return self;
}

- (void)prepareForReuse{
    [super prepareForReuse];
    self.isBottomLineShow = NO;
    if (![self.reuseIdentifier isEqualToString:kCellIdentifier_Input_OnlyText_Cell_Password]) {
        self.textField.secureTextEntry = NO;
    }
    self.textField.userInteractionEnabled = YES;
    self.textField.keyboardType = UIKeyboardTypeDefault;
    
    self.editDidBeginBlock = nil;
    self.textValueChangedBlock = nil;
    self.editDidEndBlock = nil;
    self.phoneCodeBtnClckedBlock = nil;
}

- (void)setPlaceholder:(NSString *)phStr value:(NSString *)valueStr{
    self.textField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:phStr? phStr: @"" attributes:@{NSForegroundColorAttributeName: kColorDarkA}];
    self.textField.text = valueStr;
}

#pragma mark Button

- (void)clearBtnClicked:(id)sender {
    self.textField.text = @"";
    [self textValueChanged:nil];
}

- (void)phoneCodeButtonClicked:(id)sender{
    if (self.phoneCodeBtnClckedBlock) {
        self.phoneCodeBtnClckedBlock(sender);
    }
}
- (void)countryCodeBtnClicked:(id)sender{
    if (_countryCodeBtnClickedBlock) {
        _countryCodeBtnClickedBlock();
    }
}
#pragma mark - UIView
- (void)layoutSubviews {
    [super layoutSubviews];
    
    if (!_lineView && _isBottomLineShow) {
        _lineView = [UIView new];
        if (kTarget_Enterprise) {
            _lineView.backgroundColor = [UIColor colorWithHexString:@"0xD8DDE4"];
        }else{
            _lineView.backgroundColor = kColorDarkA;
        }
        [self.contentView addSubview:_lineView];
        [_lineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(kLine_MinHeight);
            make.left.equalTo(self.contentView).offset(kLoginPaddingLeftWidth);
            make.right.equalTo(self.contentView).offset(-kLoginPaddingLeftWidth);
            make.bottom.equalTo(self.contentView);
        }];
    }
    self.backgroundColor = [UIColor whiteColor];
    self.textField.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.textField.textColor = kColorDark2;
    self.clearBtn.hidden = YES;

    UIView *rightElement;
    if ([self.reuseIdentifier isEqualToString:kCellIdentifier_Input_OnlyText_Cell_Text]) {
        rightElement = nil;
    }else if ([self.reuseIdentifier isEqualToString:kCellIdentifier_Input_OnlyText_Cell_Captcha]){
        rightElement = _captchaView;
        [self refreshCaptchaImage];
    }else if ([self.reuseIdentifier isEqualToString:kCellIdentifier_Input_OnlyText_Cell_Password]){
        rightElement = _passwordBtn;
    }else if ([self.reuseIdentifier hasPrefix:kCellIdentifier_Input_OnlyText_Cell_PhoneCode_Prefix]){
        rightElement = _verify_codeBtn;
    }else if ([self.reuseIdentifier isEqualToString:kCellIdentifier_Input_OnlyText_Cell_Company]){
        rightElement = _companySuffixL;
    }

    [_clearBtn mas_updateConstraints:^(MASConstraintMaker *make) {
        CGFloat offset = rightElement? (CGRectGetMinX(rightElement.frame) - kScreen_Width - 10): -kLoginPaddingLeftWidth;
        make.right.equalTo(self.contentView).offset(offset);
    }];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{//layout 的时候，rightElement 的 frame 还没有固定
        [_textField mas_updateConstraints:^(MASConstraintMaker *make) {
            CGFloat offset = rightElement? (CGRectGetMinX(rightElement.frame) - kScreen_Width - 10): -kLoginPaddingLeftWidth;
            make.right.equalTo(self.contentView).offset(offset);
        }];
    });

}

#pragma password
- (void)passwordBtnClicked:(UIButton *)button{
    _textField.secureTextEntry = !_textField.secureTextEntry;
    [button setImage:[UIImage imageNamed:_textField.secureTextEntry? @"password_unlook": @"password_look"] forState:UIControlStateNormal];
}

#pragma Captcha
- (void)refreshCaptchaImage{
    __weak typeof(self) weakSelf = self;
    if (_activityIndicator.isAnimating) {
        return;
    }
    [_activityIndicator startAnimating];
    [self.captchaView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@api/getCaptcha", [NSObject baseURLStr]]] placeholderImage:nil options:(SDWebImageRetryFailed | SDWebImageRefreshCached | SDWebImageHandleCookies) completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        [weakSelf.activityIndicator stopAnimating];
    }];
}

#pragma mark TextField
- (void)editDidBegin:(id)sender {
    if (kTarget_Enterprise) {
        self.lineView.backgroundColor = [UIColor colorWithHexString:@"0x323A45"];
    }else{
        self.lineView.backgroundColor = kColorBrandBlue;
    }
    
    if (self.editDidBeginBlock) {
        self.editDidBeginBlock(self.textField.text);
    }
}

- (void)editDidEnd:(id)sender {
    if (kTarget_Enterprise) {
        self.lineView.backgroundColor = [UIColor colorWithHexString:@"0xD8DDE4"];
    }else{
        self.lineView.backgroundColor = kColorDarkA;
    }
    self.clearBtn.hidden = YES;
    if (self.editDidEndBlock) {
        self.editDidEndBlock(self.textField.text);
    }
}

- (void)textValueChanged:(id)sender {
    if (self.textValueChangedBlock) {
        self.textValueChangedBlock(self.textField.text);
    }
}
@end
