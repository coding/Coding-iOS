//
//  Helper.m
//  Coding_iOS
//
//  Created by Elf Sundae on 14-12-22.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#import "Helper.h"
@import AVFoundation;

#define kAlertTagPhotoLibraryOpenSettings   100
#define kAlertTagCameraOpenSettings         101

@interface Helper ()
<UIAlertViewDelegate>
@end

@implementation Helper

+ (BOOL)checkPhotoLibraryAuthorizationStatus
{
    if ([ALAssetsLibrary respondsToSelector:@selector(authorizationStatus)]) {
        ALAuthorizationStatus authStatus = [ALAssetsLibrary authorizationStatus];
        if (ALAuthorizationStatusDenied == authStatus ||
            ALAuthorizationStatusRestricted == authStatus) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"照片访问失败"
                                                            message:@"请在 系统设置->隐私->照片 中打开本应用的访问权限"
                                                           delegate:nil
                                                  cancelButtonTitle:@"取消"
                                                  otherButtonTitles:nil];
            if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_7_1) {
                [alert addButtonWithTitle:@"设置"];
                alert.delegate = self;
                alert.tag = kAlertTagPhotoLibraryOpenSettings;
            }
            [alert show];
            
            return NO;
        }
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
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"相机访问失败"
                                                            message:@"请在 系统设置->隐私->相机 中打开本应用的访问权限"
                                                           delegate:nil
                                                  cancelButtonTitle:@"取消"
                                                  otherButtonTitles:nil];
            if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_7_1) {
                [alert addButtonWithTitle:@"设置"];
                alert.delegate = self;
                alert.tag = kAlertTagCameraOpenSettings;
            }
            [alert show];
            
            return NO;
        }
    }
    
    return YES;
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - UIAlertView Delegate

+ (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (kAlertTagPhotoLibraryOpenSettings == alertView.tag ||
        kAlertTagCameraOpenSettings == alertView.tag) {
        if (buttonIndex != alertView.cancelButtonIndex) {
            UIApplication *app = [UIApplication sharedApplication];
            NSURL *settingsURL = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
            if ([app canOpenURL:settingsURL]) {
                [app openURL:settingsURL];
            }
        }
    }
}

@end
