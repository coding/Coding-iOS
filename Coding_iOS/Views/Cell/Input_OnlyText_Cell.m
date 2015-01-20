//
//  Input_OnlyText_Cell.m
//  Coding_iOS
//
//  Created by 王 原闯 on 14-8-4.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#define kInput_OnlyText_Cell_LeftPading 18.0

#import "Input_OnlyText_Cell.h"
#import "Coding_NetAPIManager.h"

@interface Input_OnlyText_Cell ()
@property (strong, nonatomic) UIActivityIndicatorView *activityIndicator;
@end

@implementation Input_OnlyText_Cell

- (void)awakeFromNib
{
    // Initialization code
    _isCaptcha = NO;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (IBAction)editDidBegin:(id)sender {
    _lineView.backgroundColor = [UIColor colorWithHexString:@"0xffffff"];
    self.clearBtn.hidden = _isRegister? YES: self.textField.text.length <= 0;
}

- (IBAction)editDidEnd:(id)sender {
    _lineView.backgroundColor = [UIColor colorWithHexString:@"0xffffff" andAlpha:0.5];
    self.clearBtn.hidden = YES;
    if (self.editDidEndBlock) {
        self.editDidEndBlock(self.textField.text);
    }
}

- (void)configWithPlaceholder:(NSString *)phStr andValue:(NSString *)valueStr{
    self.textField.placeholder = phStr;
    self.textField.text = valueStr;
}
- (IBAction)textValueChanged:(id)sender {
    self.clearBtn.hidden = _isRegister? YES: self.textField.text.length <= 0;
    if (self.textValueChangedBlock) {
        self.textValueChangedBlock(self.textField.text);
    }
}

- (IBAction)clearBtnClicked:(id)sender {
    self.textField.text = @"";
    [self textValueChanged:nil];
}

#pragma mark - UIView
- (void)layoutSubviews {
    [super layoutSubviews];
    self.backgroundColor = _isRegister? [UIColor whiteColor]: [UIColor clearColor];
    self.textField.font = [UIFont systemFontOfSize:17];
    self.textField.textColor = _isRegister? [UIColor colorWithHexString:@"0x222222"]: [UIColor whiteColor];
    [self.textField setValue:[UIColor colorWithHexString:_isRegister? @"0x999999": @"0xffffff" andAlpha:_isRegister? 1.0: 0.5] forKeyPath:@"_placeholderLabel.textColor"];//修改placeholder颜色
    if (!_lineView && !_isRegister) {
        _lineView = [[UIView alloc] initWithFrame:CGRectMake(kInput_OnlyText_Cell_LeftPading, 43.5, kScreen_Width-2*kInput_OnlyText_Cell_LeftPading, 0.5)];
        _lineView.backgroundColor = [UIColor colorWithHexString:@"0xffffff" andAlpha:0.5];
        [self.contentView addSubview:_lineView];
    }
    if (_isCaptcha) {
        [self.textField setWidth:(kScreen_Width - 2*kInput_OnlyText_Cell_LeftPading) - (_isRegister? 70 : 90)];
        _captchaView.hidden = NO;
        [self refreshCaptchaImage];
    }else{
        [self.textField setWidth:(kScreen_Width - 2*kInput_OnlyText_Cell_LeftPading) - (_isRegister? 0:20)];
        _captchaView.hidden = YES;
    }
    [self.clearBtn setX:self.textField.maxXOfFrame];
    _lineView.hidden = _isRegister;
    if (_isRegister) {
        _clearBtn.hidden = YES;
    }
    self.textField.clearButtonMode = _isRegister? UITextFieldViewModeWhileEditing: UITextFieldViewModeNever;

}
- (void)refreshCaptchaImage{
    if (_activityIndicator && _activityIndicator.isAnimating) {
        return;
    }
    self.captchaImage = nil;
    __weak typeof(self) weakSelf = self;
    [[Coding_NetAPIManager sharedManager] loadImageWithPath:[NSString stringWithFormat:@"%@api/getCaptcha", kNetPath_Code_Base] completeBlock:^(UIImage *image, NSError *error) {
        if (image) {
            weakSelf.captchaImage = image;
        }else{
            weakSelf.captchaImage = [UIImage imageNamed:@"captcha_loadfail"];
        }
    }];
}
- (void)setCaptchaImage:(UIImage *)captchaImage{
    __weak typeof(self) weakSelf = self;
    if (!_captchaView) {
        _captchaView = [[UITapImageView alloc] initWithFrame:CGRectMake(kScreen_Width-60-kInput_OnlyText_Cell_LeftPading, (44-25)/2, 60, 25)];
        
        _captchaView.layer.masksToBounds = YES;
        _captchaView.layer.cornerRadius = 5;
        
        [_captchaView addTapBlock:^(id obj) {
            [weakSelf refreshCaptchaImage];
        }];
        [self.contentView addSubview:_captchaView];
    }
    if (captchaImage) {
        [_activityIndicator stopAnimating];
        _captchaImage = captchaImage;
        _captchaView.image = captchaImage;
    }else{
        if (!_activityIndicator) {
            _activityIndicator = [[UIActivityIndicatorView alloc]
                                 initWithActivityIndicatorStyle:
                                 UIActivityIndicatorViewStyleGray];
            CGSize captchaViewSize = _captchaView.bounds.size;
            _activityIndicator.hidesWhenStopped = YES;
            [_activityIndicator setCenter:CGPointMake(captchaViewSize.width/2, captchaViewSize.height/2)];
            [_captchaView addSubview:_activityIndicator];
        }
        [_activityIndicator startAnimating];
    }
}
@end
