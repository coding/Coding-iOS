//
//  Helper.m
//  Coding_iOS
//
//  Created by Elf Sundae on 14-12-22.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#import "Helper.h"
@import AVFoundation;

@implementation Helper

+ (BOOL)checkPhotoLibraryAuthorizationStatus
{
    PHAuthorizationStatus authStatus = PHPhotoLibrary.authorizationStatus;
    if (authStatus == PHAuthorizationStatusRestricted ||
        authStatus == PHAuthorizationStatusDenied) {
        [self showSettingAlertStr:@"请在iPhone的“设置->隐私->照片”中打开本应用的访问权限"];
        return NO;
    }
    return YES;
}

+ (BOOL)checkCameraAuthorizationStatus
{
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        kTipAlert(@"该设备不支持拍照");
        return NO;
    }
    
    if ([AVCaptureDevice respondsToSelector:@selector(authorizationStatusForMediaType:)]) {
        AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
        if (AVAuthorizationStatusDenied == authStatus ||
            AVAuthorizationStatusRestricted == authStatus) {
            [self showSettingAlertStr:@"请在iPhone的“设置->隐私->相机”中打开本应用的访问权限"];
            return NO;
        }
    }
    
    return YES;
}

+ (void)showSettingAlertStr:(NSString *)tipStr{
    //iOS8+系统下可跳转到‘设置’页面，否则只弹出提示窗即可
    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_7_1) {
        [[UIAlertController ea_alertViewWithTitle:@"提示" message:tipStr buttonTitles:@[@"设置"] destructiveTitle:nil cancelTitle:@"取消" andDidDismissBlock:^(UIAlertAction *action, NSInteger index) {
            if (index == 0) {
                UIApplication *app = [UIApplication sharedApplication];
                NSURL *settingsURL = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
                if ([app canOpenURL:settingsURL]) {
                    [app openURL:settingsURL];
                }
            }
        }] show];
    }else{
        kTipAlert(@"%@", tipStr);
    }
}

@end
