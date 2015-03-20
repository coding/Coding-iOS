//
//  InputOnlyTextPlainCell.h
//  Coding_iOS
//
//  Created by 王 原闯 on 14-8-26.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#define kCellIdentifier_InputOnlyTextPlain @"InputOnlyTextPlainCell"

#import <UIKit/UIKit.h>

@interface InputOnlyTextPlainCell : UITableViewCell

@property (nonatomic,copy) void(^textValueChangedBlock)(NSString*);
- (void)configWithPlaceholder:(NSString *)phStr valueStr:(NSString *)valueStr secureTextEntry:(BOOL)isSecure;

@end
