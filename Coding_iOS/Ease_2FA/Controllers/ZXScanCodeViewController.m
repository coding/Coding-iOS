//
//  ZXScanCodeViewController.m
//  Coding_iOS
//
//  Created by Ease on 15/7/2.
//  Copyright (c) 2015年 Coding. All rights reserved.
//

#import "ZXScanCodeViewController.h"
#import "ScanBGView.h"
#import <ZXingObjC/ZXingObjC.h>

@interface ZXScanCodeViewController ()<ZXCaptureDelegate>
@property (nonatomic, strong) ZXCapture *capture;
@property (strong, nonatomic) ScanBGView *myScanBGView;
@property (strong, nonatomic) UIImageView *scanRectView, *lineView;
@property (strong, nonatomic) UILabel *tipLabel;
@property (assign, nonatomic) BOOL scanSucessed;
@end

@implementation ZXScanCodeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"扫描二维码";
    self.view.backgroundColor = [UIColor blackColor];
    
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self
           selector:@selector(applicationDidBecomeActive:)
               name:UIApplicationDidBecomeActiveNotification
             object:nil];
    [nc addObserver:self
           selector:@selector(applicationWillResignActive:)
               name:UIApplicationWillResignActiveNotification
             object:nil];

}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self configUI];
}

- (void)configUI{
    CGFloat width = kScreen_Width *2/3;
    CGFloat padding = (kScreen_Width - width)/2;
    CGRect scanRect = CGRectMake(padding, kScreen_Height/10, width, width);
    
    if (!_capture) {
        _capture = [[ZXCapture alloc] init];
        _capture.camera = _capture.back;
        _capture.focusMode = AVCaptureFocusModeContinuousAutoFocus;
        _capture.rotation = 90.f;
        _capture.layer.frame = self.view.bounds;
        _capture.scanRect = scanRect;
        _capture.delegate = self;
    }
    
    if (!_myScanBGView) {
        _myScanBGView = [[ScanBGView alloc] initWithFrame:self.view.bounds];
        _myScanBGView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.2];
        _myScanBGView.scanRect = scanRect;
    }
    
    if (!_scanRectView) {
        _scanRectView = [[UIImageView alloc] initWithFrame:scanRect];
        _scanRectView.image = [[UIImage imageNamed:@"scan_bg"] resizableImageWithCapInsets:UIEdgeInsetsMake(25, 25, 25, 25)];
        _scanRectView.clipsToBounds = YES;
    }
    if (!_tipLabel) {
        _tipLabel = [UILabel new];
        _tipLabel.textAlignment = NSTextAlignmentCenter;
        _tipLabel.font = [UIFont boldSystemFontOfSize:16];
        _tipLabel.textColor = [UIColor whiteColor];
        _tipLabel.text = @"将二维码放入框内，即可自动扫描";
    }
    if (!_lineView) {
        UIImage *lineImage = [UIImage imageNamed:@"scan_line"];
        CGFloat lineHeight = 2;
        CGFloat lineWidth = CGRectGetWidth(_scanRectView.frame);
        _lineView = [[UIImageView alloc] initWithFrame:CGRectMake(0, -lineHeight, lineWidth, lineHeight)];
        _lineView.contentMode = UIViewContentModeScaleToFill;
        _lineView.image = lineImage;
    }
    
    [self.view.layer addSublayer:_capture.layer];
    [self.view addSubview:_myScanBGView];
    [self.view addSubview:_scanRectView];
    [self.view addSubview:_tipLabel];
    [_tipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.top.equalTo(_scanRectView.mas_bottom).offset(20);
        make.height.mas_equalTo(30);
    }];
    [_scanRectView addSubview:_lineView];
    
    [self scanLineStartAction];
}

- (void)scanLineStartAction{
    [self scanLineStopAction];
    
    CABasicAnimation *scanAnimation = [CABasicAnimation animationWithKeyPath:@"position.y"];
    scanAnimation.fromValue = @(-CGRectGetHeight(_lineView.frame));
    scanAnimation.toValue = @(CGRectGetHeight(_lineView.frame) + CGRectGetHeight(_scanRectView.frame));

    scanAnimation.repeatCount = CGFLOAT_MAX;
    scanAnimation.duration = 2.0;
    [self.lineView.layer addAnimation:scanAnimation forKey:@"basic"];
}
- (void)scanLineStopAction{
    [self.lineView.layer removeAllAnimations];
}

- (void)dealloc {
    [self.capture.layer removeFromSuperlayer];
    self.capture = nil;
    [self scanLineStopAction];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma p_Method
- (NSString *)barcodeFormatToString:(ZXBarcodeFormat)format {
    switch (format) {
        case kBarcodeFormatAztec:
            return @"Aztec";
            
        case kBarcodeFormatCodabar:
            return @"CODABAR";
            
        case kBarcodeFormatCode39:
            return @"Code 39";
            
        case kBarcodeFormatCode93:
            return @"Code 93";
            
        case kBarcodeFormatCode128:
            return @"Code 128";
            
        case kBarcodeFormatDataMatrix:
            return @"Data Matrix";
            
        case kBarcodeFormatEan8:
            return @"EAN-8";
            
        case kBarcodeFormatEan13:
            return @"EAN-13";
            
        case kBarcodeFormatITF:
            return @"ITF";
            
        case kBarcodeFormatPDF417:
            return @"PDF417";
            
        case kBarcodeFormatQRCode:
            return @"QR Code";
            
        case kBarcodeFormatRSS14:
            return @"RSS 14";
            
        case kBarcodeFormatRSSExpanded:
            return @"RSS Expanded";
            
        case kBarcodeFormatUPCA:
            return @"UPCA";
            
        case kBarcodeFormatUPCE:
            return @"UPCE";
            
        case kBarcodeFormatUPCEANExtension:
            return @"UPC/EAN extension";
            
        default:
            return @"Unknown";
    }
}

#pragma mark ZXCaptureDelegate
- (void)captureResult:(ZXCapture *)capture result:(ZXResult *)result{
    NSLog(@"result : %@", result.text);

    if (!result || _scanSucessed) return;
    _scanSucessed = YES;
    [capture stop];

    // Vibrate
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    
    OTPAuthURL *authURL = [OTPAuthURL authURLWithURL:[NSURL URLWithString:result.text] secret:nil];
    if ([authURL isKindOfClass:[TOTPAuthURL class]]) {
        if (self.sucessScanBlock) {
            self.sucessScanBlock(authURL);
        }
        [self.navigationController popViewControllerAnimated:YES];
    }else{
        NSString *tipStr;
        if (authURL) {
            tipStr = @"目前仅支持 TOTP 类型的身份验证令牌";
        }else{
            NSString *formatString = [self barcodeFormatToString:result.barcodeFormat];
            NSString *resultString = result.text;
            tipStr = [NSString stringWithFormat:@"条码「%@ : %@」不是有效的身份验证令牌条码", formatString, resultString];
        }

        UIAlertView *alertV = [UIAlertView bk_alertViewWithTitle:@"无效条码" message:tipStr];
        [alertV bk_addButtonWithTitle:@"重试" handler:^{
            self.scanSucessed = NO;
            [capture start];
        }];
        [alertV show];
    }
}

#pragma mark Notification
- (void)applicationDidBecomeActive:(UIApplication *)application {
    [self.capture start];
    [self scanLineStartAction];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    [self.capture stop];
    [self scanLineStopAction];
}
@end
