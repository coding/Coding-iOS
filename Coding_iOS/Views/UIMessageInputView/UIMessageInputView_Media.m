//
//  UIMessageInputView_Media.m
//  Coding_iOS
//
//  Created by Ease on 15/4/7.
//  Copyright (c) 2015年 Coding. All rights reserved.
//

#import "UIMessageInputView_Media.h"

@implementation UIMessageInputView_Media
+ (id)mediaWithAsset:(ALAsset *)asset urlStr:(NSString *)urlStr{
    UIMessageInputView_Media *media = [[UIMessageInputView_Media alloc] init];
    media.curAsset = asset;
    media.assetURL = [asset valueForProperty:ALAssetPropertyAssetURL];
    media.urlStr = urlStr;
    media.state = urlStr.length > 0? UIMessageInputView_MediaStateUploadSucess: UIMessageInputView_MediaStateInit;
    return media;
}
@end
