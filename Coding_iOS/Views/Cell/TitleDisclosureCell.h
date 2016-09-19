//
//  TitleDisclosureCell.h
//  Coding_iOS
//
//  Created by 王 原闯 on 14-8-26.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#define kCellIdentifier_TitleDisclosure @"TitleDisclosureCell"

#import <UIKit/UIKit.h>

@interface TitleDisclosureCell : UITableViewCell
@property (strong, nonatomic, readonly) UILabel *titleLabel;

- (void)setTitleStr:(NSString *)title;

@end
