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
    [self.textField setValue:[UIColor colorWithHexString:@"0x304054"] forKeyPath:@"_placeholderLabel.textColor"];//修改placeholder颜色
//    _lineView.backgroundColor = [UIColor colorWithHexString:@"0x2eadb9"];
}

- (IBAction)editDidEnd:(id)sender {
    [self.textField setValue:[UIColor colorWithHexString:@"0x8092a8"] forKeyPath:@"_placeholderLabel.textColor"];//修改placeholder颜色
//    _lineView.backgroundColor = [UIColor colorWithHexString:@"0xaebdc9"];
}

- (void)configWithPlaceholder:(NSString *)phStr andValue:(NSString *)valueStr{
    self.textField.placeholder = phStr;
    self.textField.text = valueStr;
}
- (IBAction)textValueChanged:(id)sender {
    if (self.textValueChangedBlock) {
        self.textValueChangedBlock(self.textField.text);
    }
}

#pragma mark - UIView
- (void)layoutSubviews {
    [super layoutSubviews];
    self.backgroundView = nil;
    self.backgroundColor = [UIColor clearColor];
    self.textField.font = [UIFont systemFontOfSize:15];
    [self.textField setValue:[UIColor colorWithHexString:@"0x8092a8"] forKeyPath:@"_placeholderLabel.textColor"];//修改placeholder颜色
    self.textField.clearButtonMode = UITextFieldViewModeWhileEditing;
    if (!_lineView) {
        _lineView = [[UIView alloc] initWithFrame:CGRectMake(kInput_OnlyText_Cell_LeftPading, 43.5, kScreen_Width-2*kInput_OnlyText_Cell_LeftPading, 0.5)];
        _lineView.backgroundColor = [UIColor colorWithHexString:@"0xaebdc9"];
        [self.contentView addSubview:_lineView];
    }
    if (_isCaptcha) {
        [self.textField setFrame:CGRectMake(kInput_OnlyText_Cell_LeftPading, 12, (kScreen_Width - 2*kInput_OnlyText_Cell_LeftPading) -100, 20)];
        _captchaView.hidden = NO;
        [self refreshCaptchaImage];
    }else{
        [self.textField setFrame:CGRectMake(kInput_OnlyText_Cell_LeftPading, 12, (kScreen_Width - 2*kInput_OnlyText_Cell_LeftPading), 20)];
        _captchaView.hidden = YES;
    }
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
