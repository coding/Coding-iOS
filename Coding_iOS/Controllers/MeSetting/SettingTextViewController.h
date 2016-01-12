//
//  SettingTextViewController.h
//  Coding_iOS
//
//  Created by 王 原闯 on 14-10-13.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#import "BaseViewController.h"

typedef NS_ENUM(NSInteger, SettingType)
{
    SettingTypeOnlyText = 0,
    SettingTypeFolderName,
    SettingTypeNewFolderName,
    SettingTypeFileVersionRemark,
    SettingTypeFileName
};

@interface SettingTextViewController : BaseViewController<UITableViewDataSource, UITableViewDelegate>
@property (strong, nonatomic) NSString *textValue, *placeholderStr;
@property (copy, nonatomic) void(^doneBlock)(NSString *textValue);
@property (assign, nonatomic) SettingType settingType;

+ (instancetype)settingTextVCWithTitle:(NSString *)title textValue:(NSString *)textValue doneBlock:(void(^)(NSString *textValue))block;
+(void)showSettingFolderNameVCFromVC:(UIViewController *)preVc withTitle:(NSString *)title textValue:(NSString *)textValue type:(SettingType)type doneBlock:(void(^)(NSString *textValue))block;

@end
