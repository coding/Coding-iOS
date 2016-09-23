//
//  OTPTableViewCell.m
//  Coding_iOS
//
//  Created by Ease on 15/7/3.
//  Copyright (c) 2015年 Coding. All rights reserved.
//

#import "OTPTableViewCell.h"
#import "OTPAuthClock.h"
#import "TOTPGenerator.h"

@interface OTPTableViewCell ()
@property (strong, nonatomic) UILabel *issuerLabel, *passwordLabel, *nameLabel;
- (void)updateUI;
- (void)otpAuthURLDidGenerateNewOTP:(NSNotification *)notification;

@end

@interface TOTPTableViewCell ()
@property (strong, nonatomic) OTPAuthClock *clockView;
@property (strong, nonatomic) UILabel *back_passwordLabel;
@property (assign, nonatomic) BOOL isDuringWarning;


- (void)otpAuthURLWillGenerateNewOTP:(NSNotification *)notification;
@end

@interface HOTPTableViewCell ()
@property (strong, nonatomic) UIButton *refreshButton;

@end

@implementation OTPTableViewCell
+ (CGFloat)cellHeight{
    return 120;
}

- (void)setAuthURL:(OTPAuthURL *)authURL{
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc removeObserver:self name:OTPAuthURLDidGenerateNewOTPNotification object:_authURL];
    _authURL = authURL;
    [nc addObserver:self selector:@selector(otpAuthURLDidGenerateNewOTP:) name:OTPAuthURLDidGenerateNewOTPNotification object:_authURL];

    [self updateUI];
}

- (void)updateUI{
    if (!_issuerLabel) {
        _issuerLabel = [UILabel new];
        _issuerLabel.font = [UIFont systemFontOfSize:16];
        _issuerLabel.textColor = kColor666;
        [self.contentView addSubview:_issuerLabel];
        [_issuerLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.contentView).offset(10);
            make.left.equalTo(self.contentView).offset(kPaddingLeftWidth);
            make.right.equalTo(self.contentView).offset(-kPaddingLeftWidth);
            make.height.mas_equalTo(20);
        }];
    }
    if (!_passwordLabel) {
        _passwordLabel = [UILabel new];
        _passwordLabel.font = [UIFont systemFontOfSize:50];
        _passwordLabel.textColor = kColorBrandGreen;
        [self.contentView addSubview:_passwordLabel];
        [_passwordLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.contentView);
            make.left.equalTo(self.contentView).offset(kPaddingLeftWidth);
            make.right.equalTo(self.contentView).offset(-kPaddingLeftWidth);
            make.height.mas_equalTo(50);
        }];
    }
    if (!_nameLabel) {
        _nameLabel = [UILabel new];
        _nameLabel.font = [UIFont systemFontOfSize:14];
        _nameLabel.textColor = kColor999;
        [self.contentView addSubview:_nameLabel];
        [_nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.contentView).offset(-10);
            make.left.equalTo(self.contentView).offset(kPaddingLeftWidth);
            make.right.equalTo(self.contentView).offset(-kPaddingLeftWidth);
            make.height.mas_equalTo(20);
        }];
    }
    _issuerLabel.text = _authURL.issuer;
    _passwordLabel.text = _authURL.otpCode.length < 6? _authURL.otpCode: [_authURL.otpCode stringByReplacingCharactersInRange:NSMakeRange(3, 0) withString:@" "];
    _nameLabel.text = _authURL.name;
}
- (void)otpAuthURLDidGenerateNewOTP:(NSNotification *)notification{
    [self updateUI];
}
@end

@implementation TOTPTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style
    reuseIdentifier:(NSString *)reuseIdentifier {
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
        [nc addObserver:self
               selector:@selector(applicationWillEnterForeground:)
                   name:UIApplicationWillEnterForegroundNotification
                 object:nil];
    }
    return self;
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    NSString *curCode = self.authURL.otpCode;
    NSString *displayingCode = self.passwordLabel.text;
    if (![curCode isEqualToString:displayingCode]) {
        [self otpAuthURLDidGenerateNewOTP:nil];
    }
}

- (void)dealloc {
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc removeObserver:self];
    [self.clockView invalidate];
}

- (void)setAuthURL:(OTPAuthURL *)authURL{
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc removeObserver:self name:OTPAuthURLWillGenerateNewOTPWarningNotification object:self.authURL];
    super.authURL = authURL;
    [nc addObserver:self selector:@selector(otpAuthURLWillGenerateNewOTP:) name:OTPAuthURLWillGenerateNewOTPWarningNotification object:self.authURL];
    [self updateUI];
}
- (void)updateUI{
    [super updateUI];
    if (!_back_passwordLabel) {
        _back_passwordLabel = [UILabel new];
        _back_passwordLabel.font = [UIFont systemFontOfSize:50];
        _back_passwordLabel.textColor = [UIColor colorWithHexString:@"0xE15957"];
        [self.contentView addSubview:_back_passwordLabel];
        [_back_passwordLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.passwordLabel);
        }];
    }
    if (!_clockView) {
        CGFloat clockWidth = 25.f;
        _clockView = [[OTPAuthClock alloc] initWithFrame:CGRectMake(0, 0, clockWidth, clockWidth) period:[TOTPGenerator defaultPeriod]];
        [_clockView setCenter:CGPointMake(CGRectGetWidth(self.contentView.frame) - clockWidth, CGRectGetHeight(self.contentView.frame) - clockWidth)];
        [self.contentView addSubview:_clockView];
    }
    self.back_passwordLabel.text = self.passwordLabel.text;
    self.back_passwordLabel.alpha = 0.0;
    self.passwordLabel.alpha = 1.0;
}

- (void)otpAuthURLWillGenerateNewOTP:(NSNotification *)notification{
    [self waringAnimation];
}

- (void)prepareForReuse{
    [self.contentView.layer removeAllAnimations];
    for (UIView *view in [self subviews]) {
        if ([view isKindOfClass:NSClassFromString(@"UITableViewCellDeleteConfirmationView")]) {
            [view removeFromSuperview];
        }
    }
//    [self setEditing:NO];
}

- (void)waringAnimation{
    NSTimeInterval period = [TOTPGenerator defaultPeriod];
    NSTimeInterval seconds = [[NSDate date] timeIntervalSince1970];
    CGFloat mod =  fmod(seconds, period);
    CGFloat percent = mod / period;

    if (percent < 0.85) {//(26/30)
        return;
    }
    
    [UIView animateWithDuration:0.5 animations:^{
        self.passwordLabel.alpha = 0.0;
        self.back_passwordLabel.alpha = 1.0;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.5 animations:^{
            self.passwordLabel.alpha = 1.0;
            self.back_passwordLabel.alpha = 0.0;
        } completion:^(BOOL finished) {
            [self waringAnimation];
        }];
    }];
}

@end

@implementation HOTPTableViewCell
- (void)updateUI{
    [super updateUI];

}
@end


