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

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        if (!_textField) {
            _textField = [UITextField new];
            [_textField setFont:[UIFont systemFontOfSize:17]];
            [_textField addTarget:self action:@selector(editDidBegin:) forControlEvents:UIControlEventEditingDidBegin];
            [_textField addTarget:self action:@selector(textValueChanged:) forControlEvents:UIControlEventEditingChanged];
            [_textField addTarget:self action:@selector(editDidEnd:) forControlEvents:UIControlEventEditingDidEnd];
            [self.contentView addSubview:_textField];
            [_textField mas_makeConstraints:^(MASConstraintMaker *make) {
                make.height.mas_equalTo(20);
                make.left.equalTo(self.contentView).offset(kLoginPaddingLeftWidth);
                make.right.equalTo(self.contentView).offset(-kLoginPaddingLeftWidth);
                make.centerY.equalTo(self.contentView);
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
            }
        }else if ([reuseIdentifier isEqualToString:kCellIdentifier_Input_OnlyText_Cell_Phone]){
            _countryCodeL = ({
                UILabel *label = [UILabel new];
                label.font = [UIFont systemFontOfSize:17];
                label.textColor = [UIColor colorWithHexString:@"0x3bbd79"];
                [self.contentView addSubview:label];
                [label mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.left.equalTo(self.contentView).offset(kPaddingLeftWidth);
                    make.centerY.equalTo(self.contentView);
                }];
                label;
            });
            UIView *lineV = ({
                UIView *view = [UIView new];
                view.backgroundColor = [UIColor colorWithHexString:@"0xCCCCCC"];
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
                make.centerY.equalTo(self.contentView);
                make.left.equalTo(lineV.mas_right).offset(8.0);
            }];
        }
    }
    return self;
}

- (void)prepareForReuse{
    self.isForLoginVC = NO;
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
    self.textField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:phStr? phStr: @"" attributes:@{NSForegroundColorAttributeName: [UIColor colorWithHexString:_isForLoginVC? @"0xffffff": @"0x999999" andAlpha:_isForLoginVC? 0.5: 1.0]}];
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
    
    if (_isForLoginVC) {
        if (!_clearBtn) {
            _clearBtn = [UIButton new];
            _clearBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
            [_clearBtn setImage:[UIImage imageNamed:@"text_clear_btn"] forState:UIControlStateNormal];
            [_clearBtn addTarget:self action:@selector(clearBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
            [self.contentView addSubview:_clearBtn];
            [_clearBtn mas_makeConstraints:^(MASConstraintMaker *make) {
                make.size.mas_equalTo(CGSizeMake(30, 30));
                make.right.equalTo(self.contentView).offset(-kLoginPaddingLeftWidth);
                make.centerY.equalTo(self.contentView);
            }];
        }
        if (!_lineView) {
            _lineView = [UIView new];
            _lineView.backgroundColor = [UIColor colorWithHexString:@"0xffffff" andAlpha:0.5];
            [self.contentView addSubview:_lineView];
            [_lineView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.height.mas_equalTo(0.5);
                make.left.equalTo(self.contentView).offset(kLoginPaddingLeftWidth);
                make.right.equalTo(self.contentView).offset(-kLoginPaddingLeftWidth);
                make.bottom.equalTo(self.contentView);
            }];
        }
    }
    
    self.backgroundColor = _isForLoginVC? [UIColor clearColor]: [UIColor whiteColor];
    self.textField.clearButtonMode = _isForLoginVC? UITextFieldViewModeNever: UITextFieldViewModeWhileEditing;
    self.textField.textColor = _isForLoginVC? [UIColor whiteColor]: [UIColor colorWithHexString:@"0x222222"];
    self.lineView.hidden = !_isForLoginVC;
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
    }
    
    [_clearBtn mas_updateConstraints:^(MASConstraintMaker *make) {
        CGFloat offset = rightElement? (CGRectGetMinX(rightElement.frame) - kScreen_Width - 10): -kLoginPaddingLeftWidth;
        make.right.equalTo(self.contentView).offset(offset);
    }];
    
    [_textField mas_updateConstraints:^(MASConstraintMaker *make) {
        CGFloat offset = rightElement? (CGRectGetMinX(rightElement.frame) - kScreen_Width - 10): -kLoginPaddingLeftWidth;
        offset -= self.isForLoginVC? 30: 0;
        make.right.equalTo(self.contentView).offset(offset);
    }];
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
    self.lineView.backgroundColor = [UIColor colorWithHexString:@"0xffffff"];
    self.clearBtn.hidden = _isForLoginVC? self.textField.text.length <= 0: YES;
    
    if (self.editDidBeginBlock) {
        self.editDidBeginBlock(self.textField.text);
    }
}

- (void)editDidEnd:(id)sender {
   self.lineView.backgroundColor = [UIColor colorWithHexString:@"0xffffff" andAlpha:0.5];
    self.clearBtn.hidden = YES;
    
    if (self.editDidEndBlock) {
        self.editDidEndBlock(self.textField.text);
    }
}

- (void)textValueChanged:(id)sender {
    self.clearBtn.hidden = _isForLoginVC? self.textField.text.length <= 0: YES;
    
    if (self.textValueChangedBlock) {
        self.textValueChangedBlock(self.textField.text);
    }
}
@end
