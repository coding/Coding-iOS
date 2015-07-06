//
//  ZXScanCodeViewController.m
//  Coding_iOS
//
//  Created by Ease on 15/7/2.
//  Copyright (c) 2015年 Coding. All rights reserved.
//

#import "ZXScanCodeViewController.h"
#import <ZXingObjC/ZXingObjC.h>

@interface ZXScanCodeViewController ()<ZXCaptureDelegate>
@property (nonatomic, strong) ZXCapture *capture;
@property (strong, nonatomic) UIView *scanRectView;
@property (assign, nonatomic) BOOL scanSucessed;
@end

@implementation ZXScanCodeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"扫描条形码";
    self.view.backgroundColor = [UIColor blackColor];
    
    self.capture = [[ZXCapture alloc] init];
    self.capture.camera = self.capture.back;
    self.capture.focusMode = AVCaptureFocusModeContinuousAutoFocus;
    self.capture.rotation = 90.0f;
    

}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    self.capture.layer.frame = self.view.bounds;
    [self.view.layer addSublayer:self.capture.layer];
    
    self.capture.delegate = self;
    self.capture.layer.frame = self.view.bounds;
    
    CGFloat padding = kPaddingLeftWidth;
    CGFloat width = kScreen_Width - 2*padding;
    CGRect scanRect = CGRectMake(padding, (CGRectGetHeight(self.view.frame) - width)/2, width, width);
    
    if (!_scanRectView) {
        _scanRectView = [[UIView alloc] initWithFrame:scanRect];
        _scanRectView.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.2];
        [self.view addSubview:_scanRectView];
    }
    self.capture.scanRect = scanRect;
}

- (void)dealloc {
    [self.capture.layer removeFromSuperlayer];
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
@end
