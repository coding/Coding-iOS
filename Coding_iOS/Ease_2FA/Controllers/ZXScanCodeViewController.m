//
//  ZXScanCodeViewController.m
//  Coding_iOS
//
//  Created by Ease on 15/7/2.
//  Copyright (c) 2015年 Coding. All rights reserved.
//

#import "ZXScanCodeViewController.h"
#import "ScanBGView.h"
#import "Helper.h"

@interface ZXScanCodeViewController ()<AVCaptureMetadataOutputObjectsDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>
@property (strong, nonatomic) ScanBGView *myScanBGView;
@property (strong, nonatomic) UIImageView *scanRectView, *lineView;
@property (strong, nonatomic) UILabel *tipLabel;

@property (strong, nonatomic) AVCaptureVideoPreviewLayer *videoPreviewLayer;
@property (strong, nonatomic) CIDetector *detector;
@end

@implementation ZXScanCodeViewController

- (CIDetector *)detector{
    if (!_detector) {
        _detector = [CIDetector detectorOfType:CIDetectorTypeQRCode context:nil options:@{ CIDetectorAccuracy : CIDetectorAccuracyHigh }];
    }
    return _detector;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"扫描二维码";
    self.view.backgroundColor = [UIColor blackColor];
    self.navigationItem.rightBarButtonItem = [UIBarButtonItem itemWithBtnTitle:@"相册" target:self action:@selector(clickRightBarButton:)];

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
    if (!_videoPreviewLayer) {
        [self configUI];
    }else{
        [self startScan];
    }
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self stopScan];
}

- (void)configUI{
    CGFloat width = kScreen_Width *2/3;
    CGFloat padding = (kScreen_Width - width)/2;
    CGRect scanRect = CGRectMake(padding, kScreen_Height/10, width, width);
    
    if (!_videoPreviewLayer) {
        NSError *error;
        AVCaptureDevice *captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:captureDevice error:&error];
        if (!input) {
            kTipAlert(@"%@", error.localizedDescription);
            [self.navigationController popViewControllerAnimated:YES];
        }else{
            //设置会话的输入设备
            AVCaptureSession *captureSession = [AVCaptureSession new];
            [captureSession addInput:input];
            //对应输出
            AVCaptureMetadataOutput *captureMetadataOutput = [[AVCaptureMetadataOutput alloc] init];
            [captureMetadataOutput setMetadataObjectsDelegate:self queue:dispatch_queue_create("ease_capture_queue",NULL)];
            [captureSession addOutput:captureMetadataOutput];

            //设置条码类型:包含 AVMetadataObjectTypeQRCode 就好
            if (![captureMetadataOutput.availableMetadataObjectTypes containsObject:AVMetadataObjectTypeQRCode]) {
                kTipAlert(@"摄像头不支持扫描二维码！");
                [self.navigationController popViewControllerAnimated:YES];
            }else{
                [captureMetadataOutput setMetadataObjectTypes:captureMetadataOutput.availableMetadataObjectTypes];
            }
            captureMetadataOutput.rectOfInterest = CGRectMake(CGRectGetMinY(scanRect)/CGRectGetHeight(self.view.frame),
                                                               1 - CGRectGetMaxX(scanRect)/CGRectGetWidth(self.view.frame),
                                                               CGRectGetHeight(scanRect)/CGRectGetHeight(self.view.frame),
                                                               CGRectGetWidth(scanRect)/CGRectGetWidth(self.view.frame));//设置扫描区域。。默认是手机头向左的横屏坐标系（逆时针旋转90度）
            //将捕获的数据流展现出来
            _videoPreviewLayer = [AVCaptureVideoPreviewLayer layerWithSession:captureSession];
            [_videoPreviewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
            [_videoPreviewLayer setFrame:self.view.bounds];
        }
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
        _tipLabel.textColor = [[UIColor whiteColor] colorWithAlphaComponent:0.5];
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
    
    [self.view.layer addSublayer:_videoPreviewLayer];
    [self.view addSubview:_myScanBGView];
    [self.view addSubview:_scanRectView];
    [self.view addSubview:_tipLabel];
    [_tipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.top.equalTo(_scanRectView.mas_bottom).offset(20);
        make.height.mas_equalTo(30);
    }];
    [_scanRectView addSubview:_lineView];
    [_videoPreviewLayer.session startRunning];
    [self scanLineStartAction];
}

- (void)scanLineStartAction{
    [self scanLineStopAction];
    
    CABasicAnimation *scanAnimation = [CABasicAnimation animationWithKeyPath:@"position.y"];
    scanAnimation.fromValue = @(-CGRectGetHeight(_lineView.frame));
    scanAnimation.toValue = @(CGRectGetHeight(_lineView.frame) + CGRectGetHeight(_scanRectView.frame));
    
    scanAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    scanAnimation.repeatCount = CGFLOAT_MAX;
    scanAnimation.duration = 2.0;
    [self.lineView.layer addAnimation:scanAnimation forKey:@"basic"];
}
- (void)scanLineStopAction{
    [self.lineView.layer removeAllAnimations];
}

- (void)dealloc {
    [self.videoPreviewLayer removeFromSuperlayer];
    self.videoPreviewLayer = nil;
    [self scanLineStopAction];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark AVCaptureMetadataOutputObjectsDelegate

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection{
    //判断是否有数据，是否是二维码数据
    if (metadataObjects.count > 0) {
        __block AVMetadataMachineReadableCodeObject *result = nil;
        [metadataObjects enumerateObjectsUsingBlock:^(AVMetadataMachineReadableCodeObject *obj, NSUInteger idx, BOOL *stop) {
            if ([obj.type isEqualToString:AVMetadataObjectTypeQRCode]) {
                result = obj;
                *stop = YES;
            }
        }];
        if (!result) {
            result = [metadataObjects firstObject];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self analyseResult:result];
        });
    }
}

- (void)analyseResult:(AVMetadataMachineReadableCodeObject *)result{
    NSString *resultStr = result.stringValue;
    if (resultStr.length <= 0) {
        return;
    }
    //停止扫描
    [self stopScan];
    //震动反馈
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    //交给 block 处理
    if (_scanResultBlock) {
        _scanResultBlock(self, resultStr);
    }
}

#pragma mark Notification
- (void)applicationDidBecomeActive:(UIApplication *)application {
    [self startScan];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    [self stopScan];
}
#pragma mark Photo
-(void)clickRightBarButton:(UIBarButtonItem*)item{
    if (![Helper checkPhotoLibraryAuthorizationStatus]) {
        return;
    }
    //停止扫描
    [self stopScan];
    
    UIImagePickerController *picker = [UIImagePickerController new];
    picker.delegate = self;
    picker.allowsEditing = NO;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    [self.navigationController presentViewController:picker animated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    [picker dismissViewControllerAnimated:YES completion:^{
        [self handleImageInfo:info];
    }];
}

- (void)handleImageInfo:(NSDictionary *)info{
    //停止扫描
    [self stopScan];
    
    UIImage *image = [info objectForKey:UIImagePickerControllerEditedImage];
    if (!image){
        image = [info objectForKey:UIImagePickerControllerOriginalImage];
    }
    __block NSString *resultStr = nil;
    NSArray *features = [self.detector featuresInImage:[CIImage imageWithCGImage:image.CGImage]];
    [features enumerateObjectsUsingBlock:^(CIQRCodeFeature *obj, NSUInteger idx, BOOL *stop) {
        if (obj.messageString.length > 0) {
            resultStr = obj.messageString;
            *stop = YES;
        }
    }];
    //震动反馈
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    //交给 block 处理
    if (_scanResultBlock) {
        _scanResultBlock(self, resultStr);
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark public
- (BOOL)isScaning{
    return _videoPreviewLayer.session.isRunning;
}
- (void)startScan{
    [self.videoPreviewLayer.session startRunning];
    [self scanLineStartAction];
}
- (void)stopScan{
    [self.videoPreviewLayer.session stopRunning];
    [self scanLineStopAction];
}
@end
