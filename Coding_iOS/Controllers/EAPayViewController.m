//
//  EAPayViewController.m
//  Coding_iOS
//
//  Created by Easeeeeeeeee on 2017/11/29.
//  Copyright © 2017年 Coding. All rights reserved.
//

#import "EAPayViewController.h"

#import <AlipaySDK/AlipaySDK.h>
#import <UMengUShare/WXApi.h>
#import <UMengUShare/WXApiObject.h>

#import "Coding_NetAPIManager.h"

@interface EAPayViewController ()

@property (assign, nonatomic) NSInteger payMethod;//0 alipay, 1 wechat
@property (strong, nonatomic) NSDictionary *payDict;

@end

@implementation EAPayViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"支付";
    self.payMethod = 0;
}

- (IBAction)methodBtnClicked:(UIButton *)sender {
    self.payMethod = sender.tag;
    if (self.payMethod == 1 && ![self p_canOpenWeiXin]){
        [NSObject showHudTipStr:@"您还没有安装「微信」"];
        return;
    }
    [NSObject showHUDQueryStr:@"请稍等..."];
    __weak typeof(self) weakSelf = self;
    [[Coding_NetAPIManager sharedManager] request_shop_payOrder:_shopOrder.orderNo method:_payMethod == 0? @"Alipay": @"Weixin" andBlock:^(NSDictionary *payDict, NSError *error) {
        [NSObject hideHUDQuery];
        weakSelf.payDict = payDict;
        if (weakSelf.payMethod == 0) {
            [weakSelf aliPay];
        }else{
            [weakSelf weixinPay];
        }
    }];
}

- (void)aliPay{
    __weak typeof(self) weakSelf = self;
    [[AlipaySDK defaultService] payOrder:_payDict[@"url"] fromScheme:kCodingAppScheme callback:^(NSDictionary *resultDic) {
        [weakSelf handleAliResult:resultDic];
    }];
}

- (void)weixinPay{
    PayReq *req = [PayReq new];
    NSDictionary *resultDict = _payDict;
    
    req.partnerId = resultDict[@"partnerId"];
    req.prepayId = resultDict[@"prepayId"];
    req.nonceStr = resultDict[@"nonceStr"];
    req.timeStamp = [resultDict[@"timestamp"] intValue];
    req.package = resultDict[@"package"];
    req.sign = resultDict[@"sign"];
    [WXApi sendReq:req];
}

- (void)handleAliResult:(NSDictionary *)resultDic{
    DebugLog(@"handleAliResult: %@", resultDic);
    BOOL isPaySuccess = NO;
    if (_payMethod == 0) {
        isPaySuccess = ([resultDic[@"resultStatus"] integerValue] == 9000);
    }else{
        NSInteger resultCode = [resultDic[@"ret"] intValue];
        isPaySuccess = (resultCode == 0);
    }
    [NSObject showHudTipStr:isPaySuccess? @"支付成功": @"支付失败"];
    if (isPaySuccess) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)handlePayURL:(NSURL *)url{
    if (_payMethod == 0) {
        __weak typeof(self) weakSelf = self;
        [[AlipaySDK defaultService] processOrderWithPaymentResult:url standbyCallback:^(NSDictionary *resultDic) {
            [weakSelf handleAliResult:resultDic];
        }];
    }else{
        [self handleAliResult:[url queryParams]];
    }
}

#pragma mark - app url
- (BOOL)p_canOpenWeiXin{
    return [self p_canOpen:@"weixin://"];
}

- (BOOL)p_canOpenAlipay{
    return [self p_canOpen:@"alipay://"];
}

- (BOOL)p_canOpen:(NSString*)url{
    return [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:url]];
}

@end
