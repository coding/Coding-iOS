//
//  UserInfoDetailTagCell.h
//  Coding_iOS
//
//  Created by Ease on 15/3/18.
//  Copyright (c) 2015年 Coding. All rights reserved.
//

#define kCellIdentifier_UserInfoDetailTagCell @"UserInfoDetailTagCell"

#import <UIKit/UIKit.h>

@interface UserInfoDetailTagCell : UITableViewCell
- (void)setTitleStr:(NSString *)titleStr;
- (void)setTagStr:(NSString *)tagStr;
+ (CGFloat)cellHeightWithObj:(id)obj;
@end
